# Injectivity Is All You Need: A Unified Single-Feature Universal Approximation Theorem for Standard Machine-Learning Activations

**Author:** Aristotle

**Date:** 2026-06-27

**Domain:** Applications (Approximation Theory / Machine Learning)

---

## Abstract

We give a unified, minimal account of universal approximation for the standard activation
functions of machine learning. The classical folklore states that single-hidden-layer
networks with sigmoidal activations are universal approximators; numerous variants
re-prove this separately for the logistic sigmoid, hyperbolic tangent, softplus, and
arctangent, each invoking properties peculiar to the chosen activation. We show that all
of these results are instances of a *single* structural fact: a strictly monotone (hence
injective) continuous activation, composed with any injective continuous input feature,
generates a uniformly dense subalgebra of the continuous functions on every compact
domain. The proof reduces, via the Stone–Weierstrass theorem, to the elementary
observation that one injective function already separates points. We isolate the lemma
that composition preserves injectivity, derive strict monotonicity for each of the four
canonical activations, and obtain — as corollaries of one general theorem — the density of
single-activation polynomial read-out networks on any compact interval. We also identify
the sharp boundary of the phenomenon: non-injective activations (e.g. Gaussian/radial
ones) can fail to be universal as a single feature, so a *family* of units is genuinely
required. The development is fully formalized and machine-checked. We discuss the
separation between the *qualitative* density question (settled here, and governed entirely
by injectivity) and the *quantitative* approximation-rate question (activation-dependent
and left as future work), and we sketch explicit shallow-network rate bounds.

**Keywords:** universal approximation, Stone–Weierstrass theorem, sigmoid, tanh, softplus,
arctan, strict monotonicity, injectivity, point separation, exponential polynomials,
EML class, dense subalgebra.

---

## 1. Introduction

### 1.1 Background and motivation

The universal approximation theorem is the theoretical bedrock of neural network
modelling. In its classical forms (Cybenko, Hornik, Funahashi, and others) it asserts
that finite linear combinations of activated affine functions are dense in the space of
continuous functions on a compact set, for suitable choices of activation. The result
licenses the practitioner's belief that a sufficiently large network can represent any
reasonable target relationship.

The literature, however, presents universality as a property tied to specific activation
functions and proven by activation-specific techniques. The logistic sigmoid is handled
via its sigmoidal limits; the hyperbolic tangent via its odd symmetry and saturation;
ReLU and softplus via piecewise-linear or smoothing arguments. This proliferation
obscures a simpler organizing principle.

This paper makes that principle explicit. We work in the **EML
(Exponential–Multiplicative–Logarithmic)** approximation programme, whose abstract
Stone–Weierstrass core reduces uniform density of a generated subalgebra to point
separation. Within this framework we prove that the *entire* qualitative content of
"single-activation universality" is the **injectivity** of the activation, which for the
standard zoo follows from **strict monotonicity**.

### 1.2 Contributions

1. **A composition lemma** (`injective_comp`): the composition of injective continuous
   maps is injective, the technical hinge connecting activations to features.
2. **A general single-activation density theorem** (`activation_feature_dense`,
   `activation_feature_approx`): for compact $X$, any injective continuous activation
   composed with any injective feature generates a dense subalgebra of $C(X,\mathbb{R})$,
   with an explicit $\varepsilon$-approximation form.
3. **A strict-monotonicity interface** (`strictMono_feature_dense`) that turns each
   activation into a one-line monotonicity check.
4. **Concrete instances** for the four canonical activations: strict monotonicity and
   injectivity of the logistic sigmoid, softplus, tanh, and arctan
   (`strictMono_sigmoid`, `strictMono_softplus`, `strictMono_tanh`,
   `Real.arctan_strictMono`), and the resulting density theorems on a compact interval
   (`sigmoid_dense_Icc`, `softplus_dense_Icc`, `tanh_dense_Icc`, `arctan_dense_Icc`),
   unified by `activation_dense_Icc`.
5. **A foundational corollary** identifying the exponential as merely the first instance:
   the density of exponential polynomials (`exponentialPolynomials_dense_Icc`,
   `exp_monomials_span_dense`).
6. **A sharp boundary**: the identification (as a falsifiable conjecture) that
   non-injective activations can fail single-feature universality, so injectivity is
   essentially necessary, not just sufficient.

### 1.3 What is and is not claimed

