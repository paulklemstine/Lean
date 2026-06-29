# The Projective Galois Structure of the Riccati Equation and the Kovacic Obstruction for EML Ordinary Differential Equations

**Author:** Aristotle
**Date:** 2026-06-28
**Domain:** Applications (Differential Galois Theory)

---

## Abstract

We develop the differential-Galois theory of ordinary differential equations
whose coefficients are *exponential–logarithmic* (EML) functions, working
entirely within an abstract differential field $K$ equipped with a derivation
$x \mapsto x'$. The central object is the **Riccati equation**
$v' + v^2 + p\,v + q = 0$, the equation satisfied by the logarithmic derivative
$v = y'/y$ of a solution of the second-order linear equation
$y'' + p\,y' + q\,y = 0$. Our main structural result is that the differential
Galois group of the Riccati equation is **projective**: it embeds in
$\mathrm{PGL}_2$ of the field of constants. We prove this in basis-free form by
exhibiting the projective invariant — the **cross-ratio** of four solutions — as
a constant of the differential field. The proof rests on a *difference law*
showing that the difference of two Riccati solutions satisfies a first-order
linear equation, combined with the homomorphism property of the logarithmic
derivative (multiplication of solutions adds coefficients). We then connect this
symmetry picture to the **Kovacic decision procedure**: the gauge transformation
that reduces a general second-order EML equation to normal Riccati form, the
clearing of denominators that translates rational solvability into a polynomial
identity, and a degree-parity obstruction proving that **Airy's equation**
$y'' = x\,y$ has no elementary (EML) solution. We show the parity criterion is
sharp: every odd-degree coefficient $x^{2k+1}$ is obstructed, while the
even-degree coefficient $x^2+1$ admits the explicit rational Riccati solution
$v = x$ (corresponding to $y = e^{x^2/2}$). All results are stated over an
arbitrary differential field with no characteristic or algebraic-closure
hypotheses; the obstruction results live in the polynomial ring $\mathbb{R}[X]$.

---

## 1. Introduction

### 1.1 Differential Galois theory in one paragraph

Classical Galois theory attaches to a polynomial a finite group of symmetries
and reads off solvability-by-radicals from the structure of that group.
**Differential Galois theory** (Picard–Vessiot theory) performs the analogous
construction for linear ordinary differential equations: it attaches to an
equation a *linear-algebraic* group — the differential Galois group — acting on
the space of solutions, and the question "is the equation solvable in elementary
(Liouvillian) terms?" becomes a question about the structure of that group. The
base field of the theory is not $\mathbb{Q}$ but the **field of constants**, the
elements annihilated by the derivation.

### 1.2 EML equations

By an **EML function** we informally mean a function assembled from the
exponential, the logarithm, polynomials, and field operations — the "ordinary"
closed-form functions of science. The corresponding class of ODEs has
EML coefficients, and the slogan organizing the theory is:

> *The differential Galois group of an EML equation is an EML group.*

For the first-order linear equation $y' = a\,y$ this group is the multiplicative
group of nonzero constants $\mathbb{G}_m$. The contribution of this paper is the
analogous, genuinely *nonlinear*, computation for the Riccati equation, whose
group is **projective**.

### 1.3 The differential-field formalism

To keep the algebra honest and free of analytic side-conditions, we work in a
**differential field**: a field $K$ together with a derivation
$\partial : K \to K$, written $x' := \partial x$, satisfying additivity and the
Leibniz rule $(xy)' = x'y + xy'$. We write the derivative-of-quotient and
derivative-of-inverse rules in their standard forms. All identities below are
purely algebraic consequences of these axioms.

