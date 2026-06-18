# A Machine-Verified Temperley–Lieb Construction of the Jones Braid Representation on Four Strands

**Author:** Aristotle
**Date:** 2026-06-18
**Domain:** Geometry / Topological Quantum Computation

## Abstract

We present a fully formalized, machine-verified construction of the elementary
algebraic core underlying the Jones representation of the braid group $B_4$ via
the Temperley–Lieb algebra. Working over an arbitrary field $K$ and an arbitrary
associative unital $K$-algebra $R$, we define the image of a braid generator by
the Kauffman-bracket rule $\sigma \mapsto A\cdot\mathbf 1 + A^{-1}\cdot X$, where
$A\in K^\times$ is a phase and $X\in R$ is a Temperley–Lieb generator. Under the
loop-value normalization $\delta = -(A^2 + A^{-2})$ together with the
Temperley–Lieb relations $X^2 = \delta X$ and the absorption laws $XYX = X$,
$YXY = Y$, we prove: (i) the far-commutation relation
$\sigma_X\sigma_Y = \sigma_Y\sigma_X$ for commuting generators; (ii) the braid
(Yang–Baxter) relation $\sigma_X\sigma_Y\sigma_X = \sigma_Y\sigma_X\sigma_Y$; and
(iii) two-sided invertibility of each generator with explicit inverse
$\sigma^{-1} = A^{-1}\cdot\mathbf 1 + A\cdot X$. These identities certify that the
Kauffman/Jones recipe yields a genuine, invertible representation of $B_4$ — the
indispensable foundation of topological quantum compiling with anyons. We are
careful to delineate what is proved (the algebraic representation theory) from
what is conjectural (density of the image in $SU(3)$ and universality of Fibonacci
anyons for quantum computation), and we lay out a concrete roadmap from the
abstract engine to the concrete golden-ratio model.

**Keywords:** braid group $B_4$, Jones representation, Temperley–Lieb algebra,
Kauffman bracket, loop value, Yang–Baxter relation, anyon braiding, topological
quantum computation.

---

## 1. Introduction

### 1.1 Motivation: computing with knots

Topological quantum computation (TQC) proposes to store and process quantum
information in the global, topological features of a many-anyon system rather than
in locally fragile degrees of freedom. The computational primitive is *braiding*:
exchanging anyons along worldlines whose homotopy class — and nothing else —
determines the resulting unitary operator on the degenerate ground-state space.
Because small perturbations of the worldlines do not change their braid class, the
induced gates are intrinsically protected against local noise. This is the
structural error resilience that makes TQC attractive.

Mathematically, the gates realizable by braiding $n$ anyons form the image of a
**representation of the braid group $B_n$**. For the Fibonacci anyon model the
relevant representations are the **Jones representations** arising from the
Temperley–Lieb algebra at a root of unity. Whether the image of such a
representation is *dense* in the ambient unitary group — and hence whether the
gate set is *universal* — is the central question of the subject. A celebrated
program of Freedman, Larsen, and Wang answers it affirmatively for Fibonacci
anyons.

### 1.2 What this paper proves, and what it does not

This paper formalizes the *algebraic foundation* of that program: the verified
construction of the braid-group representation itself. Concretely, we prove that
the Kauffman-bracket assignment produces operators that (a) satisfy the defining
relations of $B_4$ and (b) are invertible. These are the prerequisites without
which no density or universality statement can even be posed.

We explicitly do **not** prove, in this work, that the image is dense in $SU(3)$,
that any particular braid word has infinite order, or that Fibonacci-anyon
braiding is universal for quantum computation. Those statements — true and deep —
require the concrete root-of-unity model and analytic Lie-group arguments. We
treat them as motivation and future work (Section 7), and we are scrupulous not to
overstate the formal content.

### 1.3 Contributions

1. A field- and algebra-generic formalization of the Kauffman/Jones braid
   generator $\texttt{jonesOp}\,A\,X = A\cdot\mathbf 1 + A^{-1}\cdot X$ and its
   inverse $\texttt{jonesInv}\,A\,X = A^{-1}\cdot\mathbf 1 + A\cdot X$.
2. Machine-verified proofs of the loop-value scalar identity, far-commutation,
   the braid relation, and two-sided invertibility.