We settle the *qualitative* question — can a single-activation polynomial read-out hit
any continuous target to arbitrary accuracy on a compact domain? The answer is yes, and
the reason is injectivity, uniformly across activations. We do **not** here resolve the
*quantitative* question of approximation *rates* (degree/width as a function of accuracy
and target smoothness); that is genuinely activation-dependent and is the subject of
Section 8. The clean separation between these two questions is itself a contribution.

---

## 2. Preliminaries and notation

Throughout, $X$ denotes a topological space; for the density results $X$ is additionally
assumed **compact**. We write $C(X,\mathbb{R})$ for the space of continuous real-valued
functions on $X$, equipped with the supremum (uniform) norm
$$\|f\|_\infty = \sup_{x\in X} |f(x)|,$$
which is finite when $X$ is compact. The space $C(X,\mathbb{R})$ is a commutative
$\mathbb{R}$-algebra under pointwise addition, multiplication, and scalar multiplication.

For a subset $S \subseteq C(X,\mathbb{R})$, the **generated subalgebra**
$\operatorname{adjoin}_{\mathbb{R}} S$ is the smallest $\mathbb{R}$-subalgebra containing
$S$; concretely it consists of all polynomial expressions, with real coefficients, in the
elements of $S$. For a single generator $g$, the subalgebra
$\operatorname{adjoin}_{\mathbb{R}}\{g\}$ is exactly the set of univariate polynomials in
$g$:
$$\operatorname{adjoin}_{\mathbb{R}}\{g\} = \Big\{ \textstyle\sum_{k=0}^{d} c_k\, g^{k} : d\in\mathbb{N},\ c_k\in\mathbb{R} \Big\}.$$

A family $A \subseteq C(X,\mathbb{R})$ **separates points** if for all $x \ne y$ in $X$
there exists $h \in A$ with $h(x) \ne h(y)$.

We write $\sigma \circ g$ for composition; when $g : X \to \mathbb{R}$ and
$\sigma : \mathbb{R} \to \mathbb{R}$ are continuous, $\sigma \circ g \in C(X,\mathbb{R})$.

A map $h$ is **injective** if $h(x) = h(y) \Rightarrow x = y$. A function
$\sigma : \mathbb{R}\to\mathbb{R}$ is **strictly monotone (increasing)** if $x < y$
implies $\sigma(x) < \sigma(y)$; every strictly increasing function is injective.

---

## 3. The analytic engine: Stone–Weierstrass and point separation

The foundation is the Stone–Weierstrass theorem for real subalgebras, which we use in the
following form.

> **Theorem 3.1 (Stone–Weierstrass, density form).** Let $X$ be a compact space and let
> $A \le C(X,\mathbb{R})$ be a subalgebra that separates points. Then $A$ is uniformly
> dense in $C(X,\mathbb{R})$; equivalently, its topological closure equals the whole
> space, $\overline{A} = \top$.

In the formal development this is `eml_topologicalClosure_eq_top_of_separatesPoints`
(closure form) with companions `eml_dense_range_of_subalgebra_separatesPoints` (density
form) and `eml_exists_uniform_approx` (the $\varepsilon$-approximation form: for every
$f$ and every $\varepsilon>0$ there exists $p \in A$ with $\|p - f\|_\infty < \varepsilon$).

Theorem 3.1 converts a hard analytic problem (approximate every continuous function) into
a soft combinatorial one (tell points apart). The next lemma shows that a *single*
injective function discharges the hypothesis.

> **Lemma 3.2 (single injective member separates).** Let $A \le C(X,\mathbb{R})$ be a
> subalgebra and let $g \in A$ be injective. Then $A$ separates points.

*Proof.* Let $x \ne y$. Injectivity gives $g(x) \ne g(y)$, and $g \in A$ is the required
witness. $\qquad\blacksquare$

(Formal name: `separatesPoints_of_injective_mem`.) A companion lemma,
`separatesPoints_adjoin_of_separatesPoints`, records the more general statement that a
point-separating family generates a point-separating subalgebra.

---

## 4. Single-generator universality

Combining Lemma 3.2 with Theorem 3.1 applied to $A = \operatorname{adjoin}_\mathbb{R}\{g\}$
(which contains $g$) yields the cornerstone.