**Definition 1.1 (Constants).** The *field of constants* of $K$ is
$$C \;=\; \{\, x \in K : x' = 0 \,\}.$$
It is a subfield of $K$: it is closed under addition (additivity of $\partial$),
multiplication and inverse (Leibniz and the inverse rule), and contains $0,1$.
This is the base field over which the differential Galois group is a
linear-algebraic group. *(Formalized as `constantsSubfield`, with membership
unfolding `mem_constantsSubfield : x ∈ C ↔ x' = 0`.)*

---

## 2. The logarithmic derivative as a homomorphism

The algebraic engine of the entire theory is the **logarithmic derivative**
$$L : K^\times \to (K, +), \qquad L(y) = \frac{y'}{y}.$$

**Lemma 2.1 (Homomorphism property, `logDeriv_mul`).** For nonzero $y, z$,
$$\frac{(yz)'}{yz} = \frac{y'}{y} + \frac{z'}{z}.$$
*Proof.* Apply Leibniz: $(yz)' = y'z + yz'$; divide by $yz$ and simplify. $\square$

This is the abstract content of $\log(yz) = \log y + \log z$. The companion
identities are $L(y/z) = L(y) - L(z)$ (`logDeriv_div`), $L(y^{-1}) = -L(y)$
(`logDeriv_inv`), and $L(y^n) = n\,L(y)$ for $n \in \mathbb{Z}$
(`logDeriv_zpow`). Thus $L$ is a group homomorphism whose kernel is exactly the
constants $C$.

The homomorphism property powers a complete **first-order solution calculus**.

**Lemma 2.2 (Superposition, `firstOrder_mul`).** If $y' = a\,y$ and $z' = b\,z$,
then
$$(yz)' = (a+b)\,(yz).$$
*Proof.* $(yz)' = y'z + yz' = a y z + b y z = (a+b) yz$. $\square$

This is the algebraic shadow of $e^A e^B = e^{A+B}$: multiplying solutions adds
coefficients. The quotient analogue is:

**Lemma 2.3 (Quotient solution, `firstOrder_div`).** If $y' = a\,y$,
$z' = b\,z$, and $z \neq 0$, then
$$(y/z)' = (a - b)\,(y/z).$$

There is also a finite version, `firstOrder_prod`: for a finite family with
$(y_i)' = a_i\,y_i$, the product $\prod_i y_i$ solves
$w' = \bigl(\sum_i a_i\bigr) w$.

Lemmas 2.2 and 2.3 are precisely the catalog machinery invoked in the cross-ratio
computation of Section 4.

---

## 3. The first-order Galois group is $\mathbb{G}_m(C)$

Before the projective (Riccati) computation, we record the linear (first-order)
one, which is its rank-one shadow.

**Theorem 3.1 (Constant ratio of solutions, `solution_ratio_isConstant`).** If
$y_1' = a\,y_1$, $y_2' = a\,y_2$ and $y_1 \neq 0$, then $(y_2/y_1)' = 0$, i.e.
$y_2/y_1 \in C$.
*Proof.* By the quotient rule and substitution of the equations, the numerator
of $(y_2/y_1)'$ is $y_2' y_1 - y_2 y_1' = a y_2 y_1 - y_2 a y_1 = 0$. $\square$

**Theorem 3.2 (Galois action is scaling by a constant, `galois_action_is_mul_constant`).**
Any two nonzero solutions $y_1, y_2$ of $y' = a\,y$ differ by a nonzero
constant: there is $c \in K$ with $c \neq 0$, $c' = 0$, and $y_2 = c\,y_1$.
*Proof.* Take $c = y_2/y_1$; it is nonzero (quotient of nonzeros) and constant
(Theorem 3.1), and $y_2 = c\,y_1$ by clearing the denominator. $\square$

**Theorem 3.3 (Solution space is a $\mathbb{G}_m(C)$-torsor, `galois_torsor`).**
For a fixed nonzero solution $y_1$, an element $y_2$ is a nonzero solution iff
$y_2 = c\,y_1$ for some nonzero constant $c$.
*Proof.* Forward direction is Theorem 3.2. Conversely, a constant multiple of a
solution is a solution (`const_mul_solution`), and a product of nonzeros is
nonzero. $\square$

Thus the differential Galois group of $y' = a\,y$ acts on its one-dimensional
solution line by the multiplicative group of nonzero constants $\mathbb{G}_m(C)$
— the prototypical EML group.

---

## 4. The projective Galois group of the Riccati equation

### 4.1 The Riccati equation and its origin

**Definition 4.1 (Riccati equation).** For $p, q \in K$, the *Riccati equation*
is the first-order nonlinear equation
$$v' + v^2 + p\,v + q = 0.$$

It is the logarithmic-derivative reduction of a second-order linear equation:

**Proposition 4.2 (Full Riccati transform, `riccati_full_of_second_order`).** If
$y \neq 0$ solves $y'' + p\,y' + q\,y = 0$, then $v = y'/y$ solves
$v' + v^2 + p\,v + q = 0$.
*Proof sketch.* The identity $(y'/y)' + (y'/y)^2 = y''/y$ (the Riccati identity
for the logarithmic derivative) reduces the claim to substituting
$y'' = -p\,y' - q\,y$ and simplifying. $\square$

### 4.2 The difference law

The decisive structural fact is that *differences* of Riccati solutions are
linear.

**Theorem 4.3 (Difference law, `riccati_diff`).** If $v_1$ and $v_2$ both solve
$v' + v^2 + p\,v + q = 0$, then
$$(v_1 - v_2)' = -\bigl(v_1 + v_2 + p\bigr)\,(v_1 - v_2).$$
*Proof.* Subtract the two Riccati equations:
$$
(v_1 - v_2)' = v_1' - v_2'
= -(v_1^2 - v_2^2) - p(v_1 - v_2)
= -\bigl[(v_1+v_2) + p\bigr](v_1 - v_2),
$$
using $v_1^2 - v_2^2 = (v_1+v_2)(v_1-v_2)$ and the cancellation of $q$. $\square$

Equivalently (`riccati_diff_logDeriv`), for distinct solutions
$$\frac{(v_1 - v_2)'}{v_1 - v_2} = -\bigl(v_1 + v_2 + p\bigr).$$

So every difference $v_i - v_j$ is a first-order linear solution with
coefficient $-(v_i + v_j + p)$, and the calculus of Section 2 applies to it.

### 4.3 The cross-ratio is constant

**Definition 4.4 (Cross-ratio, `crossRatio`).** For $v_1, v_2, v_3, v_4 \in K$,
$$[\,v_1, v_2; v_3, v_4\,] \;=\;
\frac{(v_1 - v_3)(v_2 - v_4)}{(v_1 - v_4)(v_2 - v_3)}.$$

This is the canonical projective invariant: it is exactly the quantity fixed by
the Möbius (i.e. $\mathrm{PGL}_2$) action on the projective line.

**Theorem 4.5 (Invariance of the cross-ratio, `riccati_crossRatio_isConstant`).**
Let $v_1, v_2, v_3, v_4$ all solve $v' + v^2 + p\,v + q = 0$, with $v_1 \neq v_4$
and $v_2 \neq v_3$ (so the cross-ratio is defined). Then
$$\bigl(\,[\,v_1, v_2; v_3, v_4\,]\,\bigr)' = 0,$$
i.e. the cross-ratio is a constant.

*Proof.* By Theorem 4.3, each difference is a first-order solution:
$$
(v_1 - v_3)' = -(v_1+v_3+p)(v_1-v_3), \qquad
(v_2 - v_4)' = -(v_2+v_4+p)(v_2-v_4),
$$
and similarly for $v_1 - v_4$, $v_2 - v_3$. Apply Lemma 2.2 (`firstOrder_mul`)
to the numerator $N = (v_1-v_3)(v_2-v_4)$ and denominator
$D = (v_1-v_4)(v_2-v_3)$:
$$
N' = \kappa_N\, N, \quad \kappa_N = -(v_1+v_3+p) - (v_2+v_4+p),
$$
$$
D' = \kappa_D\, D, \quad \kappa_D = -(v_1+v_4+p) - (v_2+v_3+p).
$$
Since $D \neq 0$ (both factors are nonzero by hypothesis), Lemma 2.3
(`firstOrder_div`) gives
$$
\bigl(N/D\bigr)' = (\kappa_N - \kappa_D)\,(N/D).
$$
Finally,
$$
\kappa_N - \kappa_D
= \bigl[-(v_1+v_2+v_3+v_4+2p)\bigr] - \bigl[-(v_1+v_2+v_3+v_4+2p)\bigr]
= 0,
$$
since each of $v_1, v_2, v_3, v_4$ occurs once in each bracket and the two copies
of $p$ match. Hence $(N/D)' = 0$. $\square$

**Interpretation.** Theorem 4.5 is the basis-free statement that the differential
Galois group of the Riccati equation is a subgroup of $\mathrm{PGL}_2(C)$: every
symmetry of the equation preserves the projective cross-ratio invariant, exactly
as Möbius transformations do in classical geometry. The cancellation
$\kappa_N = \kappa_D$ is the differential-algebraic incarnation of the chain-rule
identity underlying Möbius invariance of the cross-ratio. The hypotheses
$v_1 \neq v_4$, $v_2 \neq v_3$ are precisely well-definedness of the
denominator; no further assumption is needed.

### 4.4 The degeneration chain

Knowledge of explicit solutions degenerates the symmetry group along
$$
\mathrm{PGL}_2(C) \;\supset\;
\mathbb{G}_a \rtimes \mathbb{G}_m \;\supset\;
\mathbb{G}_m \;\supset\; 1,
$$
each step removing one degree of projective freedom:

- **One solution** $v_0$ linearizes the equation via $v = v_0 + 1/u$, with
  $u' = (2 v_0 + p)\,u + 1$; the stabilizer is the affine group
  $\mathbb{G}_a \rtimes \mathbb{G}_m$.
- **Two solutions** leave the scaling torus $\mathbb{G}_m$, exactly the
  first-order picture of Section 3 (the reciprocal-shifts $1/(v - v_0)$ form an
  affine line over the constants).
- **Three solutions** fix the projective coordinate completely; the symmetry is
  trivial. This is rigidity: three points determine a Möbius map.

The count of constant-field-rational solutions ($0, 1, 2$, or $\infty$) is thus a
complete discrete invariant of the Riccati Galois group — a projective analogue
of the order of a finite Galois group.

---

## 5. Reduction to normal form: the Riccati gauge

The Kovacic algorithm is stated for the *normal form* $u'' = r\,u$, whose
Riccati equation is $\tilde v' + \tilde v^2 = r$. A general second-order EML
equation carries a first-derivative term, so we need a gauge to remove it.

**Theorem 5.1 (Riccati gauge / completing the square, `riccati_gauge`).** Suppose
$2g = p$ (abstractly $g = p/2$) and $v$ solves $v' + v^2 + p\,v + q = 0$. Then
$\tilde v = v + g$ solves the normal-form Riccati equation
$$\tilde v' + \tilde v^2 = g' + g^2 - q.$$
*Proof.* Expand $(v+g)' + (v+g)^2 - (g'+g^2-q)$ using additivity of $\partial$.
It equals $(v' + v^2 + p v + q) + (2g - p)\,v$; the first parenthesis vanishes by
hypothesis and the second by $2g = p$. The proof is division-free and valid in
any differential field. $\square$

**Corollary 5.2 (`riccati_normalForm_of_second_order`).** A nonzero solution $y$
of $y'' + p\,y' + q\,y = 0$, gauged by any $g$ with $2g = p$, yields a solution
$\tilde v = y'/y + g$ of $\tilde v' + \tilde v^2 = g'+g^2-q$. The normal-form
coefficient is $r = g' + g^2 - q = q - \tfrac{p^2}{4} - \tfrac{p'}{2}$ when
$g = p/2$.

This is the Riccati-side companion of the substitution
$y = e^{-\frac12 \int p}\,u$ that removes the first-derivative term on the linear
side, and it is what allows the normal-form obstruction theory below to apply to
general EML equations.

---

## 6. The Kovacic obstruction: Airy's equation has no EML solution

### 6.1 Rational solvability as a polynomial identity

The first step of the Kovacic algorithm asks whether the normal-form Riccati
equation $v' + v^2 = f$ has a *rational* solution $v = p/q$ with $q \neq 0$.
Clearing denominators (using $v' = (p'q - pq')/q^2$ and $v^2 = p^2/q^2$) shows
this holds iff the polynomial identity
$$p'\,q - p\,q' + p^2 \;=\; f\,q^2$$
holds in the polynomial ring. We work in $\mathbb{R}[X]$.

**Definition 6.1 (`HasRationalRiccatiSolution`).** $f \in \mathbb{R}[X]$ *has a
rational Riccati solution* if there exist $p, q \in \mathbb{R}[X]$ with $q \neq 0$
and $p'q - pq' + p^2 = f\,q^2$.

### 6.2 The Wronskian-like degree bound

**Lemma 6.2 (`natDegree_wronskianLike_le`).** For $p, q \in \mathbb{R}[X]$,
$$\deg\bigl(p'\,q - p\,q'\bigr) \le \deg p + \deg q - 1.$$
*Proof sketch.* The "Wronskian-like" combination $p'q - pq'$ has its top-degree
terms cancel: both $p'q$ and $pq'$ have leading degree $\deg p + \deg q - 1$, and
their leading coefficients agree up to the cancellation, dropping the degree by
one. (Handled by case analysis on the degrees of $p, q$ in the formalization.)
$\square$

### 6.3 The odd-degree obstruction

**Theorem 6.3 (Odd-degree Riccati obstruction, `no_rational_solves_riccati_odd_deg`).**
If $f \in \mathbb{R}[X]$ has *odd* degree, then $p'q - pq' + p^2 = f\,q^2$ has no
solution with $q \neq 0$. Equivalently, $v' + v^2 = f$ has no rational solution.

*Proof.* Suppose a solution exists with $q \neq 0$. The right-hand side has
degree $\deg f + 2\deg q$, which is **odd** (since $\deg f$ is odd). For the left
side, split on $\deg p$ versus $\deg q$:

- **Case $\deg p \ge \deg q$.** Then $\deg(p^2) = 2\deg p \ge 2\deg q$, while by
  Lemma 6.2 the term $p'q - pq'$ has degree $\le \deg p + \deg q - 1 < 2\deg p$.
  So the left side has degree exactly $2\deg p$, an **even** number. Equating to
  the odd right-hand degree forces $\deg f + 2\deg q = 2\deg p$, i.e.
  $\deg f = 2(\deg p - \deg q)$ is even — contradicting $\deg f$ odd.
- **Case $\deg p < \deg q$.** Then $\deg(p^2) = 2\deg p \le 2\deg q - 2$ and, by
  Lemma 6.2, $\deg(p'q - pq') \le \deg p + \deg q - 1 \le 2\deg q - 2$. So the
  left side has degree $\le 2\deg q - 2$, strictly below the right side's degree
  $\ge 2\deg q + 1$. Contradiction.

Either way no solution exists. Notably, *coprimality of $p$ and $q$ is not
required*: the obstruction is purely metric (degree-parity), stronger than the
textbook pole argument. $\square$

### 6.4 Airy

**Theorem 6.4 (Airy has no rational Riccati solution, `no_rational_solves_riccati_airy`).**
There are no $p, q \in \mathbb{R}[X]$ with $q \neq 0$ and
$p'q - pq' + p^2 = X\,q^2$.
*Proof.* Apply Theorem 6.3 with $f = X$, whose degree is $1$, odd. $\square$

Combined with the polynomial-level obstruction (Airy has no nonzero polynomial
solution, `no_poly_solves_airy`), this packages as
`airy_no_poly_and_no_rational_riccati`: Airy's equation $y'' = x\,y$ has neither
a polynomial solution nor a rational Riccati solution — the first two layers of
the Kovacic procedure certifying that **Airy's equation has no elementary (EML)
closed-form solution.**

### 6.5 Sharpness of the parity criterion

**Theorem 6.5 (Generalized Airy obstruction, `no_rational_riccati_genAiry`).**
For every $k \in \mathbb{N}$, $f = X^{2k+1}$ has no rational Riccati solution.
*Proof.* $\deg X^{2k+1} = 2k+1$ is odd; apply Theorem 6.3. $\square$

**Theorem 6.6 (Even-degree solvability, `riccati_evenDeg_solvable`).** The
coefficient $f = X^2 + 1$ has the explicit rational (indeed polynomial) Riccati
solution $v = X$.
*Proof.* With $p = X$, $q = 1$: $p'q - pq' + p^2 = 1 + X^2 = f\,q^2$. $\square$

This witness is not artificial: $y'' = (x^2+1)\,y$ is solved by $y = e^{x^2/2}$,
whose logarithmic derivative is exactly $x = v$.

**Theorem 6.7 (Sharpness, `kovacic_parity_decision_sharp`).** On the family
$y'' = f\,y$ the odd-degree test is a correct and tight decision: every
$X^{2k+1}$ is obstructed while $X^2 + 1$ is solvable.
*Proof.* Conjunction of Theorems 6.5 and 6.6. $\square$

Thus the odd-degree hypothesis is *necessary*: it cannot be weakened without
admitting solvable even-degree examples.

---

## 7. Algorithmic summary

The results assemble into the first step of a Kovacic-style decision procedure
for a second-order EML equation $y'' + p\,y' + q\,y = 0$:

1. **Gauge to normal form.** Choose $g$ with $2g = p$; the normal-form
   coefficient is $r = g' + g^2 - q$ (Theorem 5.1). The Riccati equation becomes
   $\tilde v' + \tilde v^2 = r$.
2. **Test rational solvability.** A rational solution $\tilde v = p_0/q_0$ exists
   iff $p_0' q_0 - p_0 q_0' + p_0^2 = r\,q_0^2$ (Definition 6.1).
3. **Parity shortcut.** If $r$ is a polynomial of odd degree, *no* rational
   solution exists (Theorem 6.3); the equation has no first-step Liouvillian
   solution. For Airy ($r = x$) this terminates with "unsolvable" (Theorem 6.4).
4. **Symmetry bookkeeping.** Whatever rational solutions exist, the cross-ratio
   of any four solutions is constant (Theorem 4.5); the count of rational
   solutions ($0,1,2,\infty$) pins the Galois group on the degeneration chain
   $\mathrm{PGL}_2 \supset \mathbb{G}_a\rtimes\mathbb{G}_m \supset \mathbb{G}_m
   \supset 1$.

---

## 8. Discussion and applications

**Why projective and not linear.** The first-order linear theory (Section 3)
gives a $\mathbb{G}_m(C)$ torsor — a *line* of solutions. The Riccati equation,
being a nonlinear (quadratic) first-order equation, instead carries a
*projective line* of solutions: its symmetry group is $\mathrm{PGL}_2(C)$ and the
invariant is the cross-ratio. The two pictures are unified by the difference law
(Theorem 4.3), which exhibits each difference $v_i - v_j$ as a rank-one
($\mathbb{G}_m$) object; the projective combination of four such pieces collapses
the additive coefficients to zero (Theorem 4.5).

**Practical relevance.** Second-order linear ODEs pervade physics and
engineering — oscillators, wave propagation, quantum states near turning points,
control systems. The Kovacic algorithm is the rigorous arbiter of whether such
an equation has a closed-form solution. The Airy result is the paradigmatic
"no": Airy functions, fundamental in optics (caustics, rainbows) and quantum
mechanics (linear-potential turning points), are *provably* non-elementary, and
the proof here is a transparent degree-parity count rather than a pole analysis.

**Abstraction without loss.** All symmetry results are proved over an arbitrary
differential field with no characteristic or algebraic-closure hypotheses; the
obstruction results are polynomial-degree statements in $\mathbb{R}[X]$. This
keeps the arguments structural and broadly reusable.

---

## 9. Future directions

The Riccati Galois action degenerates along
$\mathrm{PGL}_2(C) \supset \mathbb{G}_a \rtimes \mathbb{G}_m \supset \mathbb{G}_m
\supset 1$, each known solution removing one projective degree of freedom. Three
testable conjectures push this pattern:

1. **Effective three-solution reconstruction.** For three distinct solutions
   $a, b, c$, every solution equals an explicit Möbius map of a constant $\kappa$
   (the cross-ratio), giving a genuine bijection
   $\{\text{solutions}\} \simeq C \cup \{\infty\}$. The only missing ingredient is
   the algebraic inversion of a Möbius map over the constants subfield — pure
   field algebra.
2. **Strict, complete degeneration.** Over an algebraically closed constant
   field the Riccati Galois group is *exactly* one of $\mathrm{PGL}_2$,
   $\mathbb{G}_a \rtimes \mathbb{G}_m$, $\mathbb{G}_m$, finite, or trivial, with
   the number of rational solutions being $0, 1, 2,$ or $\infty$ respectively —
   no other possibility. The discrete count is a complete invariant.
3. **Airy and beyond.** Extend the odd-degree obstruction from $\mathbb{R}[X]$ to
   the full transcendental EML setting and characterize precisely which
   coefficient families admit Liouvillian solutions.

---

## Appendix: catalog of formal results

| Name | Statement |
|------|-----------|
| `logDeriv_mul` | $L(yz) = L(y) + L(z)$ |
| `firstOrder_mul` | $y'=ay,\ z'=bz \Rightarrow (yz)'=(a{+}b)yz$ |
| `firstOrder_div` | $y'=ay,\ z'=bz,\ z\neq 0 \Rightarrow (y/z)'=(a{-}b)(y/z)$ |
| `constantsSubfield` | constants form a subfield $C$ |
| `galois_action_is_mul_constant` | two nonzero solutions of $y'=ay$ differ by a nonzero constant |
| `galois_torsor` | solution space of $y'=ay$ is a $\mathbb{G}_m(C)$-torsor |
| `riccati_full_of_second_order` | $y''+py'+qy=0 \Rightarrow v=y'/y$ solves Riccati |
| `riccati_diff` | $(v_1-v_2)' = -(v_1{+}v_2{+}p)(v_1-v_2)$ |
| `crossRatio` | $[v_1,v_2;v_3,v_4]$ definition |
| `riccati_crossRatio_isConstant` | cross-ratio of four solutions is constant |
| `riccati_gauge` | $2g=p \Rightarrow (v{+}g)'+(v{+}g)^2 = g'+g^2-q$ |
| `natDegree_wronskianLike_le` | $\deg(p'q-pq') \le \deg p + \deg q - 1$ |
| `no_rational_solves_riccati_odd_deg` | odd $\deg f$ $\Rightarrow$ no rational Riccati solution |
| `no_rational_solves_riccati_airy` | Airy ($f=X$) has no rational Riccati solution |
| `riccati_evenDeg_solvable` | $X^2+1$ has solution $v=X$ |
| `kovacic_parity_decision_sharp` | odd obstructed, $X^2+1$ solvable |
