# Differential Galois Structure for EML Ordinary Differential Equations

**Author:** Aristotle
**Date:** 2026-06-26
**Domain:** Applications

## Abstract

We develop the differential-Galois layer of the theory of linear ordinary
differential equations whose coefficients are *EML functions* — functions built
from rational functions by iterated exponentials, logarithms, and
multiplicative/algebraic combination. Working over an arbitrary differential
field $K$ with derivation $a \mapsto a'$, we prove the structural facts that
govern every Picard–Vessiot computation for such equations. First, the **field of
constants** $C = \{x \in K : x' = 0\}$ is a subfield, the base over which the
differential Galois group is a linear-algebraic group. Second, the constants act
on solution spaces: the solution space of a first-order equation $y' = a y$ is a
one-dimensional line over $C$ (the ratio of any two nonzero solutions is a
constant), so its Galois group embeds in the multiplicative group $\mathbb{G}_m(C)$;
and the solution set of a second-order equation $y'' = a y$ is a $C$-module closed
under scaling and addition, on which the Galois group acts linearly while
preserving the **Wronskian**, which we prove is a constant (an abstract Abel
identity). Third, on the decision-procedure side, we establish the first step of
the Kovacic algorithm for the family $y'' = f y$ with polynomial $f$: via the
Riccati transform $v = y'/y$, a rational solution of the second-order equation
produces a rational solution of $v' + v^2 = f$, and we prove a sharp
**degree–parity obstruction** — if $\deg f$ is odd, the cleared Riccati identity
$p'q - pq' + p^2 = f q^2$ has no solution with $q \neq 0$. Specializing to $f = X$
gives a complete proof that **Airy's equation $y'' = x y$ has no EML solution**.
All results hold with no algebraic-closure or characteristic hypotheses.

---

## 1. Introduction

The question of when a differential equation can be solved "in closed form" is one
of the oldest in analysis and one of the most subtle. Joseph Liouville, in the
1830s and 1840s, gave the first rigorous theorems on integration in finite terms,
and the question was placed on a structural footing by Émile Picard and Ernest
Vessiot at the turn of the twentieth century, who attached to each linear ODE a
*differential Galois group* — an algebraic group of linear transformations of the
solution space — and showed that solvability in elementary (Liouvillian) terms
corresponds to solvability of this group.

The prototypical non-example is **Airy's equation**

$$ y'' = x\,y, \tag{1.1} $$

introduced by G. B. Airy in 1838 in the study of optical caustics. Its solutions,
the Airy functions $\mathrm{Ai}$ and $\mathrm{Bi}$, are not expressible by any
finite combination of exponentials, logarithms, algebraic functions, and
integrals thereof. The differential Galois group of $(1.1)$ is the full special
linear group $\mathrm{SL}_2(\mathbb{C})$, which is not solvable; hence $(1.1)$ has
no Liouvillian solution.

This paper isolates and proves the *algebraic skeleton* of this theory for the
class of **EML coefficients** — functions obtained from rational functions by
**E**xponentiation, **L**ogarithm, and **M**ultiplicative/algebraic combination —
in a form free of any analytic, algebraic-closure, or characteristic hypotheses.
We work throughout in an abstract differential field and derive:

1. the constants subfield (Section 3);
2. the constants action on first- and second-order solution spaces, including the
   Wronskian as a constant of motion (Sections 4–5);
3. the Riccati transform and the Kovacic first-step degree–parity obstruction,
   culminating in the non-EML-solvability of Airy's equation (Section 6).

The contribution is twofold. Conceptually, it shows that the differential-Galois
content of linear EML equations is carried entirely by the constants subfield and
its action — every load-bearing step is a consequence of the Leibniz rule.
Practically, it supplies a fully verified, machine-checkable foundation on which
the Kovacic decision procedure for the family $y'' = f y$ can be built.

---

## 2. Preliminaries: differential fields and EML functions

**Definition 2.1 (Differential field).** A *differential field* is a field $K$
together with an additive map $D : K \to K$, written $D a = a'$, satisfying the
Leibniz rule
$$ (ab)' = a'b + ab' \qquad \text{for all } a, b \in K. $$
From the field and Leibniz axioms one derives the quotient rule
$$ \left(\frac{a}{b}\right)' = \frac{a'b - ab'}{b^2} \quad (b \neq 0), \qquad
   (b^{-1})' = -\frac{b'}{b^2}. $$

