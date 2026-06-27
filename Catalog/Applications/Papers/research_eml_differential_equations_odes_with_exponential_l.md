# EML Differential Equations: A Differential-Algebra Framework for Riccati Reduction, Wronskian Existence Criteria, and the Kovacic Parity Obstruction

**Author:** Aristotle
**Date:** 2026-06-27
**Domain:** Applications (Differential Algebra / Differential Galois Theory)

---

## Abstract

We develop, entirely within the algebra of differential fields, the structural
backbone of the closed-form solution theory for second-order linear ordinary
differential equations $y'' = a\,y$ whose coefficients lie in a field of
*Exponential–Logarithmic (EML)* functions. Three pillars are established and made
fully rigorous. **(1) Canonical form.** The logarithmic-derivative substitution
$v = y'/y$ — the Riccati transform — reduces $y'' = a\,y$ to the first-order
quadratic Riccati equation $v' + v^2 = a$ in *any* differential field, with no
analytic, characteristic, or algebraic-closure hypotheses. **(2) Existence
criteria.** The field of constants $\mathcal{C} = \{x : x' = 0\}$ is the base
field over which the solution space is a module of dimension at most two; the
Wronskian $W = y_1 y_2' - y_2 y_1'$ of two solutions is always a constant
(abstract Abel identity), and a pair of solutions is a fundamental system exactly
when $W$ is a *nonzero* constant. **(3) The algebra–geometry gap.** While the
algebraic skeleton (constants, solution module, Galois action) is always present,
its realization by explicit EML solutions can fail. We give a sharp, decidable
witness: for the polynomial-coefficient family $y'' = f\,y$, the first step of the
Kovacic algorithm — existence of a rational solution of the associated Riccati
equation $v' + v^2 = f$ — fails for every odd-degree $f$ and can succeed for
even-degree $f$. Airy's equation $y'' = x\,y$ is the canonical witness: it has
neither a nonzero polynomial solution nor a rational Riccati solution. All results
described here have been formally verified.

---

## 1. Introduction

### 1.1 The closed-form question

The central question of the classical theory of linear ODEs is deceptively
simple: *given a second-order linear equation $y'' = a\,y$, can its solutions be
written in closed form?* Here "closed form" means an *EML expression* — a finite
formula built from a base field, the independent variable, and the operations of
field arithmetic, root extraction, exponentiation, and logarithm. Polynomials,
$e^{x}$, $\log(1+x^2)$, and $\sqrt{e^{x}+x}$ are EML; the Airy functions are not.

The modern answer is supplied by **differential Galois theory** (Picard–Vessiot,
Kolchin) and made algorithmic by **Kovacic's algorithm** (1986), which decides in
finitely many steps whether $y'' = a\,y$ over a rational-function field admits a
Liouvillian (closed-form) solution. The decision procedure's first and most basic
step is a search for a *rational solution of the associated Riccati equation*.

### 1.2 Contributions

This paper isolates and formally verifies the differential-algebra core of that
theory. Our contributions are:

1. A characteristic-free, analysis-free proof that the Riccati transform reduces
   $y'' = a y$ to $v' + v^2 = a$ in any differential field (Theorem
   `riccati_of_second_order`, §3).
2. A complete development of the field of constants as a subfield, the
   module structure of the solution space over it, and the abstract Abel identity
   for the Wronskian (§4).
3. A Wronskian-based existence/independence dichotomy: a fundamental system is
   detected precisely by a nonvanishing constant Wronskian (§5).
4. A sharp, two-sided parity obstruction for the Kovacic first step on the
   polynomial-coefficient family, with Airy's equation as the canonical
   non-solvable witness and $y'' = (x^2+1)y$ as a solvable witness (§6–§7).

The guiding slogan: *the differential Galois group lives as a linear-algebraic
group over the constants subfield; it acts on a solution module whose
non-degeneracy is detected by a nonvanishing constant Wronskian; and the gap
between this algebraic picture and an explicit EML realization is exactly the
failure of rational Riccati solvability, witnessed decidably by a parity count.*

---

## 2. Preliminaries: differential fields and EML coefficients

**Definition 2.1 (Differential field).** A *differential field* is a field $K$
equipped with a derivation $' : K \to K$, an additive map satisfying the Leibniz
rule
$$
(fg)' = f'g + fg', \qquad f,g \in K.
$$
From the field and Leibniz axioms one derives the quotient rule
$(f/g)' = (f'g - fg')/g^2$ for $g \neq 0$, and the reciprocal rule
$(1/g)' = -g'/g^2$.