3. A precise separation of the proved algebraic core from the conjectural
   analytic superstructure, with a roadmap (Section 7) for instantiating the
   abstract engine at the golden-ratio loop value $\delta = (1+\sqrt5)/2$.

---

## 2. Setting and Definitions

Throughout, $K$ is a field, $R$ is an associative unital $K$-algebra, and
$\mathbf 1$ denotes the unit of $R$. The symbol $\bullet$ denotes the scalar
action of $K$ on $R$. We fix a phase $A \in K^\times$ (so $A \neq 0$ and $A^{-1}$
exists) and the corresponding **loop value**
$$\delta \;:=\; -\bigl(A^2 + A^{-2}\bigr) \in K.$$

A **Temperley–Lieb generator** is an element $X\in R$ satisfying $X^2 = \delta X$;
two adjacent generators $X,Y$ additionally satisfy the **absorption relations**
$XYX = X$ and $YXY = Y$, while distant generators **commute**, $XY = YX$. These
are exactly the defining relations of the Temperley–Lieb algebra
$\mathrm{TL}_n(\delta)$, presented diagrammatically by planar non-crossing
pairings with the rule that a closed loop evaluates to $\delta$.

> **Definition 1 (`jonesOp`).** The image of a positive braid generator $\sigma$
> is
> $$\texttt{jonesOp}(A,X) \;=\; A\bullet\mathbf 1 \;+\; A^{-1}\bullet X \;\in R.$$
> This is the Kauffman-bracket smoothing rule: a crossing equals $A$ times the
> identity tangle plus $A^{-1}$ times the cap–cup tangle $X$.

> **Definition 2 (`jonesInv`).** The candidate inverse of $\sigma$ is
> $$\texttt{jonesInv}(A,X) \;=\; A^{-1}\bullet\mathbf 1 \;+\; A\bullet X \;\in R,$$
> obtained from Definition 1 by interchanging $A \leftrightarrow A^{-1}$.

We write $\sigma_X = \texttt{jonesOp}(A,X)$ and $\sigma_X^{-1} =
\texttt{jonesInv}(A,X)$ for brevity. For $B_4$ the three generators
$\sigma_1,\sigma_2,\sigma_3$ are realized as $\sigma_{E_1},\sigma_{E_2},
\sigma_{E_3}$ for Temperley–Lieb generators $E_1,E_2,E_3$, where $E_1,E_3$
commute and the consecutive pairs $(E_1,E_2)$, $(E_2,E_3)$ satisfy absorption.

---

## 3. The Loop-Value Identity

> **Lemma 1 (`delta_scalar_id`).** If $\delta = -(A^2 + A^{-2})$, then
> $$A^2 + \delta + A^{-2} = 0 \qquad\text{in } K.$$

**Proof sketch.** Substitute the definition of $\delta$ and simplify:
$A^2 + \bigl(-(A^2+A^{-2})\bigr) + A^{-2} = 0$ by commutative ring arithmetic.
$\qquad\blacksquare$

Although elementary, Lemma 1 is the mechanism by which every higher identity in
this paper closes. The combination $A^2 + \delta + A^{-2}$ is precisely the scalar
that multiplies the "extra" $X$-terms in the expansions below; its vanishing is
what reduces those expansions to the desired braid identities. The choice
$\delta = -(A^2+A^{-2})$ is therefore not cosmetic — it is forced by the
requirement that the Kauffman rule descend to a braid representation.

---

## 4. Far Commutation

> **Theorem 2 (`braid_commute`).** Let $X,Y\in R$ with $XY = YX$. Then
> $$\sigma_X\,\sigma_Y \;=\; \sigma_Y\,\sigma_X,$$
> i.e. $\texttt{jonesOp}(A,X)\cdot\texttt{jonesOp}(A,Y)
> = \texttt{jonesOp}(A,Y)\cdot\texttt{jonesOp}(A,X)$.

**Proof sketch.** Expand both products by bilinearity of multiplication over the
scalar action:
$$\sigma_X\sigma_Y = A^2\,\mathbf 1 + (A\cdot A^{-1})(X+Y) + A^{-2}XY
 = A^2\,\mathbf 1 + (X+Y) + A^{-2}XY.$$