> **Theorem 4.1 (single-generator density, `adjoin_singleton_dense`).** Let $X$ be
> compact and $g \in C(X,\mathbb{R})$ injective. Then
> $$\overline{\operatorname{adjoin}_{\mathbb{R}}\{g\}} = C(X,\mathbb{R}),$$
> i.e. the polynomials in $g$ are uniformly dense in $C(X,\mathbb{R})$.

*Proof sketch.* The generator $g$ lies in $\operatorname{adjoin}_\mathbb{R}\{g\}$ (it is
the degree-one monomial). By Lemma 3.2 the subalgebra separates points. By Theorem 3.1 its
closure is everything. $\qquad\blacksquare$

> **Theorem 4.2 ($\varepsilon$-form, `adjoin_singleton_approx`).** Under the hypotheses of
> Theorem 4.1, for every $f \in C(X,\mathbb{R})$ and every $\varepsilon > 0$ there is a
> polynomial $p$ in $g$ with $\|p - f\|_\infty < \varepsilon$.

*Proof sketch.* Apply `eml_exists_uniform_approx` to the point-separating subalgebra
$\operatorname{adjoin}_\mathbb{R}\{g\}$. $\qquad\blacksquare$

This is already a complete universal-approximation statement: a *single* injective feature,
followed by arbitrary polynomial read-out, is universal on any compact domain.

---

## 5. Composition preserves injectivity

To pass from abstract injective features to actual activated neurons, we need that
applying an activation does not destroy injectivity.

> **Lemma 5.1 (`injective_comp`).** Let $\sigma : \mathbb{R}\to\mathbb{R}$ be a continuous
> injective map and $g : X \to \mathbb{R}$ a continuous injective map. Then the
> composition $\sigma \circ g \in C(X,\mathbb{R})$ is injective.

*Proof.* Suppose $(\sigma\circ g)(x) = (\sigma\circ g)(y)$, i.e. $\sigma(g(x)) =
\sigma(g(y))$. Injectivity of $\sigma$ gives $g(x) = g(y)$; injectivity of $g$ gives
$x = y$. $\qquad\blacksquare$

Feeding Lemma 5.1 into Theorem 4.1 gives the general activation theorem.

> **Theorem 5.2 (single-activation universality, `activation_feature_dense`).** Let $X$ be
> compact, $\sigma \in C(\mathbb{R},\mathbb{R})$ injective, and $g \in C(X,\mathbb{R})$
> injective. Then
> $$\overline{\operatorname{adjoin}_{\mathbb{R}}\{\sigma\circ g\}} = C(X,\mathbb{R}).$$

*Proof sketch.* By Lemma 5.1, $\sigma\circ g$ is injective; apply Theorem 4.1 to it.
$\qquad\blacksquare$

> **Theorem 5.3 ($\varepsilon$-form, `activation_feature_approx`).** Under the hypotheses
> of Theorem 5.2, for every $f \in C(X,\mathbb{R})$ and $\varepsilon>0$ there exists a
> polynomial $p$ in $\sigma\circ g$ with $\|p - f\|_\infty < \varepsilon$.

For ergonomics we package the most common usage — a strictly monotone, continuous
activation — as a dedicated interface.

> **Theorem 5.4 (strict-monotone interface, `strictMono_feature_dense`).** Let
> $\sigma : \mathbb{R}\to\mathbb{R}$ be strictly monotone and continuous, and let
> $g \in C(X,\mathbb{R})$ be injective on compact $X$. Then $\sigma\circ g$ generates a
> dense subalgebra of $C(X,\mathbb{R})$.

*Proof sketch.* Strict monotonicity implies injectivity (`StrictMono.injective`); apply
Theorem 5.2. $\qquad\blacksquare$

This is the workhorse: each activation now reduces to verifying *strict monotonicity*.

---

## 6. The standard activation zoo

We instantiate the framework on the four canonical activations. For each we record (i) its
definition as a continuous map $\mathbb{R}\to\mathbb{R}$, (ii) continuity, and (iii) strict
monotonicity, from which injectivity follows immediately.

### 6.1 Logistic sigmoid

$$\sigma(x) = \frac{1}{1 + e^{-x}}.$$

- **Continuity** (`continuous_sigmoid`): the denominator $1 + e^{-x}$ is continuous and
  strictly positive, so the quotient is continuous.
- **Strict monotonicity** (`strictMono_sigmoid`): for $x < y$ we have $-y < -x$, hence
  $e^{-y} < e^{-x}$, hence $1+e^{-y} < 1+e^{-x}$; dividing $1$ by a smaller positive
  number gives a larger result, so $\sigma(x) < \sigma(y)$.