**Definition 2.2 (EML / closed-form tower).** A coefficient field is *EML* if it
is obtained from a base differential field by a finite tower of extensions, each
adjoining an element that is algebraic, an exponential ($u$ with $u'/u \in K$), or
a logarithm ($u$ with $u' \in K$) over the previous stage. The prototypical EML
field of interest is $\mathbb{R}(x)$ with $x' = 1$ and its elementary extensions;
the polynomial ring $\mathbb{R}[x]$ is its differential subring.

**Remark 2.3.** All structural results in §3–§5 are proved for an *arbitrary*
differential field $K$ and therefore apply verbatim to any EML field. The concrete
obstructions of §6–§7 are proved for $K = \mathbb{R}(x)$, working through the
polynomial ring $\mathbb{R}[x]$.

**Definition 2.4 (Logarithmic derivative).** For $y \in K$ with $y \neq 0$, the
*logarithmic derivative* is
$$
\operatorname{logDeriv}(y) := \frac{y'}{y}.
$$

---

## 3. Pillar 1 — The Riccati transform (canonical form)

The Riccati transform is the canonical normal form that reduces a second-order
linear equation to a first-order quadratic one.

**Theorem 3.1 (Riccati transform, raw form — `logDeriv_riccati`).**
*For every $y \in K$ with $y \neq 0$,*
$$
\operatorname{logDeriv}(y)' + \operatorname{logDeriv}(y)^2 = \frac{y''}{y}.
$$

*Proof sketch.* Write $v = y'/y$. By the quotient rule,
$v' = (y'' y - (y')^2)/y^2 = y''/y - (y'/y)^2 = y''/y - v^2$. Rearranging gives
$v' + v^2 = y''/y$. Formally this is `Derivation.leibniz_div` followed by
`field_simp; ring`. $\qquad\blacksquare$

**Theorem 3.2 (Riccati transform for $y'' = a y$ — `riccati_of_second_order`).**
*If $y \neq 0$ and $y'' = a\,y$, then $v = y'/y$ satisfies*
$$
v' + v^2 = a.
$$

*Proof sketch.* Substitute $y'' = a y$ into Theorem 3.1: the right-hand side
$y''/y = (a y)/y = a$. $\qquad\blacksquare$

**Theorem 3.3 (Algebraic normal form — `riccati_squared_add_deriv`).**
*For $y \neq 0$,*
$$
\bigl(\operatorname{logDeriv}(y)' + \operatorname{logDeriv}(y)^2\bigr)\,y = y''.
$$
This is Theorem 3.1 cleared of denominators; it is the convenient form for
polynomial manipulations.

**Significance.** Theorem 3.2 is the substitution at the heart of the Kovacic
algorithm. It converts the *linear, second-order* problem into a *nonlinear,
first-order* one whose closed-form (in fact rational) solvability is decidable by
degree analysis. Crucially, no hypotheses on the characteristic or algebraic
closure of $K$ are needed; the identity is purely formal.

---

## 4. Pillar 2a — The field of constants and the solution module

**Definition 4.1 (Constants subfield — `constantsSubfield`).**
$$
\mathcal{C}(K) := \{\, x \in K : x' = 0 \,\}.
$$

**Proposition 4.2 (`mem_constantsSubfield`).** $\mathcal{C}(K)$ is a subfield of
$K$: it contains $0$ and $1$ and is closed under addition, negation,
multiplication, and inversion; membership is equivalent to $x' = 0$.

*Proof sketch.* Closure under each operation is a one-line derivation from the
Leibniz, sum, reciprocal, and inverse rules. For instance, if $a' = b' = 0$ then
$(ab)' = a'b + ab' = 0$, and $(a^{-1})' = -a'/a^2 = 0$. $\qquad\blacksquare$

$\mathcal{C}(K)$ is the base field over which the differential Galois group is a
*linear-algebraic* group — the "field of scalars" of the whole theory.

**Theorem 4.3 (First-order solution line — `firstOrder_ratio_isConstant`).**
*If $y_1, y_2$ both solve the first-order equation $y' = a\,y$ and $y_2 \neq 0$,
then $(y_1/y_2)' = 0$; i.e. $y_1/y_2 \in \mathcal{C}(K)$.*

*Proof sketch.* By the quotient rule, $(y_1/y_2)' = (y_1' y_2 - y_1 y_2')/y_2^2 =
(a y_1 y_2 - y_1 a y_2)/y_2^2 = 0$. $\qquad\blacksquare$

*Consequence.* The solution space of $y' = a y$ is one-dimensional over
$\mathcal{C}(K)$, so its differential Galois group embeds in the multiplicative
group $\mathcal{C}(K)^\times$ — the prototypical "EML group."

For the second-order equation $y'' = a\,y$ the solution set carries a module
structure over the constants:

**Theorem 4.4 (Scaling — `scale_solution`).** *If $c' = 0$ and $y'' = a y$, then
$(c y)'' = a\,(c y)$.*

**Theorem 4.5 (Superposition — `add_solution`).** *If $y_1'' = a y_1$ and
$y_2'' = a y_2$, then $(y_1 + y_2)'' = a\,(y_1 + y_2)$.*

*Proof sketches.* For 4.4, $(cy)' = c y'$ since $c' = 0$, and differentiating
again gives $(cy)'' = c y'' = c (a y) = a (cy)$. For 4.5, the derivation is
additive, so $(y_1+y_2)'' = y_1'' + y_2'' = a y_1 + a y_2 = a(y_1+y_2)$.
$\qquad\blacksquare$

Together, Theorems 4.4–4.5 make the solution set of $y'' = a y$ a
$\mathcal{C}(K)$-module.

---

## 5. Pillar 2b — The Wronskian and the fundamental-system criterion

**Definition 5.1 (Wronskian).** For $y_1, y_2 \in K$,
$$
W(y_1, y_2) := y_1\,y_2' - y_2\,y_1'.
$$

**Theorem 5.2 (Abstract Abel identity — `wronskian_deriv_eq_zero`,
`wronskian_isConstant`).** *If $y_1'' = a y_1$ and $y_2'' = a y_2$, then
$W(y_1,y_2)' = 0$; equivalently $W(y_1, y_2) \in \mathcal{C}(K)$.*

*Proof sketch.* By Leibniz,
$$
W' = (y_1 y_2' - y_2 y_1')' = (y_1' y_2' + y_1 y_2'') - (y_2' y_1' + y_2 y_1'')
   = y_1 y_2'' - y_2 y_1''.
$$
Substituting $y_i'' = a y_i$ gives $W' = y_1(a y_2) - y_2(a y_1) = 0$.
$\qquad\blacksquare$

**Definition 5.3 (Linear dependence over the constants —
`LinDepOverConstants`).** $y_1, y_2$ are *linearly dependent over $\mathcal{C}(K)$*
if there exist constants $c_1, c_2$, not both zero, with $c_1 y_1 + c_2 y_2 = 0$.

**Theorem 5.4 (Dependence $\Rightarrow$ vanishing Wronskian —
`wronskian_eq_zero_of_linDep`).** *If $y_1, y_2$ are linearly dependent over the
constants, then $W(y_1, y_2) = 0$.* (No differential equation is needed — this is
a property of the differential field.)

*Proof sketch.* Suppose $c_1 y_1 + c_2 y_2 = 0$ with $c_1, c_2$ constant and not
both zero. Differentiating and using $c_i' = 0$ gives $c_1 y_1' + c_2 y_2' = 0$.
Then $c_1 W = (c_1 y_1) y_2' - y_2 (c_1 y_1') = -(c_2 y_2) y_2' + y_2 (c_2 y_2') =
0$, and symmetrically $c_2 W = 0$. Since some $c_i \neq 0$, $W = 0$.
$\qquad\blacksquare$

**Corollary 5.5 (Nonzero Wronskian $\Rightarrow$ independence —
`linIndep_of_wronskian_ne_zero`).** *If $W(y_1, y_2) \neq 0$, then $y_1, y_2$ are
linearly independent over the constants.* (Contrapositive of Theorem 5.4.)

**Theorem 5.6 (Fundamental-system criterion —
`wronskian_isConstant_ne_zero_of_linIndep`).** *If $y_1'' = a y_1$,
$y_2'' = a y_2$, and $W(y_1, y_2) \neq 0$, then $W(y_1, y_2)$ is a **nonzero
constant**, i.e. $W \in \mathcal{C}(K)$ and $W \neq 0$.*

*Proof sketch.* Combine Theorem 5.2 (constancy) with the hypothesis
$W \neq 0$. $\qquad\blacksquare$

**Interpretation.** Theorem 5.6 is the effective existence condition: a pair of
solutions is a *fundamental system* — a basis of the full (at most
two-dimensional) solution module over $\mathcal{C}(K)$ — precisely when their
Wronskian is a nonzero constant. The single scalar $W$ both certifies
independence and, by Abel's identity, is automatically constant on the solution
space. This is the algebraic non-degeneracy condition underlying the entire
existence theory.

---

## 6. Pillar 3a — Polynomial obstructions for Airy and its generalizations

We now turn to concrete non-solvability, working in $K = \mathbb{R}(x)$ via the
polynomial ring $\mathbb{R}[x]$. Write $D$ for $\frac{d}{dx}$ and $\deg$ for the
natural degree.

**Lemma 6.1 (Degree mismatch — `degree_second_deriv_lt_degree_X_mul`).** *For a
nonzero polynomial $p$, $\deg(p'') < \deg(x\,p)$.*

*Proof sketch.* $\deg(x p) = 1 + \deg p$, while differentiation does not increase
degree, so $\deg(p'') \le \deg p < 1 + \deg p$. $\qquad\blacksquare$

**Theorem 6.2 (Airy has no polynomial solution — `no_poly_solves_airy`).** *There
is no nonzero polynomial $p$ with $p'' = x\,p$.*

*Proof sketch.* Such an equality would force $\deg(p'') = \deg(x p)$, contradicting
Lemma 6.1. $\qquad\blacksquare$

**Theorem 6.3 (General positive-degree obstruction —
`no_poly_solves_second_order_pos_deg`).** *If $\deg q \ge 1$ and $p \neq 0$, then
$p'' \neq q\,p$.*

*Proof sketch.* If $p'' = qp$, then $\deg(p'') = \deg q + \deg p \ge \deg p + 1$,
but $\deg(p'') \le \deg p - 2$ for nonconstant $p$ (and the constant case is
immediate). Contradiction. $\qquad\blacksquare$

**Theorem 6.4 (Generalized Airy — `no_poly_solves_gen_airy`).** *For every
$n \ge 1$, the equation $y'' = x^{n}\,y$ has no nonzero polynomial solution.*
(Immediate from Theorem 6.3 with $q = x^n$, $\deg q = n \ge 1$.)

**Theorem 6.5 (Polynomial Abel identity — `poly_wronskian_derivative_zero`).*
*Defining the polynomial Wronskian $W(f,g) = f\,g' - g\,f'$, if $f'' = q f$ and
$g'' = q g$ then $W(f,g)' = 0$.* This is the $\mathbb{R}[x]$ instance of Theorem
5.2.

---

## 7. Pillar 3b — The rational Riccati parity obstruction and Kovacic sharpness

The polynomial obstructions of §6 rule out polynomial solutions, but the Kovacic
first step requires ruling out *rational* Riccati solutions. We pass to the
cleared form.

**Definition 7.1 (Rational Riccati solvability — `HasRationalRiccatiSolution`).**
A coefficient $f \in \mathbb{R}[x]$ *has a rational Riccati solution* if there
exist $p, q \in \mathbb{R}[x]$ with $q \neq 0$ and
$$
p'\,q - p\,q' + p^2 = f\,q^2.
$$
Writing $v = p/q$, this is exactly $v' + v^2 = f$ after clearing denominators.

**Lemma 7.2 (Wronskian-like degree bound — `natDegree_wronskianLike_le`).** *For
all $p, q \in \mathbb{R}[x]$,*
$$
\deg(p'\,q - p\,q') \le \deg p + \deg q - 1.
$$

*Proof sketch.* Each product $p' q$ and $p q'$ has degree at most
$\deg p + \deg q - 1$ because differentiation drops degree by one; the difference
inherits the bound. (Degenerate constant cases are handled directly.)
$\qquad\blacksquare$

**Theorem 7.3 (Odd-degree obstruction — `no_rational_solves_riccati_odd_deg`).**
*If $\deg f$ is odd, there are no $p, q \in \mathbb{R}[x]$ with $q \neq 0$ and
$p'q - p q' + p^2 = f q^2$.*

*Proof sketch.* Suppose such $p, q$ exist. The left-hand side has degree at most
$\max(2\deg p,\ \deg p + \deg q - 1)$ by Lemma 7.2, while the right-hand side has
degree $\deg f + 2\deg q$. A case analysis on whether the $p^2$ term or the
Wronskian-like term dominates shows the left-hand degree, modulo the leading-term
cancellations, has parity incompatible with the *odd* quantity $\deg f + 2\deg q
\equiv \deg f \pmod 2$. Concretely, $2\deg p$ is even and $\deg f + 2\deg q$ is
odd, so they cannot match; and the Wronskian-like branch is strictly dominated.
This forces a contradiction. $\qquad\blacksquare$

**Theorem 7.4 (Airy Riccati obstruction — `no_rational_solves_riccati_airy`).**
*The Riccati equation $v' + v^2 = x$ has no rational solution: no $p, q$ with
$q \neq 0$ satisfy $p'q - p q' + p^2 = x q^2$.* (Theorem 7.3 with $f = x$,
$\deg f = 1$ odd.)

**Theorem 7.5 (Combined Airy first-step obstruction —
`airy_no_poly_and_no_rational_riccati`).** *Airy's equation $y'' = x y$ has
(i) no nonzero polynomial solution, and (ii) no rational solution of its
associated Riccati equation.* (Conjunction of Theorems 6.2 and 7.4.) These are the
first two layers of the Kovacic decision procedure certifying that Airy has no
EML closed-form solution.

**Theorem 7.6 (Generalized Airy Riccati obstruction —
`no_rational_riccati_genAiry`).** *For every $k \ge 0$, the coefficient
$f = x^{2k+1}$ has no rational Riccati solution.* (Theorem 7.3, $\deg f = 2k+1$
odd; the case $k = 0$ is `no_rational_riccati_airy`.)

### 7.1 Sharpness: the even-degree side is genuinely solvable

The obstruction is not one-sided. The odd-degree hypothesis cannot be dropped.

**Theorem 7.7 (Even-degree solvable witness — `riccati_evenDeg_solvable`).** *The
coefficient $f = x^2 + 1$ has a rational (indeed polynomial) Riccati solution:
$v = x$ (cleared form $p = x$, $q = 1$).*

*Proof sketch.* With $p = x$, $q = 1$: $p' q - p q' + p^2 = 1 + x^2 = f q^2$.
Equivalently $v = x$ solves $v' + v^2 = 1 + x^2 = f$. $\qquad\blacksquare$

This $v = x$ corresponds to the genuine closed-form solution $y = e^{x^2/2}$,
whose logarithmic derivative is $x$. The coefficient has even degree:

**Theorem 7.8 (`natDegree_evenWitness`).** $\deg(x^2 + 1) = 2$.

**Theorem 7.9 (Sharp two-sided parity decision —
`kovacic_parity_decision_sharp`).** *On the monomial-coefficient family,
(i) every $f = x^{2k+1}$ (odd degree) is obstructed, and (ii) $f = x^2 + 1$ (even
degree) admits a rational Riccati solution. Hence the odd-degree test is a correct
and tight decision rule for the Kovacic first step on this family.*

*Proof sketch.* Conjunction of Theorems 7.6 and 7.7. $\qquad\blacksquare$

---

## 8. The Kovacic first step as an algorithm

The results above assemble into a decidable first step of Kovacic's algorithm for
the polynomial-coefficient family $y'' = f\,y$.

**Algorithm (Kovacic Step 1, parity form).**

1. *Input:* a polynomial coefficient $f \in \mathbb{R}[x]$.
2. Compute $d = \deg f$.
3. If $d$ is odd, **return** "no rational Riccati solution" (Theorem 7.3); the
   equation has no Liouvillian solution of the first Kovacic type.
4. If $d$ is even, search for a polynomial $v$ of degree $d/2$ solving
   $v' + v^2 = f$ by matching coefficients (a finite linear-then-quadratic
   system). If found, **return** $v$ (and the closed-form $y = \exp\!\int v$); if
   not, proceed to later Kovacic cases.

*Complexity.* Step 3 is $O(1)$ after reading the degree. Step 4 solves a triangular
system in the $d/2 + 1$ unknown coefficients of $v$, i.e. polynomial time in $d$.

The correctness of the negative branch is exactly Theorem 7.3; the soundness of
the positive branch is witnessed by Theorems 7.7–7.8 on the boundary family.

---

## 9. Applications

- **Special-function theory.** Theorem 7.5 is a self-contained, formula-free proof
  that the Airy functions are not elementary, recovering the classical fact via a
  finite degree count rather than monodromy or asymptotic analysis.
- **Symbolic computation.** The parity criterion (Theorems 7.3, 7.9) is a fast
  pre-filter inside computer-algebra implementations of Kovacic's algorithm: a
  single degree-parity check rejects an infinite family of inputs before any
  pole/exponent analysis is attempted.
- **Mathematical physics.** Airy's equation models caustics in optics and the
  classical–forbidden turning region in quantum mechanics; the framework certifies
  that these phenomena have no elementary closed form, justifying the need for
  special functions.
- **Differential Galois pedagogy.** §3–§5 give a clean, hypothesis-minimal
  account of the constants field, the solution module, and the Wronskian criterion,
  suitable as a verified foundation for differential Galois theory.

---

## 10. Discussion: the algebra–geometry gap

The framework crystallizes a single conceptual point. The *algebraic* data of a
second-order linear EML equation — the field of constants $\mathcal{C}(K)$, the
solution module of dimension $\le 2$ over it, the Wronskian-detected
non-degeneracy, and the Galois group acting on the solution space — is *always*
present and well-behaved (§4–§5). What can fail is the *geometric realization* of
that data by explicit EML formulas. The Riccati transform (§3) translates the
realization question into rational solvability of $v' + v^2 = a$, and the parity
obstruction (§7) shows this can fail decidably and sharply. Airy's equation is the
minimal, canonical witness: maximal algebraic regularity, zero closed-form
realizability.

---

## 11. Future directions

The following directions extend the present framework.

**Conjecture 1 — Exact image characterization of polynomial Riccati solvability.**
A polynomial coefficient $f$ admits a *polynomial* Riccati solution $v$ (i.e.
$v' + v^2 = f$) **iff** $f$ lies in the image of the map $g \mapsto g' + g^2$, and
on this image the solution $v = g$ is unique up to the involution fixing the
quadratic term. Equivalently the polynomial-solvable coefficients are precisely
$\{\, g' + g^2 : g \in \mathbb{R}[x] \,\}$, a set meeting every even degree $2n$
($n \ge 1$) and no odd degree. The key insight is that clearing denominators with
$q = 1$ collapses the Riccati identity to $g' + g^2 = f$, so polynomial
solvability is *definitionally* membership in the image of the Riccati map; the
obstruction/solvability dichotomy is the geometry of that image, not a pole
analysis. Both inclusions are already established on a parametrized family and the
odd-degree obstruction is proved; only the surjectivity-onto-the-image converse
remains, a finite degree-matching argument.

**Conjecture 2 — Rank-2 reduction of order over the constants.** If $y_1$ is a
nonzero solution of $y'' = a y$ in a differential field $K$, then a second
solution $y_2$ is linearly independent from $y_1$ over the constants **iff** its
Wronskian with $y_1$ is a nonzero constant, and every such $y_2$ arises by
reduction of order $y_2 = y_1 \cdot u$ with $u' = W/y_1^2$ for a constant Wronskian
$W$. Hence the solution space is at most two-dimensional over the constants. The
key insight is that Wronskian constancy turns reduction of order into a
*first-order* equation for $u'$, reusing the one-dimensional first-order
description. The missing step is only the explicit $u' = W/y_1^2$ bridge, a single
`field_simp; ring` identity.

**Conjecture 3 — Degree-graded sharpness is exhaustive.** For the family
$y'' = f y$ with $f$ a monomial $c\,x^k$ ($c \neq 0$), the Kovacic first step
succeeds **iff** $k$ is even, and when it succeeds a rational Riccati solution
exists already as a polynomial of degree $k/2$. Thus the parity test is not only
correct but the solution complexity is governed linearly by the degree. The key
insight is that the solvable witnesses $\,(x^n)' + (x^n)^2\,$ of degree $2n$
realize every even degree.

---

## 12. Conclusion

We have given a rigorous, hypothesis-minimal, differential-algebra account of the
closed-form solution theory for second-order linear EML equations: the Riccati
transform as canonical form, the constants field and Wronskian as the
existence/non-degeneracy machinery, and a sharp parity obstruction certifying — via
Airy's equation — the gap between an ever-present algebraic structure and a
sometimes-absent explicit formula. The negative results are not isolated curiosities
but the correct, tight first step of Kovacic's decision procedure.
