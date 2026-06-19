# The Analytic Rank of an L-Function: A Formal Skeleton for Birch–Swinnerton-Dyer

**Author:** Aristotle
**Date:** 2026-06-19
**Domain:** Applications (Number Theory / Arithmetic Geometry)

## Abstract

The Birch and Swinnerton-Dyer (BSD) conjecture predicts that the algebraic rank of
an elliptic curve $E/\mathbb{Q}$ — the rank $r$ of its finitely generated
Mordell–Weil group $E(\mathbb{Q}) \cong \mathbb{Z}^r \times T$ — equals the
*analytic rank*, the order of vanishing at $s = 1$ of the Hasse–Weil L-function
$L(E,s)$. It further predicts the exact leading Taylor coefficient of $L$ at $s=1$
in terms of the real period $\Omega_E$, the regulator $\operatorname{Reg}_E$, the
order of the Tate–Shafarevich group $\#\Sha(E)$, the Tamagawa numbers $c_p$, and
the torsion order. This paper isolates and rigorously establishes the *analytic*
half of the rank statement. We define the analytic rank as the natural-number order
of vanishing $\operatorname{ord}_{s_0} L$, and prove four structural theorems that
any reasonable theory of L-function rank must satisfy: (1) **rank-zero detection**,
$\operatorname{rank}_{\mathrm{an}} = 0 \iff L(s_0) \ne 0$; (2) its contrapositive,
**positive-rank detection**; (3) the **leading-term factorization** exhibiting the
nonzero leading coefficient predicted by the full BSD formula; and (4)
**additivity** of analytic rank under products, the rank-level shadow of the Artin
formalism. We certify non-vacuity by constructing, for each $r \in \mathbb{N}$, an
explicit model L-function of analytic rank exactly $r$. On the local side we record
the algebraic reformulation of Hasse's bound: a Frobenius eigenvalue lies on the
circle $|z| = \sqrt p$ iff $a^2 \le 4p$. All results have been formally verified.

---

## 1. Introduction

### 1.1 The two ranks

Let $E/\mathbb{Q}$ be an elliptic curve, given in Weierstrass form by
$y^2 = x^3 + ax + b$ with $4a^3 + 27b^2 \ne 0$. Its set of rational points
$E(\mathbb{Q})$ carries an abelian group law (the chord–tangent construction). By
the **Mordell–Weil theorem**, this group is finitely generated:
$$ E(\mathbb{Q}) \;\cong\; \mathbb{Z}^r \times T, $$
where $T = E(\mathbb{Q})_{\mathrm{tors}}$ is finite and $r \ge 0$ is the **algebraic
rank**. The rank measures the number of independent rational points of infinite
order; it is finite but not effectively computable by any known unconditional
algorithm.

To each prime $p$ of good reduction associate the **trace of Frobenius**
$$ a_p = p + 1 - \#E(\mathbb{F}_p), $$
and form the **Hasse–Weil L-function** as the Euler product
$$ L(E, s) = \prod_{p \text{ good}} \big(1 - a_p p^{-s} + p^{1 - 2s}\big)^{-1} \cdot \prod_{p \text{ bad}} (\text{local factor}), \qquad \Re(s) > 3/2, $$
which (by modularity, Wiles et al.) continues analytically to all of $\mathbb{C}$.
The **analytic rank** is the order of vanishing at the central point:
$$ \operatorname{rank}_{\mathrm{an}}(E) := \operatorname{ord}_{s=1} L(E, s). $$

### 1.2 The conjecture

> **Conjecture (BSD, rank form).** $\operatorname{ord}_{s=1} L(E,s) = r$.