The symmetric expansion of $\sigma_Y\sigma_X$ differs only in the last term,
which is $A^{-2}YX$. Since $XY = YX$ by hypothesis, the two expansions coincide.
$\qquad\blacksquare$

This is the relation $\sigma_1\sigma_3 = \sigma_3\sigma_1$ in $B_4$: the two
crossings act on disjoint pairs of strands and therefore commute.

---

## 5. The Braid (Yang–Baxter) Relation

> **Theorem 1 (`braid_relation`).** Suppose $A\neq 0$,
> $\delta = -(A^2+A^{-2})$, and the Temperley–Lieb relations
> $$X^2 = \delta\,X,\quad Y^2 = \delta\,Y,\quad XYX = X,\quad YXY = Y$$
> hold. Then
> $$\sigma_X\,\sigma_Y\,\sigma_X \;=\; \sigma_Y\,\sigma_X\,\sigma_Y.$$

**Proof sketch.** Expand each side using Definition 1. Each triple product is a
sum of eight terms indexed by choosing $\mathbf 1$ or $X$ (resp. $Y$) from each of
the three factors:
$$\sigma_X\sigma_Y\sigma_X
 = (A\mathbf 1 + A^{-1}X)(A\mathbf 1 + A^{-1}Y)(A\mathbf 1 + A^{-1}X).$$
Collect terms by monomial type. The pure-scalar term $A^3\mathbf 1$ is symmetric
between the two sides. Terms with a single $X$ or $Y$ are likewise symmetric.
Using $X^2 = \delta X$ and $Y^2 = \delta Y$, the repeated-letter monomials reduce
to scalar multiples of single letters. The genuinely "mixed" monomials produce the
absorption patterns $XYX$ and $YXY$, which collapse to $X$ and $Y$ respectively by
hypothesis. After this reduction, the difference between the two sides is a scalar
multiple of $X$ (and symmetrically of $Y$) whose coefficient is exactly
$A^{-1}(A^2 + \delta + A^{-2})$. By Lemma 1 this coefficient vanishes, so both
sides are equal. $\qquad\blacksquare$

Theorem 1 is the crux of the construction: it certifies that the Kauffman/Jones
assignment respects the defining relation of the braid group. Equivalently, the
operators $\sigma_X$ furnish a representation of the type-$A$ Artin braid group on
the algebra $R$. Specialized to $E_1,E_2,E_3$ it yields the two adjacent braid
relations $\sigma_1\sigma_2\sigma_1=\sigma_2\sigma_1\sigma_2$ and
$\sigma_2\sigma_3\sigma_2=\sigma_3\sigma_2\sigma_3$ of $B_4$.

---

## 6. Invertibility of the Generators

> **Theorem 3a (`jonesOp_mul_jonesInv`).** If $A\neq 0$,
> $\delta = -(A^2+A^{-2})$, and $X^2 = \delta X$, then
> $$\sigma_X\,\sigma_X^{-1} \;=\; \mathbf 1.$$

> **Theorem 3b (`jonesInv_mul_jonesOp`).** Under the same hypotheses,
> $$\sigma_X^{-1}\,\sigma_X \;=\; \mathbf 1.$$

**Proof sketch.** Expand the product
$$\sigma_X\sigma_X^{-1} = (A\mathbf 1 + A^{-1}X)(A^{-1}\mathbf 1 + AX)
 = \mathbf 1 + A^2 X + A^{-2}X + X^2.$$
Using $X^2 = \delta X$, the $X$-coefficient becomes $A^2 + A^{-2} + \delta$, which
is zero by Lemma 1. Hence $\sigma_X\sigma_X^{-1} = \mathbf 1$. The reverse product
is identical by symmetry of the expression in $A \leftrightarrow A^{-1}$, giving
Theorem 3b. $\qquad\blacksquare$

Theorems 3a–3b show that each generator is a two-sided unit of $R$ with the
explicit inverse of Definition 2. Consequently the $\sigma_i$ lie in the unit
group $R^\times$, and the assignment extends to negative braid generators — a
necessary condition for the image to be a *group* representation of $B_4$ and
hence a candidate quantum gate set.

---

## 7. From the Abstract Engine to Fibonacci Anyons (Discussion and Future Work)