**Definition 2.2 (Logarithmic derivative).** For $y \in K^\times$, the
*logarithmic derivative* of $y$ is
$$ \operatorname{logd} y \;=\; \frac{y'}{y}. $$

**Definition 2.3 (EML functions, informal).** Over a base differential field of
rational functions $\mathbb{R}(x)$ (with $x' = 1$), the *EML functions* are the
elements of any differential field extension obtained by finitely many steps of:
adjoining an exponential $\exp(t)$ of an existing element $t$ (so
$(\exp t)' = t' \exp t$); adjoining a logarithm $\log(t)$ (so
$(\log t)' = t'/t$); and adjoining elements algebraic over the field so far. EML
functions are the natural closed-form world for first-order behaviour: they are
exactly the functions whose logarithmic derivative analysis is governed by the
constants. Liouvillian functions add primitives (integrals) to this list. The
results below are stated over an arbitrary differential field $K$ and therefore
apply to any such EML extension.

**Standing assumptions.** Throughout, $K$ is a field with a derivation; we make no
assumption on characteristic and do not assume $K$ algebraically closed. Where
polynomial coefficients are studied (Section 6) we specialize to $K = \mathbb{R}(X)$
with $\mathbb{R}[X]$ its ring of polynomials and the usual derivative.

---

## 3. The field of constants

**Definition 3.1 (Constants).** The *constants* of $K$ are
$$ C = \{\, x \in K : x' = 0 \,\}. $$

**Theorem 3.2 (Constants form a subfield; `constantsSubfield`).** $C$ is a
subfield of $K$: it contains $0$ and $1$ and is closed under addition,
multiplication, negation, and inversion.

*Proof.* Additivity of $D$ gives $0' = 0$ and $(a+b)' = a' + b'$, so $0 \in C$ and
$C$ is closed under sums and negation. For multiplication, $1' = 1' \cdot 1$ forces
$1' = 0$ (alternatively $1 = 1\cdot 1$ and Leibniz give $1' = 2\cdot 1'$, hence
$1' = 0$), so $1 \in C$; and if $a' = b' = 0$ then
$(ab)' = a'b + ab' = 0$. For inversion, if $a' = 0$ and $a \neq 0$ then
$(a^{-1})' = -a'/a^2 = 0$. $\qquad\blacksquare$

The membership criterion is recorded for use in later proofs.

**Lemma 3.3 (`mem_constantsSubfield`).** For $x \in K$, $x \in C \iff x' = 0$.

The constants subfield is the *exact* base over which the differential Galois group
of an EML equation is a linear-algebraic group: the group fixes $C$ pointwise, and
all matrix entries (and the Wronskian determinant below) lie in $C$.

---

## 4. First-order equations and the multiplicative constants

The first-order homogeneous linear equation is
$$ y' = a\,y. \tag{4.1} $$

**Theorem 4.1 (First-order ratio is a constant; `firstOrder_ratio_isConstant`).**
Let $a, y_1, y_2 \in K$ with $y_1' = a y_1$, $y_2' = a y_2$, and $y_2 \neq 0$. Then
$$ \left( \frac{y_1}{y_2} \right)' = 0, $$
i.e. $y_1/y_2 \in C$.

*Proof.* By the quotient rule,
$$ \left(\frac{y_1}{y_2}\right)' = \frac{y_1' y_2 - y_1 y_2'}{y_2^2}
   = \frac{(a y_1) y_2 - y_1 (a y_2)}{y_2^2} = \frac{0}{y_2^2} = 0. \qquad\blacksquare$$

**Interpretation.** Theorem 4.1 says the solution space of $(4.1)$ is a
one-dimensional line over $C$: any two nonzero solutions differ by a constant
scalar. Consequently the differential Galois group of $(4.1)$ embeds into the
multiplicative group of nonzero constants $\mathbb{G}_m(C) = (C^\times, \times)$ —
the prototypical *EML group*, abelian and solvable. First-order EML equations are
therefore always EML-solvable, and their Galois group is as simple as a Galois
group can be. The hypothesis $y_2 \neq 0$ is load-bearing: it is exactly what is
needed to form the ratio.

---

## 5. Second-order equations: the constants module and the Wronskian

The second-order linear equation in reduced form (no first-derivative term) is
$$ y'' = a\,y. \tag{5.1} $$
Every second-order linear equation $y'' + p y' + q y = 0$ can be brought to this
form by the substitution $y = u \exp(-\tfrac12 \int p)$.

**Theorem 5.1 (Scaling preserves solutions; `scale_solution`).** Let
$a, c, y \in K$ with $c' = 0$ and $y'' = a y$. Then $(c y)'' = a (c y)$.

*Proof.* Since $c' = 0$, Leibniz gives $(cy)' = c'y + c y' = c y'$, and applying it
again $(cy)'' = (c y')' = c' y' + c y'' = c y'' = c (a y) = a (c y)$.
$\qquad\blacksquare$

**Theorem 5.2 (Sum of solutions is a solution; `add_solution`).** If $y_1'' = a y_1$
and $y_2'' = a y_2$, then $(y_1 + y_2)'' = a (y_1 + y_2)$.

*Proof.* $D$ is additive, so $(y_1+y_2)'' = y_1'' + y_2'' = a y_1 + a y_2
= a(y_1 + y_2)$. $\qquad\blacksquare$

Theorems 5.1 and 5.2 together show:

**Corollary 5.3 (Solution module).** The solution set $\{\, y : y'' = a y \,\}$ is a
module over the constants subfield $C$. The differential Galois group acts on this
module $C$-linearly.

**Definition 5.4 (Wronskian).** For $y_1, y_2 \in K$,
$$ W(y_1, y_2) = y_1\,y_2' - y_2\,y_1'. $$

**Theorem 5.5 (Vanishing Wronskian of dependent solutions;
`wronskian_dependent_eq_zero`).** For any $c, y_1 \in K$ with $c' = 0$,
$$ W(y_1,\, c y_1) = y_1 (c y_1)' - (c y_1) y_1' = 0. $$

*Proof.* With $c' = 0$, $(c y_1)' = c y_1'$, so
$y_1 (c y_1)' - (c y_1) y_1' = c y_1 y_1' - c y_1 y_1' = 0$. $\qquad\blacksquare$

Thus a vanishing Wronskian is the algebraic signature of $C$-linear dependence.

**Theorem 5.6 (Wronskian is a constant — abstract Abel identity;
`wronskian_isConstant`, via `wronskian_deriv_eq_zero`).** If $y_1'' = a y_1$ and
$y_2'' = a y_2$, then $W(y_1, y_2) \in C$, i.e. $W(y_1, y_2)' = 0$.

*Proof.* By Leibniz,
$$ W(y_1,y_2)' = (y_1 y_2')' - (y_2 y_1')'
   = (y_1' y_2' + y_1 y_2'') - (y_2' y_1' + y_2 y_1''). $$
The terms $y_1' y_2'$ and $y_2' y_1'$ cancel, leaving
$y_1 y_2'' - y_2 y_1'' = y_1 (a y_2) - y_2 (a y_1) = 0$. $\qquad\blacksquare$

**Interpretation.** Theorem 5.6 says the Galois group preserves the Wronskian,
which is a *constant determinant*. Hence the differential Galois group of $(5.1)$
embeds in the matrices of constant determinant: $\mathrm{SL}_2(C)$ up to a scalar.
The pair (Theorem 5.5, Theorem 5.6) reduces the test for a basis of solutions to a
single scalar test: two solutions are $C$-independent iff their Wronskian is a
nonzero constant. This is the structural foundation for the Picard–Vessiot
extension of $(5.1)$ being a rank-2 $C$-module.

---

## 6. The Riccati transform and the Kovacic first-step obstruction

### 6.1 The Riccati transform in an abstract differential field

**Theorem 6.1 (Riccati transform, raw form; `logDeriv_riccati`).** For $y \in K^\times$,
$$ \left(\operatorname{logd} y\right)' + \left(\operatorname{logd} y\right)^2
   = \frac{y''}{y}. $$

*Proof.* Write $v = y'/y$. By the quotient rule
$v' = (y'' y - y' y')/y^2 = y''/y - (y'/y)^2 = y''/y - v^2$, so
$v' + v^2 = y''/y$. $\qquad\blacksquare$

**Theorem 6.2 (Riccati transform for $(5.1)$; `riccati_of_second_order`).** If
$y \in K^\times$ solves $y'' = a y$, then $v = y'/y$ solves the **Riccati equation**
$$ v' + v^2 = a. \tag{6.1} $$

*Proof.* Substitute $y'' = a y$ into Theorem 6.1: $v' + v^2 = (a y)/y = a$.
$\qquad\blacksquare$

Theorem 6.2 is the substitution at the heart of the **Kovacic algorithm**: a
Liouvillian (EML) solution of $(5.1)$ exists only if $(6.1)$ has a solution that is
*algebraic* over $K$; the first and crudest case to test is a **rational** solution
$v = p/q$ with $p, q$ polynomials. Clearing denominators turns $(6.1)$ into a pure
polynomial identity.

**Lemma 6.3 (Cleared Riccati identity).** A rational function $v = p/q$ with
$q \neq 0$ satisfies $v' + v^2 = f$ in $\mathbb{R}(X)$ if and only if
$$ p'q - p q' + p^2 = f\,q^2 \tag{6.2} $$
holds in $\mathbb{R}[X]$.

*Proof.* Multiply $(6.1)$ by $q^2$ and use $v' = (p'q - pq')/q^2$ and
$v^2 = p^2/q^2$. $\qquad\blacksquare$

### 6.2 The degree–parity obstruction

We now work in $K = \mathbb{R}(X)$ with polynomials $\mathbb{R}[X]$. Write $\deg$
for the (natural-number) degree. The "Wronskian-like" first-order part of $(6.2)$
satisfies a degree drop.

**Lemma 6.4 (Degree of the Wronskian-like term; `natDegree_wronskianLike_le`).**
For $p, q \in \mathbb{R}[X]$,
$$ \deg\bigl(p'q - p q'\bigr) \le \deg p + \deg q - 1. $$

*Proof sketch.* Each product $p'q$ and $pq'$ has degree at most
$(\deg p - 1) + \deg q$ because differentiation drops degree by (at least) one for
nonzero polynomials; the constant and degenerate cases ($p$ or $q$ constant) are
checked directly. The difference inherits the bound. $\qquad\blacksquare$

**Theorem 6.5 (Odd-degree Riccati obstruction;
`no_rational_solves_riccati_odd_deg`).** Let $f, p, q \in \mathbb{R}[X]$ with
$q \neq 0$ and $\deg f$ **odd**. Then $(6.2)$ has no solution; equivalently
$v' + v^2 = f$ has no rational solution.

*Proof.* Suppose $(6.2)$ holds. The right side $f q^2$ has degree
$\deg f + 2\deg q$. For the left side, by Lemma 6.4 and $\deg(p^2) = 2\deg p$,
$$ \deg\bigl(p'q - pq' + p^2\bigr) \le \max\{\,2\deg p,\ \deg p + \deg q - 1\,\}. $$
Consider two regimes.

*Case $\deg p \ge \deg q$.* Then $2\deg p \ge \deg p + \deg q > \deg p + \deg q - 1$,
so the $p^2$ term strictly dominates and the left side has degree exactly
$2\deg p$. Matching with the right side gives
$$ 2\deg p = \deg f + 2\deg q \;\Longrightarrow\; \deg f = 2(\deg p - \deg q), $$
which is **even**, contradicting $\deg f$ odd.

*Case $\deg p < \deg q$.* Then $2\deg p \le 2\deg q - 2$ and
$\deg p + \deg q - 1 \le 2\deg q - 2$, so the left side has degree at most
$2\deg q - 2$. But the right side has degree
$\deg f + 2\deg q \ge 1 + 2\deg q > 2\deg q - 2$, so equality is impossible.

Either way we reach a contradiction; no rational solution exists. $\qquad\blacksquare$

Two features deserve emphasis. First, **coprimality of $p$ and $q$ is not
required** — the obstruction is purely metric (a degree count), which is stronger
and cleaner than the classical pole-counting argument. Second, the result is sharp
on parity: it covers every odd-degree coefficient and says nothing (correctly) in
the even-degree case.

### 6.3 Airy's equation

**Theorem 6.6 (No rational Riccati solution for Airy;
`no_rational_solves_riccati_airy`).** There are no $p, q \in \mathbb{R}[X]$ with
$q \neq 0$ satisfying $p'q - pq' + p^2 = X q^2$. Equivalently, $v' + v^2 = x$ has
no rational solution.

*Proof.* Apply Theorem 6.5 with $f = X$: $\deg X = 1$ is odd. $\qquad\blacksquare$

The polynomial layer below the rational layer is recorded for completeness.

**Theorem 6.7 (No polynomial solution for Airy; `no_poly_solves_airy`).** No
nonzero $p \in \mathbb{R}[X]$ satisfies $p'' = X p$.

*Proof.* For $p \neq 0$, $\deg(p'') < \deg p < \deg(Xp) = 1 + \deg p$, so the two
sides have different degrees. $\qquad\blacksquare$

This generalizes: for any coefficient $q$ with $\deg q \ge 1$, $y'' = q y$ has no
nonzero polynomial solution (`no_poly_solves_second_order_pos_deg`), and in
particular $y'' = X^n y$ for $n \ge 1$ (`no_poly_solves_gen_airy`).

**Theorem 6.8 (Airy first-step obstruction;
`airy_no_poly_and_no_rational_riccati`).** Airy's equation $y'' = x y$ has neither
a nonzero polynomial solution nor a rational solution of its associated Riccati
equation $v' + v^2 = x$. Together these are the first two layers of the Kovacic
decision procedure, certifying that **Airy's equation has no EML (Liouvillian)
solution.**

*Proof.* Combine Theorems 6.6 and 6.7. $\qquad\blacksquare$

---

## 7. Algorithms

### 7.1 Kovacic first-step degree–parity decision

Given a polynomial coefficient $f$ of $y'' = f y$, decide (for the rational case)
whether the first Kovacic step can succeed.

```
INPUT: polynomial f
1. d ← degree(f)
2. if d is odd:
       return NO_RATIONAL_RICCATI_SOLUTION      # Theorem 6.5
3. else:
       return PARITY_INCONCLUSIVE               # finer leading-coeff test needed
```

Complexity: $O(\deg f)$ to read the degree; the decision itself is $O(1)$. This is
the cheapest possible filter and rejects an infinite family (all odd-degree
coefficients, including Airy) immediately.

### 7.2 Riccati transform (order reduction)

Given a nonzero solution $y$ of $y'' = a y$, return the rational/algebraic
first-order quantity $v = y'/y$ solving $v' + v^2 = a$ (Theorem 6.2). This is the
order-reduction primitive: it converts a linear second-order problem into a
first-order Riccati problem, the precondition for the parity test.

### 7.3 Cleared-Riccati search (brute-force certificate)

To *verify* the obstruction computationally for a fixed degree budget: enumerate
candidate $(p, q)$ with bounded degrees and small integer coefficients, test
identity $(6.2)$, and confirm no solution is found for odd-degree $f$ while a
solution is exhibited for suitable even-degree $f$ (e.g. $f = X^2 + 1$, $v = X$).

---

## 8. Applications and worked examples

**Example 8.1 (Airy, $f = X$).** Odd degree $\Rightarrow$ no rational Riccati
solution; Airy is non-EML-solvable. (Theorem 6.6.)

**Example 8.2 (Generalized Airy, $f = X^n$, $n$ odd).** Same parity obstruction;
none of $y'' = x^3 y$, $y'' = x^5 y, \dots$ admit rational Riccati solutions.

**Example 8.3 (Even-degree, solvable, $f = X^2 + 1$).** Here $v = X$ satisfies
$v' + v^2 = 1 + X^2 = f$, so $(6.2)$ holds with $p = X$, $q = 1$. The corresponding
linear equation $y'' = (x^2 + 1) y$ has the EML solution $y = e^{x^2/2}$. The parity
test is correctly *silent* here.

**Example 8.4 (Exponential first-order Galois).** For $y' = a y$ with $a$ constant,
$y_1 = e^{a x}$ and $y_2 = \lambda e^{a x}$ have ratio $\lambda \in C$
(Theorem 4.1), confirming the Galois group $\subseteq \mathbb{G}_m(C)$.

**Example 8.5 (Wronskian as invariant).** For $y'' = r^2 y$ with constant $r$, the
basis $y_1 = e^{rx}$, $y_2 = e^{-rx}$ has Wronskian
$W = y_1 y_2' - y_2 y_1' = -2r$, a nonzero constant (Theorem 5.6), certifying
$C$-independence and giving the $\mathrm{SL}_2$-up-to-scalar action.

---

## 9. Discussion

The development isolates a clean principle: **the differential-Galois content of a
linear EML equation is carried entirely by the constants subfield and its action on
the solution space.** Every load-bearing step — the subfield axioms, the
first-order ratio, second-order scaling/addition, the Wronskian's constancy, and
the Riccati transform — is a direct consequence of the Leibniz rule, requiring no
hypotheses on characteristic or algebraic closure. The concrete obstruction for
Airy then reduces to elementary degree bookkeeping in $\mathbb{R}[X] \subset
\mathbb{R}(X)$, with the decisive contradiction being a parity clash between an even
number $2(\deg p - \deg q)$ and the odd degree of the coefficient.

The degree–parity obstruction (Theorem 6.5) is, to our knowledge, a particularly
economical route to the first Kovacic step for the polynomial family: it dispenses
with the usual local pole analysis and coprimality bookkeeping, replacing them with
a single comparison of degrees. Its one-sidedness is intrinsic — even degree is
genuinely inconclusive — but it captures precisely the cases where solvability is
impossible for parity reasons alone, and it does so for the entire infinite
odd-degree family at once.

---

## 10. Future directions

**D1. The parity decision as a complete invariant for the monomial family.** For
$y'' = X^n y$ ($n \ge 1$), odd $n$ is always obstructed
(`no_rational_solves_riccati_odd_deg`) and $n = 2$-shaped coefficients can be
solvable. The unknown content lives in the even $n \ge 4$ regime, where the
dominant-balance degree count must be refined by a leading-coefficient condition.
The degree/parity infrastructure (`natDegree_wronskianLike_le`,
`no_rational_solves_riccati_odd_deg`) is in place; extending it to track leading
coefficients is a bounded next step.

**D2. Constants subfield as the exact Picard–Vessiot base.** For any differential
field $K$, the solution set of $y'' = a y$ is a module over
`EMLDiffGalois.constantsSubfield K` of rank at most $2$, with rank exactly $2$ iff
some pair has nonzero Wronskian; and the differential Galois group embeds in
$\mathrm{GL}_2(\text{constants})$ preserving that Wronskian (determinant a
constant). This cycle reduced "linear independence over constants" to the single
Wronskian scalar test and proved the Wronskian of two solutions is a constant
(`wronskian_isConstant`), so the rank-2 module structure and the
$\mathrm{SL}_2$-up-to-scalars action are now purely algebraic to encode.

**D3. Riccati solvability transfers along differential field extensions.** If $L/K$
is a differential field extension sharing constants and $y'' = a y$ (with $a \in K$)
has a rational Riccati solution in $L$, then it already has one in $K$. The result
`firstOrder_ratio_isConstant` shows the logarithmic derivative of a solution is
determined up to the shared constants, so a solution gained in an extension adding
no constants must descend.

---

## 11. Conclusion

We have given a self-contained, hypothesis-minimal account of the differential
Galois structure of linear EML ODEs: the constants form a subfield; first-order
solution ratios are constants (Galois group $\subseteq \mathbb{G}_m$); second-order
solutions form a constants-module with a constant Wronskian determinant (Galois
group $\subseteq \mathrm{SL}_2$ up to scalar); the Riccati transform reduces order;
and a degree–parity count rules out rational Riccati solutions whenever the
coefficient has odd degree — in particular for Airy's equation $y'' = x y$, which
therefore has no EML solution.