- **Injectivity** (`injective_sigmoid`): immediate from strict monotonicity.

Continuous-map form: `sigmoidCM`.

### 6.2 Softplus

$$s(x) = \log(1 + e^{x}).$$

- **Continuity** (`continuous_softplus`): $1 + e^x$ is continuous and strictly positive,
  and $\log$ is continuous on the positives.
- **Strict monotonicity** (`strictMono_softplus`): for $x<y$, $e^x < e^y$ so $1+e^x <
  1+e^y$; the logarithm is strictly increasing on positives, so $s(x) < s(y)$.
- **Injectivity** (`injective_softplus`): immediate.

Continuous-map form: `softplusCM`.

### 6.3 Hyperbolic tangent

$$\tanh(x) = \frac{\sinh x}{\cosh x} = \frac{e^{x}-e^{-x}}{e^{x}+e^{-x}}.$$

- **Continuity** (`continuous_tanh`): $\tanh = \sinh/\cosh$ with $\cosh$ nowhere zero
  (indeed $\cosh > 0$).
- **Strict monotonicity** (`strictMono_tanh`): the derivative is
  $\dfrac{d}{dx}\tanh x = \dfrac{1}{\cosh^2 x} > 0$ for all $x$, and a function with
  everywhere-positive derivative is strictly increasing (`strictMono_of_deriv_pos`).
- **Injectivity** (`injective_tanh`): immediate.

Continuous-map form: `tanhCM`. (Mathlib v4.28.0 lacks a packaged `StrictMono` lemma for
`tanh`; the derivative computation supplies it.)

### 6.4 Arctangent

$$\arctan(x), \qquad \arctan : \mathbb{R}\to(-\tfrac\pi2,\tfrac\pi2).$$

- **Continuity** (`Real.continuous_arctan`): standard.
- **Strict monotonicity** (`Real.arctan_strictMono`): standard; arctan is the inverse of
  $\tan$ on its principal branch.
- **Injectivity** (`injective_arctan`): immediate.

Continuous-map form: `arctanCM`.

---

## 7. Density on a compact interval

Specializing to $X = [a,b] \subseteq \mathbb{R}$ with the **coordinate feature**
$g = \mathrm{id}$ (the inclusion $x \mapsto x$, `iccCoord`, which is injective by
`injective_iccCoord`) yields four concrete universality theorems and one unifying
statement.

> **Corollary 7.1 (sigmoid, `sigmoid_dense_Icc`).** On any compact interval $[a,b]$, the
> polynomials in $\sigma(x) = 1/(1+e^{-x})$ are uniformly dense in $C([a,b],\mathbb{R})$.

> **Corollary 7.2 (softplus, `softplus_dense_Icc`).** On any compact interval $[a,b]$, the
> polynomials in $s(x) = \log(1+e^{x})$ are uniformly dense in $C([a,b],\mathbb{R})$.

> **Corollary 7.3 (tanh, `tanh_dense_Icc`).** On any compact interval $[a,b]$, the
> polynomials in $\tanh(x)$ are uniformly dense in $C([a,b],\mathbb{R})$.

> **Corollary 7.4 (arctan, `arctan_dense_Icc`).** On any compact interval $[a,b]$, the
> polynomials in $\arctan(x)$ are uniformly dense in $C([a,b],\mathbb{R})$.

Each is the single line "apply Theorem 5.2 with the activation's injectivity and
`injective_iccCoord`." All four are special cases of:

> **Theorem 7.5 (uniform statement, `activation_dense_Icc`).** Let
> $\sigma:\mathbb{R}\to\mathbb{R}$ be strictly monotone and continuous, and $[a,b]$ a
> compact interval. Then the polynomials in $\sigma$ are uniformly dense in
> $C([a,b],\mathbb{R})$.

### 7.1 The exponential ancestor

The same machinery, applied to $\sigma = \exp$, recovers the classical result that seeded
the programme.

> **Theorem 7.6 (exponential polynomials, `exponentialPolynomials_dense_Icc`).** On any
> compact interval $[a,b]$, the subalgebra generated by $x \mapsto e^{x}$ — equivalently,
> finite real combinations $\sum_k c_k\, e^{k x}$ — is uniformly dense in
> $C([a,b],\mathbb{R})$.

A refinement shows that one need not take genuine *products* of distinct features; the
plain **linear span** of the exponential monomials already suffices.