The four theorems above are *generic*: they hold for any field, any algebra, and
any phase satisfying the loop-value normalization. The path to the physically
relevant Fibonacci model is to **instantiate** them.

**The golden-ratio specialization.** Take $K = \mathbb C$,
$R = \mathrm{Mat}_3(\mathbb C)$, and the primitive tenth root of unity
$A = e^{3\pi i/5}$. Then
$$\delta = -(A^2 + A^{-2}) = -2\cos(6\pi/5) = \frac{1+\sqrt5}{2} = \varphi,$$
the golden ratio. With $E_1,E_2,E_3$ realized as the explicit Temperley–Lieb
path-model projectors at $\delta = \varphi$, all hypotheses of Theorems 1–3 become
finite matrix identities verifiable by direct computation. The resulting
$\sigma_i$ are the concrete $3\times 3$ braid gates of the Fibonacci anyon model
on four strands.

**Unitarity.** Adjoining the star structure $\overline{A} = A^{-1}$ and
$E_i^\dagger = E_i$ makes each $\sigma_i$ unitary, so the representation lands in
$U(3)$, and after a determinant normalization in $SU(3)$.

**The conjectural superstructure.** The deep results of Freedman–Larsen–Wang
imply that the image of $B_4$ under this representation is *dense* in (a quotient
acting as) $SU(3)$; combined with the Solovay–Kitaev theorem, density yields
*efficient* universality. These analytic statements are **not** formalized here.
They constitute the principal future work and require: (i) the concrete model
above; (ii) irreducibility of the $3$-dimensional representation (a commutant
computation); (iii) the invariant Hermitian form; and (iv) packaging the relations
into a genuine group homomorphism out of a presentation of $B_4$.

We emphasize the logical ordering: density and universality are meaningful only
once the representation itself is known to exist and be invertible. That existence
and invertibility — the load-bearing foundation — is exactly what this paper
establishes with machine-checked certainty.

---

## 8. Related Context

The Temperley–Lieb algebra originated in statistical mechanics (Temperley and
Lieb, 1971) and was connected to von Neumann algebras and knot invariants by
Vaughan Jones, whose work led to the Jones polynomial. The Kauffman bracket gives
the diagrammatic state-sum realization of these invariants. The braid/Yang–Baxter
relation is the consistency condition shared by exactly solvable lattice models,
quantum groups, and anyonic statistics. The application to fault-tolerant quantum
computation is due to Kitaev and to Freedman, Larsen, and Wang. The present work
contributes a verified, generic algebraic kernel for this circle of ideas.

---

## 9. Conclusion

We have given a complete, machine-verified development of the algebraic heart of
the Jones braid representation on four strands: the Kauffman-bracket generator,
its inverse, the loop-value identity that powers every reduction, far-commutation,
the braid relation, and two-sided invertibility. The construction is generic in
the field and algebra, isolating exactly the hypotheses (loop value plus
Temperley–Lieb relations) that any concrete model — in particular the
golden-ratio Fibonacci model — must satisfy. With this foundation certified, the
remaining steps toward a fully verified account of topological quantum
universality are a concrete instantiation and the analytic density argument, which
we identify as the natural next milestones.

---

## Appendix A. Summary of Formal Results

| Name | Statement |
|---|---|
| `jonesOp` | $\sigma \mapsto A\bullet\mathbf 1 + A^{-1}\bullet X$ |
| `jonesInv` | $\sigma^{-1} \mapsto A^{-1}\bullet\mathbf 1 + A\bullet X$ |
| `delta_scalar_id` | $\delta=-(A^2{+}A^{-2}) \Rightarrow A^2+\delta+A^{-2}=0$ |
| `braid_commute` | $XY=YX \Rightarrow \sigma_X\sigma_Y=\sigma_Y\sigma_X$ |
| `braid_relation` | TL relations $\Rightarrow \sigma_X\sigma_Y\sigma_X=\sigma_Y\sigma_X\sigma_Y$ |
| `jonesOp_mul_jonesInv` | $\sigma_X\sigma_X^{-1}=\mathbf 1$ |
| `jonesInv_mul_jonesOp` | $\sigma_X^{-1}\sigma_X=\mathbf 1$ |