> **Conjecture (BSD, strong form).** Writing $r$ for the common rank,
> $$ \lim_{s\to 1} \frac{L(E,s)}{(s-1)^r} = \frac{\Omega_E \cdot \operatorname{Reg}_E \cdot \#\Sha(E) \cdot \prod_p c_p}{(\#E(\mathbb{Q})_{\mathrm{tors}})^2}. $$

The known unconditional results are partial: by Gross–Zagier and Kolyvagin, if the
analytic rank is $0$ or $1$ then it equals the algebraic rank, and $\Sha$ is finite
in those cases. The general statement, and the finiteness of $\Sha$, remain open and
constitute one of the Clay Millennium Prize Problems.

### 1.3 Contribution and scope

We do not resolve BSD. Instead we give a **formally verified analytic skeleton**:
the precise, unconditional structural properties that the order-of-vanishing
invariant satisfies, decoupled from the (open) identification with the algebraic
rank. These are the statements on which any proof of BSD's rank equality must
ultimately rest, and which a formalization of the full conjecture would import as
lemmas. We work with an abstract analytic function $L : \mathbb{C} \to \mathbb{C}$
and a central point $s_0 \in \mathbb{C}$ (take $s_0 = 1$ for BSD), using the order
of vanishing as the organizing invariant.

---

## 2. Definitions

Throughout, "analytic at $s_0$" means complex-analytic (holomorphic) in a
neighborhood of $s_0$. For an analytic function the **order of vanishing**
$\operatorname{ord}_{s_0} L \in \mathbb{N} \cup \{\infty\}$ is the largest $n$ such
that $(s - s_0)^{-n} L(s)$ remains analytic and nonzero at $s_0$; it equals $\infty$
exactly when $L$ vanishes identically near $s_0$. Mathlib models this as
`analyticOrderAt L s₀`, valued in $\mathbb{N}_\infty = \mathbb{N} \cup \{\infty\}$.

**Definition 2.1 (Analytic rank).**
$$ \operatorname{analyticRank}(L, s_0) := \big(\operatorname{ord}_{s_0} L\big)_{\mathbb{N}} \in \mathbb{N}, $$
the truncation to $\mathbb{N}$ of the order of vanishing (so $\infty \mapsto 0$ under
truncation, which is why finiteness hypotheses appear below). For the BSD L-function
one takes $s_0 = 1$.

**Definition 2.2 (Finiteness / non-degeneracy).** We say $L$ is *non-degenerate at
$s_0$* if $\operatorname{ord}_{s_0} L \ne \infty$, i.e. $L$ is not identically zero
in any neighborhood of $s_0$. This is the formal counterpart of the
analytic-continuation hypothesis: BSD's L-function is non-degenerate because it is a
nonzero entire function.

**Definition 2.3 (Model L-function).** For $r \in \mathbb{N}$ and $c \in \mathbb{C}$,
$$ \operatorname{modelL}(r, c)(s) := (s - 1)^r \cdot c. $$
This is the simplest entire function with prescribed order of vanishing at $s_0 = 1$.

**Definition 2.4 (Local factor and Frobenius).** At a prime $p$ of good reduction,
the local L-factor is the reciprocal of
$$ L_p(T) = 1 - a_p T + p T^2, $$
whose reciprocal roots $\alpha, \beta$ — the roots of the **Frobenius
characteristic polynomial** $X^2 - a_p X + p$ — are the *Frobenius eigenvalues*.
By Vieta, $\alpha + \beta = a_p$ and $\alpha\beta = p$.

---

## 3. Main Results

### 3.1 Rank-zero and positive-rank detection

**Theorem 3.1 (`analyticRank_eq_zero_iff`, rank-zero detection).**
Let $L$ be analytic at $s_0$ and non-degenerate at $s_0$. Then
$$ \operatorname{analyticRank}(L, s_0) = 0 \iff L(s_0) \ne 0. $$

*Proof sketch.* By definition the rank is the $\mathbb{N}$-truncation of
$\operatorname{ord}_{s_0} L$. Truncation gives $0$ either when the order is genuinely
$0$ or when it is $\infty$; the non-degeneracy hypothesis excludes the latter, so
rank $0$ is equivalent to $\operatorname{ord}_{s_0} L = 0$. A standard
characterization (`analyticOrderAt_eq_zero`) states that, for a function analytic at
$s_0$, the order of vanishing is $0$ iff $L(s_0) \ne 0$. Combining the two gives the
equivalence. $\square$

**Theorem 3.2 (`analyticRank_pos_iff`, positive-rank detection).**
Under the same hypotheses,
$$ \operatorname{analyticRank}(L, s_0) \ge 1 \iff L(s_0) = 0. $$

*Proof sketch.* The rank is a natural number, so being positive is the negation of
being zero. Apply Theorem 3.1 and negate both sides: $L(s_0) \ne 0$ becomes
$L(s_0) = 0$. $\square$

These two theorems formalize the most-cited consequence of BSD: for the
elliptic-curve L-function, $L(E,1) \ne 0$ corresponds to algebraic rank $0$ (finitely
many rational points), while $L(E,1) = 0$ corresponds to positive rank (infinitely
many rational points). The detection statements are unconditional facts about the
analytic side; BSD is the (open) assertion that the analytic rank so detected equals
the algebraic rank.

### 3.2 Leading-term factorization

**Theorem 3.3 (`analyticRank_factorization`).**
Let $L$ be analytic and non-degenerate at $s_0$, with $r = \operatorname{analyticRank}(L, s_0)$.
Then there exists an analytic function $g$ with $g(s_0) \ne 0$ such that, in a
neighborhood of $s_0$,
$$ L(s) = (s - s_0)^r \cdot g(s). $$

*Proof sketch.* This is the defining universal property of the order of vanishing.
Mathlib's `AnalyticAt.analyticOrderNatAt_eq_iff` states, for a function analytic and
of finite order at $s_0$, that the order equals $n$ iff such a factorization with
$g(s_0)\ne 0$ exists. Instantiating $n = r$ (which holds by definition) extracts the
witness $g$. $\square$

The value $g(s_0)$ is exactly the **leading Taylor coefficient**
$\lim_{s\to s_0}(s-s_0)^{-r}L(s)$. For the BSD L-function with $s_0 = 1$, this
coefficient is precisely the quantity the strong BSD formula evaluates:
$$ g(1) = \frac{\Omega_E \cdot \operatorname{Reg}_E \cdot \#\Sha(E) \cdot \prod_p c_p}{(\#E(\mathbb{Q})_{\mathrm{tors}})^2}. $$
Theorem 3.3 guarantees, unconditionally, that such a finite nonzero leading
coefficient *exists* whenever $L$ is non-degenerate; the strong conjecture is the
arithmetic *evaluation* of it.

### 3.3 Additivity under products

**Theorem 3.4 (`analyticRank_mul`, additivity).**
Let $f, g$ be analytic and non-degenerate at $s_0$. Then
$$ \operatorname{analyticRank}(f \cdot g, s_0) = \operatorname{analyticRank}(f, s_0) + \operatorname{analyticRank}(g, s_0). $$

*Proof sketch.* Orders of vanishing add under multiplication of analytic functions:
if $f = (s-s_0)^m f_1$ and $g = (s-s_0)^n g_1$ with $f_1(s_0), g_1(s_0) \ne 0$, then
$fg = (s-s_0)^{m+n} f_1 g_1$ with $(f_1 g_1)(s_0) \ne 0$. In $\mathbb{N}_\infty$ this
is `analyticOrderAt_mul`; truncating to $\mathbb{N}$ requires both orders finite,
supplied by the non-degeneracy hypotheses, giving the natural-number identity
`analyticOrderNatAt_mul`. $\square$

Additivity is the rank-level form of the **Artin / Rankin–Selberg formalism**: when
an abelian variety decomposes (up to isogeny) into a product, its L-function
factors, and analytic ranks add. It underlies the strategy of reducing a curve's
analytic rank to those of simpler isogeny factors. Combined with Theorem 3.1 it
yields **isogeny invariance** of the analytic rank: multiplying $L$ by a
non-vanishing analytic unit $u$ (with $u(s_0)\ne 0$, hence $\operatorname{rank} u = 0$)
leaves the analytic rank unchanged — the analytic shadow of the BSD prediction that
isogenous curves share a rank (see Future Directions, Conjecture 3).

### 3.4 Non-vacuity: every rank is realized

**Lemma 3.5 (`modelL_analyticAt`).** For all $r \in \mathbb{N}$, $c \in \mathbb{C}$,
the model $\operatorname{modelL}(r,c)$ is analytic everywhere, in particular at
$s_0 = 1$.

*Proof sketch.* $(s-1)^r$ is a polynomial (analytic as a product of $r$ copies of
the analytic function $s \mapsto s-1$), and the constant $c$ is analytic; the product
of analytic functions is analytic. $\square$

**Theorem 3.6 (`modelL_analyticRank`, realizability).** For all $r \in \mathbb{N}$
and $c \ne 0$,
$$ \operatorname{analyticRank}(\operatorname{modelL}(r,c), 1) = r. $$

*Proof sketch.* By Lemma 3.5 the model is analytic at $1$. The factorization
$\operatorname{modelL}(r,c)(s) = (s-1)^r \cdot c$ exhibits exactly the form of
Theorem 3.3 with $g \equiv c$ and $g(1) = c \ne 0$, so the order of vanishing is the
natural number $r$ (`analyticOrderAt_eq_natCast`). Truncating $r$ to $\mathbb{N}$
returns $r$. $\square$

**Corollary 3.7 (`modelL_central_value`).** For $c \ne 0$,
$$ \operatorname{modelL}(r,c)(1) = 0 \iff r \ge 1. $$

*Proof sketch.* At $s = 1$ the factor $(s-1)^r$ becomes $0^r$, which is $0$ for
$r \ge 1$ and $1$ for $r = 0$; multiplying by $c \ne 0$, the value is $0$ iff
$r \ge 1$. $\square$

Theorem 3.6 shows the analytic-rank invariant is **surjective onto $\mathbb{N}$**:
it is not secretly constant or trivial. Corollary 3.7 is the positive-rank
detection theorem (3.2) made fully explicit on this family.

### 3.5 The local side: Hasse's bound, algebraically

**Theorem 3.8 (Hasse bound, eigenvalue form).** Let $p$ be prime and $a \in \mathbb{Z}$.
A root $z \in \mathbb{C}$ of the Frobenius polynomial $X^2 - aX + p$ lies on the
circle of radius $\sqrt p$, i.e. $|z| = \sqrt p$, if and only if
$$ a^2 \le 4p. $$

*Proof sketch.* The roots are $z = \tfrac{a \pm \sqrt{a^2 - 4p}}{2}$. If
$a^2 \le 4p$, the discriminant is $\le 0$, the roots are complex conjugates, and
$|z|^2 = z\bar z = \alpha\beta = p$ by Vieta, so $|z| = \sqrt p$. Conversely, if
$|z| = \sqrt p$ then $z\bar z = p = \alpha\beta$ forces $\bar z = \beta$, so the
roots are conjugate, the discriminant $a^2 - 4p$ is $\le 0$, hence $a^2 \le 4p$.
$\square$

This is the algebraic core of the **Riemann Hypothesis for elliptic curves over
finite fields** (Hasse's theorem $|a_p| \le 2\sqrt p$): the analytic statement
"eigenvalues on the circle $\sqrt p$" is equivalent to a one-line integer
inequality. The reciprocal-root symmetry $\alpha \leftrightarrow p/\alpha$ encodes
the functional equation of the local zeta function $Z_p(T) = L_p(T)/((1-T)(1-pT))$,
and the point count expands as
$\#E(\mathbb{F}_p) = p + 1 - a = (1-\alpha)(1-\beta)$, seeding the global Euler
product.

---

## 4. Algorithms

The structural theorems translate into concrete computational procedures, which the
companion `demo.py` realizes.

**Algorithm A — Analytic rank by series truncation.** Given a Taylor expansion of
$L$ at $s_0$ (coefficients $a_0, a_1, \dots$), the analytic rank is the index of the
first nonzero coefficient: $\operatorname{rank} = \min\{ n : a_n \ne 0 \}$. This
operationalizes Theorem 3.3 (the leading term is $a_r(s-s_0)^r$) and Theorem 3.1
(rank $0 \iff a_0 = L(s_0) \ne 0$). Complexity: $O(N)$ in the number of coefficients
examined, with a tolerance for floating-point zero-detection.

**Algorithm B — Trace of Frobenius and Hasse verification.** For a curve
$y^2 = x^3 + ax + b$ over $\mathbb{F}_p$, count affine points by evaluating the
Legendre symbol of $x^3+ax+b$ for each $x \in \mathbb{F}_p$, add the point at
infinity, set $a_p = p + 1 - \#E(\mathbb{F}_p)$, and check $a_p^2 \le 4p$
(Theorem 3.8). Complexity: $O(p \log p)$ per prime.

**Algorithm C — Local factor and Euler product.** Form $L_p(T) = 1 - a_p T + pT^2$,
factor it to obtain Frobenius eigenvalues $\alpha,\beta$, verify $|\alpha|=|\beta|=\sqrt p$
and $\alpha\beta = p$, and accumulate the partial Euler product
$\prod_{p \le X} L_p(p^{-s})^{-1}$ as a numerical approximation to $L(E,s)$.

---

## 5. Applications

- **Rank-zero curves and finiteness.** Theorem 3.1 gives the analytic criterion
  $L(E,1)\ne 0$ that (via Kolyvagin) certifies algebraic rank $0$ and hence finitely
  many rational points — useful in Diophantine problems and descent.
- **Congruent number problem.** Whether $n$ is the area of a rational right triangle
  is equivalent to positive rank of $y^2 = x^3 - n^2 x$; Theorem 3.2 provides the
  analytic test $L(E_n, 1) = 0$.
- **Cryptographic curve selection.** Hasse's bound (Theorem 3.8) constrains group
  orders $\#E(\mathbb{F}_p) = p+1-a_p \in [p+1-2\sqrt p,\ p+1+2\sqrt p]$, the
  backbone of elliptic-curve cryptography parameter choices.
- **Isogeny classes.** Additivity (Theorem 3.4) and its invariance corollary justify
  reducing rank computations across an isogeny class to a single representative.

---

## 6. Discussion

The results here cleanly separate the *analytic structure* of BSD from its *open
arithmetic content*. Theorems 3.1–3.4 are unconditional theorems about analytic
functions; they are exactly the lemmas a complete formalization of BSD would invoke
on the analytic side. What remains open is the bridge: identifying the analytic rank
defined here (Definition 2.1) with the algebraic Mordell–Weil rank, and evaluating
the leading coefficient $g(1)$ of Theorem 3.3 by the strong BSD formula. The
non-vacuity results (Theorems 3.5–3.7) guard against a subtle failure mode of
formalization — a definition that is technically well-typed but secretly constant —
by exhibiting the invariant's surjectivity onto $\mathbb{N}$.

A delicate point is the finiteness (non-degeneracy) hypothesis. The
$\mathbb{N}$-valued rank truncates $\infty$ to $0$, so without non-degeneracy the
equivalence "rank $0 \iff L(s_0)\ne 0$" would fail (a function identically zero near
$s_0$ has order $\infty$, truncated rank $0$, yet $L(s_0) = 0$). The hypothesis is
the formal shadow of the analytic-continuation input to BSD: the L-function is a
genuine nonzero entire function, hence non-degenerate.

---

## 7. Future Work

See the Future Directions section of the package for the full list. In brief:
(1) derive the local zeta functional equation $Z_p(1/(pT)) = (\text{power}) \cdot Z_p(T)$
purely from eigenvalue symmetry $\alpha\leftrightarrow p/\alpha$; (2) prove the Hasse
interval $[p+1-\lfloor 2\sqrt p\rfloor,\ p+1+\lfloor 2\sqrt p\rfloor]$ is symmetric
and saturated under the quadratic twist $a\mapsto -a$; (3) upgrade additivity
(Theorem 3.4) to full isogeny invariance of the analytic rank; (4) formulate the
parity bridge linking the central sign $w = (-1)^{\operatorname{rank}}$ to the parity
of the Mordell–Weil rank.

---

## 8. Conclusion

We have given a formally verified analytic skeleton for the Birch and
Swinnerton-Dyer conjecture: a clean definition of analytic rank as the order of
vanishing of an L-function at its central point, and four structural theorems —
rank-zero detection, positive-rank detection, leading-term factorization, and
additivity — together with an explicit realizability family certifying that the
invariant is genuinely surjective, and the algebraic reformulation of Hasse's bound
on the local side. These are the load-bearing analytic facts on which a complete
resolution of BSD must rest.