> **Theorem 7.7 (span form, `exp_monomials_span_dense`).** For compact $X$ and injective
> $g$, the linear span of $\{(\exp\circ g)^k : k\in\mathbb{N}\}$ is dense in
> $C(X,\mathbb{R})$. Equivalently $\sum_k c_k\, e^{k\,g(x)}$ approximate every continuous
> function.

*Proof idea.* The carrier of $\operatorname{adjoin}_\mathbb{R}\{h\}$ equals the linear
span of the powers $\{h^k\}$, because the multiplicative closure of a single element is
exactly its powers (`adjoin_singleton_coe_eq_span_pow`); transport Theorem 4.1 across this
identification. $\qquad\blacksquare$

The conceptual upshot, recorded in the development's research notes: the exponential's role
was never analytic. Only its injectivity mattered, which is why the entire activation zoo
inherits universality by the identical argument.

---

## 8. Approximation rates for shallow networks (discussion and sketches)

Density is a *qualitative* statement. The *quantitative* refinement asks: to achieve
uniform error $\varepsilon$ for an $L$-Lipschitz (or $C^r$) target $f$ on $[a,b]$, what
polynomial degree $d$ (equivalently, read-out width) suffices? This is where activations
genuinely differ, and it is the natural next layer of theory.

A clean route to explicit bounds proceeds in two steps.

**Step 1 — Change of variable.** Let $u = \sigma(x)$. Because $\sigma$ is a strictly
monotone continuous bijection from $[a,b]$ onto $[\sigma(a),\sigma(b)]$, approximating
$f(x)$ by a degree-$d$ polynomial in $\sigma(x)$ is exactly approximating
$F(u) := f(\sigma^{-1}(u))$ by an ordinary degree-$d$ polynomial in $u$ on
$[\sigma(a),\sigma(b)]$.

**Step 2 — Classical polynomial rates.** Apply a Jackson-type theorem to $F$. If $F$ is
$L_F$-Lipschitz on an interval of length $M = \sigma(b)-\sigma(a)$, then the best
degree-$d$ polynomial approximation satisfies a bound of the shape
$$\inf_{\deg p \le d}\ \|F - p\|_\infty \ \le\ \frac{C\, L_F\, M}{d}$$
for an absolute constant $C$ (Jackson's first theorem), improving to $O(d^{-r})$ for
$C^r$ targets and to geometric decay $O(\rho^{-d})$ for functions analytic in a
Bernstein ellipse.

The activation enters only through the modulus distortion: $L_F$ depends on the inverse
slope $1/\sigma'$, and $M$ on the range of $\sigma$. For the four activations this gives
qualitatively different constants:

- **Sigmoid / arctan / tanh** are *saturating*: $\sigma' \to 0$ at the ends, so $\sigma^{-1}$
  has large slope near the range endpoints, inflating $L_F$ when $[a,b]$ is wide. Bounded
  range ($M \le 1, \pi, 2$ respectively) but steep inverse.
- **Softplus** is *non-saturating* on the right ($\sigma'(x) = \sigma_{\text{logistic}}(x)
  \to 1$), giving a milder inverse-slope penalty for large positive $x$, at the cost of an
  unbounded range.

These observations are heuristic sketches; turning them into formal, machine-checked rate
theorems (and identifying the activation that is optimal for a given smoothness class) is a
concrete program for follow-up work, complementary to the qualitative results proven here.

---

## 9. The sharp boundary: when one neuron is *not* enough

Injectivity is not merely a convenient sufficient condition; it is essentially the
dividing line for single-feature universality.

> **Proposition 9.1 (non-injective collapse, informal).** Let
> $\sigma : \mathbb{R}\to\mathbb{R}$ be continuous with $\sigma(a) = \sigma(b)$ for some
> $a \ne b$. Take $X = \{a,b\}$ (compact) and $g = \mathrm{id}$. Then $\sigma\circ g$ is
> constant on $X$, so $\operatorname{adjoin}_\mathbb{R}\{\sigma\circ g\}$ consists of
> constants and fails to separate the points $a, b$. Hence its closure is *not* all of
> $C(X,\mathbb{R})$: the single feature is not universal.

This immediately rules out radial/Gaussian activations $\rho(x) = e^{-x^2}$ (even, hence
$\rho(-c)=\rho(c)$) and any other non-injective activation as single-feature universal
approximators. With such activations one genuinely needs a *family* of units to recover
universality — the width/necessity counterpart to the sufficiency results of Sections 5–7.

Together with Theorem 5.2, Proposition 9.1 suggests the sharp characterization (stated as a
conjecture for full formalization): *a continuous activation $\sigma$ is single-feature
universal for every compact $X$ and every injective $g$ if and only if $\sigma$ is
injective.*

---

## 10. Related work and positioning

Classical universal approximation theorems (Cybenko 1989; Hornik–Stinchcombe–White 1989;
Funahashi 1989; Leshno–Lin–Pinkus–Schocken 1993) establish density for broad activation
classes, often via the Stone–Weierstrass theorem or via Fourier/ridge arguments. The
Leshno et al. characterization — a continuous activation yields universal shallow networks
iff it is non-polynomial — concerns the *multi-unit ridge* setting (varying weights and
biases, summing many units).

Our statement is orthogonal and complementary: we fix a *single* feature and obtain
universality through *polynomial read-out* rather than a sum of many activated units. In
this single-feature regime the governing property is **injectivity**, not
non-polynomiality. The two viewpoints meet in the EML programme, whose abstract
Stone–Weierstrass core (Section 3) we instantiate. The present contribution is the
recognition that the four canonical activations are unified by strict monotonicity and the
reduction of all four density results to one composition lemma.

---

## 11. Conclusion

Universal approximation for the standard activation zoo is not four theorems but one. The
load-bearing property is injectivity, supplied uniformly by strict monotonicity; the
analytic content is the Stone–Weierstrass reduction of density to point separation; and the
glue is the trivial fact that injective maps compose. From this we recover, as one-line
corollaries, the density of single-neuron polynomial read-out networks built on the
logistic sigmoid, softplus, tanh, and arctan, with the exponential as the historical first
instance. The framework also draws a sharp line: drop injectivity and a single neuron can
fail to be universal. What remains — and what genuinely depends on the choice of activation
— is the *rate* of approximation, the natural subject of future quantitative work.

---

## 12. Future directions

*The following are testable conjectures for follow-up cycles, carried over from the
development's research programme.*

- **C1 — Non-injective bounded activations require a family.** A Gaussian/RBF activation
  $\rho(x)=e^{-x^2}$ is not injective (it is even), so a single RBF feature $\rho\circ g$
  cannot generate a point-separating subalgebra when $g$ takes both a value and its
  negation. Concretely: exhibit a compact $X$ and injective $g$ with $-c, c \in
  \operatorname{range} g$ such that $\operatorname{adjoin}_\mathbb{R}\{\rho\circ g\}$ does
  not separate points; this is the activation-side analogue of a width/necessity result.

- **C2 — $L^p$ density transfer from uniform density.** For any finite Borel measure $\mu$
  on a compact metric space $X$ and any $1 \le p < \infty$, every point-separating EML
  subalgebra $A \le C(X,\mathbb{R})$ is dense in $L^p(\mu)$. Proof route: uniform density +
  the contraction $\|f\|_{L^p} \le \mu(X)^{1/p}\|f\|_\infty$ + density of $C(X)$ in $L^p$.

- **C3 — Two-layer EML width bound on $\mathbb{R}^n$ via Kolmogorov–Arnold inner
  functions.** Every $f \in C(K,\mathbb{R})$ on compact $K\subseteq\mathbb{R}^n$ is
  uniformly approximable by a sum of $2n+1$ outer polynomials applied to single-activation
  inner features $\sigma(\sum_i w_i x_i)$; i.e. the EML class realizes the
  Kolmogorov–Arnold width $2n+1$ with a fixed monotone activation.

- **C4 — Monotone-activation density is equivalent to injectivity (sharp
  characterization).** For continuous $\sigma$, the single feature $\sigma\circ g$ is
  universal for every compact $X$ and every injective $g$ iff $\sigma$ is injective. The
  forward direction is the activation density theorem; the converse is the
  constant-collapse argument of Proposition 9.1.

- **C5 — Quantitative degree/frequency bounds for exponential-polynomial approximation.**
  On $[a,b]$, approximating an $L$-Lipschitz $f$ to uniform error $\varepsilon$ with
  exponential polynomials $\sum_k c_k e^{k x}$ requires bounding the degree in terms of
  $L$, $\varepsilon$, and the interval, via the change-of-variable + Jackson route of
  Section 8.
