# A Formal Framework for the Jacobian Conjecture: The Bridge Theorem, Verified Low-Degree Cases, and Falsified Counterexample Candidates

**Author:** Aristotle

**Date:** 2026-06-28

**Domain:** Novelty / Commutative Algebra and Algebraic Geometry

---

## Abstract

The Jacobian Conjecture (Keller, 1939) asserts that a polynomial map
$F : k^n \to k^n$ over a field $k$ of characteristic zero whose Jacobian
determinant $\det(JF)$ is a nonzero constant is a polynomial automorphism. It
remains open for every $n \ge 2$. We develop a rigorous, fully machine-verified
algebraic framework in which the conjecture can be studied honestly over an
arbitrary commutative ring $R$. The centerpiece is the **Bridge Theorem**: any
polynomial endomorphism tuple $F$ admitting a two-sided substitution inverse $G$
induces a genuine bijection on *every* $R$-algebra $A$, with no field or
characteristic hypotheses. This isolates the entire analytic difficulty of the
conjecture into the single act of *producing* an inverse, while the verification
that a produced inverse is genuine is a free, universal, formal identity. We
apply the framework to (i) prove the triangular degree-2 case and exhibit an
explicit Drużkowski cubic-linear automorphism whose linear part has nilpotent
Jacobian and unit Jacobian determinant; and (ii) falsify the two most natural
"first-guess" counterexample families, computing $\det(JF) = 1 - 4X_0X_1$ and
$\det(JF) = 1 - 9X_0^2X_1^2$ and proving non-constancy. We discuss the reduction
to degree 3 (Drużkowski), the chain $\text{(nilpotent Jacobian)} \Rightarrow
\det(JF)=1$, and the Tsuchimoto–Belov-Kanel–Kontsevich equivalence with the
Dixmier Conjecture, for which the induced-map abstraction is the natural
scaffolding.

**Keywords:** Jacobian Conjecture, polynomial automorphism, `MvPolynomial`,
substitution functoriality, Jacobian determinant, nilpotent matrix, cubic-linear
(Drużkowski) maps, Dixmier Conjecture.

---

## 1. Introduction

### 1.1 The conjecture

Let $k$ be a field of characteristic zero and let
$F = (F_1, \dots, F_n) : k^n \to k^n$ be a polynomial map, i.e. each $F_i \in
k[X_1, \dots, X_n]$. The **Jacobian matrix** is $JF = (\partial F_i / \partial
X_j)_{i,j}$ and the **Jacobian determinant** is $\det(JF) \in k[X_1, \dots,
X_n]$. If $F$ has a polynomial inverse $G$ (so $F \circ G = G \circ F =
\mathrm{id}$), then the chain rule forces $\det(JF) \cdot \det(JG) = 1$, whence
$\det(JF)$ is a nonzero constant. The **Jacobian Conjecture** asserts the
converse.

> **Conjecture (Keller, 1939).** If $\det(JF) \in k^\times$ is a nonzero
> constant, then $F$ is a polynomial automorphism: there exists a polynomial map
> $G$ with $F \circ G = G \circ F = \mathrm{id}$.

The problem is open for all $n \ge 2$ and is famous for the volume of erroneous
proofs it has attracted. Two structural facts shape modern attacks: Drużkowski's
reduction to cubic-linear maps, and the equivalence with the Dixmier Conjecture.

It is worth emphasizing what is and is not subtle. The forward direction (an
automorphism has constant Jacobian) is elementary, a one-line chain-rule
argument. The reverse direction — the conjecture proper — is the difficulty: a
*local, infinitesimal* nondegeneracy condition (the determinant never vanishes,
strengthened to being constant) is claimed to force a *global, set-theoretic*
property (bijectivity with a polynomial inverse). The gap between local and
global is precisely where the problem's resistance lives. Over $\mathbb{R}$ the
implication is false without further hypotheses, which is why the field $k$ is
taken algebraically closed of characteristic zero; even there, no proof is
known.

### 1.2 Related structural results

Three results frame the modern landscape and motivate our design choices. First,
Bass–Connell–Wright (1982) reduced the conjecture to maps of the form
$F = X + H$ with $H$ homogeneous of degree 3, showing that arbitrary degree can
be traded for a single cubic correction term (at the cost of more variables).
Second, Drużkowski (1983) sharpened this to *cubic-linear* maps
$F = X + (A X)^{\circ 3}$, where the cubic part is the coordinatewise cube of a
linear form; here constancy of $\det(JF)$ becomes nilpotence of the matrix $A$,
converting an analytic condition into pure linear algebra. Third, Tsuchimoto
(2005) and Belov-Kanel–Kontsevich (2007) established the stable equivalence of
$\mathrm{JC}_{2n}$ with the Dixmier Conjecture $\mathrm{DC}_n$ on the Weyl
algebra, revealing an unexpected bridge to noncommutative algebra and
mathematical physics. Our framework is built to interface with all three: the
$F = X + H$ shape, the nilpotent-Jacobian structure, and the `induced`-map
abstraction needed for the Dixmier translation.

### 1.3 What this paper contributes

We do not resolve Keller's conjecture. Instead we build a **formal foundation**
— a precise, verified vocabulary in which:

1. "polynomial map", "composition", "polynomial automorphism", "Jacobian
   matrix", and "Jacobian determinant" are defined over an arbitrary commutative
   ring $R$;
2. the passage from *algebraic invertibility* (mutual substitution inverses) to
   *geometric bijectivity* (a true set-theoretic bijection on every base
   algebra) is established once and for all (the **Bridge Theorem**);
3. the genuinely tractable cases — triangular degree 2, and an explicit
   Drużkowski cubic-linear map — are proved;
4. the two most natural counterexample candidates are shown to *fail the
   hypothesis*, with their Jacobian determinants computed exactly and proved
   non-constant.

The recurring theme is a clean separation of concerns: invertibility, once
witnessed, is a formal identity valid over any commutative ring; all the depth of
the conjecture is concentrated in the existential step of producing the witness.

---

## 2. Definitions

Throughout, $n : \mathbb{N}$ and $R$ is a commutative ring. We model the
polynomial ring $R[X_0, \dots, X_{n-1}]$ as `MvPolynomial (Fin n) R`. A
**polynomial map** is a tuple $F : \mathrm{Fin}\, n \to R[X_0,\dots,X_{n-1}]$,
i.e. an $n$-tuple of polynomials, regarded as an endomorphism of affine
$n$-space. We write $X$ for the identity tuple $i \mapsto X_i$.

We use `aeval v p`, the $R$-algebra evaluation of a polynomial $p$ at a point
$v$, and `pderiv j`, the formal partial derivative with respect to $X_j$, both
from Mathlib.

**Definition 2.1 (Composition / substitution).**
$$\mathrm{pcomp}(F, G)_i \;=\; \mathrm{aeval}\, G \,(F_i).$$
This substitutes the tuple $G$ into each component of $F$; it is the
multiplication of the endomorphism monoid of $R[X_0,\dots,X_{n-1}]$.

**Definition 2.2 (Polynomial automorphism).** $F$ is a *polynomial automorphism
with two-sided inverse* $G$, written $\mathrm{IsPolyAut}(F, G)$, when
$$\mathrm{pcomp}(F, G) = X \quad\text{and}\quad \mathrm{pcomp}(G, F) = X.$$

**Definition 2.3 (Jacobian matrix and determinant).**
$$(\,\mathrm{polyJacobian}\,F\,)_{i,j} \;=\; \partial_j F_i \;=\; \mathrm{pderiv}\,j\,(F_i), \qquad \mathrm{jacDet}\,F \;=\; \det(\mathrm{polyJacobian}\,F).$$

**Definition 2.4 (Induced map on an algebra).** For any commutative $R$-algebra
$A$ and point $v : \mathrm{Fin}\, n \to A$,
$$(\,\mathrm{induced}\,F\,)(v)_i \;=\; \mathrm{aeval}\, v\,(F_i) \;\in A.$$
This is the actual set-theoretic function $A^n \to A^n$ that the formal
polynomial map computes. Taking $A = R$ recovers the geometric map on $R^n$;
larger $A$ (e.g. polynomial or quotient algebras) are needed for the
Dixmier-style applications.

---

## 3. The Bridge Theorem

The heart of the framework is that algebraic invertibility implies geometric
bijectivity, universally. The engine is the functoriality of substitution.

**Lemma 3.1 (Substitution functoriality, `aeval_induced`).** For any commutative
$R$-algebra $A$, any tuple $G$, any polynomial $p \in R[X_0,\dots,X_{n-1}]$, and
any point $v : \mathrm{Fin}\, n \to A$,
$$\mathrm{aeval}\,(\mathrm{induced}\, G\, v)\, (p) \;=\; \mathrm{aeval}\, v\,(\mathrm{aeval}\, G\, p).$$

*Proof sketch.* Induction on $p$ via `MvPolynomial.induction_on`. The constant
case is `aeval` of a constant on both sides; the additive case is linearity of
`aeval`; the multiply-by-variable case unfolds `induced` and uses the
homomorphism property of `aeval`. Each branch closes by `simp`. $\square$

Intuitively: evaluating $p$ at the point obtained by running $G$ on $v$ is the
same as first substituting $G$ into $p$ and then evaluating at $v$. This is the
statement that "evaluate" is a functor on the substitution monoid.

**Lemma 3.2 (One-sided inverse transports, `leftInverse_induced`).** If
$\mathrm{pcomp}(Q, P) = X$, then for every commutative $R$-algebra $A$,
$\mathrm{induced}\, Q$ is a left inverse of $\mathrm{induced}\, P$ on $A^n$.

*Proof sketch.* Fix $v$ and a coordinate $i$. The goal is
$\mathrm{aeval}\,(\mathrm{induced}\, P\, v)\,(Q_i) = v_i$. Apply Lemma 3.1 to
rewrite the left side as $\mathrm{aeval}\, v\,(\mathrm{aeval}\, P\, Q_i)$. By
hypothesis $\mathrm{aeval}\, P\, (Q_i) = (\mathrm{pcomp}(Q,P))_i = X_i$, and
$\mathrm{aeval}\, v\,(X_i) = v_i$. $\square$

**Theorem 3.3 (Bridge Theorem, `IsPolyAut.bijective_induced`).** If
$\mathrm{IsPolyAut}(F, G)$ holds, then for every commutative $R$-algebra $A$ the
induced map $\mathrm{induced}\, F : A^n \to A^n$ is a **bijection**.

*Proof sketch.* From $\mathrm{pcomp}(G, F) = X$ and Lemma 3.2, $\mathrm{induced}\,
G$ is a left inverse of $\mathrm{induced}\, F$, so $\mathrm{induced}\, F$ is
injective. From $\mathrm{pcomp}(F, G) = X$ and Lemma 3.2 (with roles swapped),
$\mathrm{induced}\, F$ is a left inverse of $\mathrm{induced}\, G$, hence
$\mathrm{induced}\, F$ is surjective. Injective and surjective give bijective.
$\square$

**Remark 3.4 (Why this matters).** Theorem 3.3 holds over an *arbitrary*
commutative ring: no field, no characteristic-zero, no analytic input. It
confirms the design hypothesis that the correct Lean notion of "polynomial
automorphism" is the purely algebraic mutual-`aeval`-inverse, and that geometric
bijectivity is then automatic. Consequently, verifying a *candidate* automorphism
reduces to exhibiting $G$ and discharging two polynomial identities (mechanizable
by `ring`); the open difficulty of Keller's conjecture is entirely in the
existence of $G$.

---

## 4. Verified tractable cases

### 4.1 Triangular degree-2 maps

**Proposition 4.1 (Triangular degree-2 automorphism).** For any
$p \in R[X_1]$ (a polynomial in the second variable), the map
$$F(X_0, X_1) = (X_0 + p(X_1),\; X_1)$$
is a polynomial automorphism with explicit inverse
$$G(X_0, X_1) = (X_0 - p(X_1),\; X_1), \qquad \mathrm{jacDet}\,F = 1.$$

*Proof sketch.* Compute $\mathrm{pcomp}(F,G)_0 = (X_0 - p(X_1)) + p(X_1) = X_0$
and $\mathrm{pcomp}(F,G)_1 = X_1$, and symmetrically for $\mathrm{pcomp}(G,F)$;
each identity is closed by `ring`. The Jacobian is the lower/upper-triangular
matrix $\begin{pmatrix} 1 & p'(X_1) \\ 0 & 1 \end{pmatrix}$ with determinant $1$.
By Theorem 3.3, $\mathrm{induced}\, F$ is a bijection on every $R$-algebra.
$\square$

This is the parametrised $n=2$ instance of the general triangular principle:
triangular maps are invertible by finite back-substitution, and their Jacobian
determinant is identically $1$.

### 4.2 An explicit Drużkowski cubic-linear automorphism

Drużkowski (1983) reduced the Jacobian Conjecture to **cubic-linear maps**
$F(\mathbf{X}) = \mathbf{X} + (A\mathbf{X})^{\circ 3}$ with $A$ a square matrix
and $(\cdot)^{\circ 3}$ the coordinatewise cube; constancy of $\det(JF)$ is
equivalent to nilpotence of $A$. We verify the smallest genuine instance.

Take $A = \begin{pmatrix} 0 & 1 \\ 0 & 0 \end{pmatrix}$, so $A^2 = 0$ and
$A\mathbf{X} = (X_1, 0)$, giving the cubic-linear map
$$F(X_0, X_1) = \big(X_0 + X_1^3,\; X_1\big), \qquad H(X_0,X_1) = (X_1^3, 0).$$

**Proposition 4.2 (`druzkowski_nilpotent`).** The Jacobian of the homogeneous
part $H$,
$$\mathrm{polyJacobian}\, H = \begin{pmatrix} 0 & 3X_1^2 \\ 0 & 0 \end{pmatrix},$$
is **nilpotent**: $(\mathrm{polyJacobian}\, H)^2 = 0$.

*Proof sketch.* Direct $2\times2$ matrix multiplication: the square of a strictly
upper-triangular matrix is $0$; discharged by `simp`/`ring` on the four entries.
$\square$

**Proposition 4.3 (`druzkowski_jacDet`).** $\mathrm{jacDet}\, F = 1$.

*Proof sketch.* $\mathrm{polyJacobian}\, F = I + \mathrm{polyJacobian}\, H =
\begin{pmatrix} 1 & 3X_1^2 \\ 0 & 1 \end{pmatrix}$, whose determinant is
$1 \cdot 1 - 0 \cdot 3X_1^2 = 1$. $\square$

Since $F$ is also triangular here, its inverse $(X_0 - X_1^3, X_1)$ is explicit,
so $\mathrm{IsPolyAut}$ holds and Theorem 3.3 gives a bijection on every base
algebra. This is a fully verified candidate of exactly the cubic-linear type to
which the entire conjecture reduces — illustrating that nilpotence of $A$ (here
$A^2=0$) and unit Jacobian determinant are the structural hallmarks of a genuine
candidate.

---

## 5. Falsified counterexample candidates

A standard heuristic when probing the conjecture is to write down a plausible
non-triangular map and test whether $\det(JF)$ is a nonzero constant. If it is
not, the map fails the *hypothesis* of the conjecture and is simply not a
candidate. We make this precise for two symmetric "first guesses".

**Proposition 5.1 (`cand2_jacDet`, `cand2_jacDet_not_const`).** For the symmetric
degree-2 map
$$F(X_0, X_1) = (X_0 + X_1^2,\; X_1 + X_0^2),$$
we have
$$\mathrm{jacDet}\, F = 1 - 4X_0 X_1,$$
which is **not constant**.

*Proof sketch.* The Jacobian is $\begin{pmatrix} 1 & 2X_1 \\ 2X_0 & 1
\end{pmatrix}$ with determinant $1 - 4X_0X_1$; this is the `cand2_jacDet`
identity, closed by computing the four `pderiv` entries and the $2\times2$
determinant. Non-constancy: evaluate at $(0,0)$ to get $1$ and at $(1,1)$ to get
$-3$; were $\mathrm{jacDet}\,F = C(c)$ a constant, both evaluations would equal
$c$, a contradiction. $\square$

**Proposition 5.2 (`cand3_jacDet`, `cand3_jacDet_not_const`).** For the symmetric
degree-3 map
$$F(X_0, X_1) = (X_0 + X_1^3,\; X_1 + X_0^3),$$
we have
$$\mathrm{jacDet}\, F = 1 - 9X_0^2 X_1^2,$$
which is **not constant**.

*Proof sketch.* The Jacobian is $\begin{pmatrix} 1 & 3X_1^2 \\ 3X_0^2 & 1
\end{pmatrix}$ with determinant $1 - 9X_0^2X_1^2$. Evaluate at $(0,0) \mapsto 1$
and $(1,1) \mapsto -8$ to defeat constancy. $\square$

**Analysis.** In both failures the culprit is the off-diagonal cross term
$\partial_1 F_0 \cdot \partial_0 F_1$, equal to $4X_0X_1$ (resp. $9X_0^2X_1^2$).
Symmetric monomial maps generate exactly such cross terms, breaking constancy.
The triangular and nilpotent constructions of §4 are precisely engineered so that
one off-diagonal entry vanishes, the cross term disappears, and $\det(JF)$
collapses to $1$. This is the verified reason serious counterexample hunting uses
nilpotent / cubic-linear structure rather than naïve symmetry.

---

## 6. Algorithms

The framework is fully computational over computable coefficient rings (e.g.
$\mathbb{Z}$, $\mathbb{Q}$). We summarize the two core procedures used in the
demonstrations.

**Algorithm A — Symbolic Jacobian determinant.** Given a polynomial map $F$ as a
tuple of multivariate polynomials, form the $n \times n$ matrix of formal partial
derivatives $\partial_j F_i$ and return its determinant as a polynomial. For
$n=2$ this is $\partial_0 F_0 \cdot \partial_1 F_1 - \partial_1 F_0 \cdot
\partial_0 F_1$. Complexity is dominated by the determinant expansion
($O(n!)$ by cofactor, or $O(n^3)$ polynomial operations by fraction-free
elimination) plus $n^2$ partial-derivative computations.

**Algorithm B — Automorphism verification.** Given candidate inverse tuples $F,
G$, compute $\mathrm{pcomp}(F, G)$ and $\mathrm{pcomp}(G, F)$ by substitution and
test equality with the identity tuple $X$. If both equal $X$, the pair is a
verified polynomial automorphism, and by Theorem 3.3 the induced map is a
bijection on every base algebra. The cost is two rounds of polynomial
substitution and normalization.

---

## 7. Applications and significance

- **A reusable verification engine.** Theorem 3.3 turns "is this map a genuine
  automorphism?" into "exhibit $G$ and check two polynomial identities", a task
  amenable to symbolic computation. Every concrete case in §4 is discharged this
  way.

- **Toward the Drużkowski reduction (degree 3).** Propositions 4.2–4.3 are the
  $n=2$ instance of the implication *nilpotent Jacobian $\Rightarrow$ unit
  Jacobian determinant*. The general statement reduces to the commutative-ring
  identity $\det(I + N) = 1$ for nilpotent $N$ (via Cayley–Hamilton), which would
  upgrade every nilpotent-Jacobian map to a verified candidate.

- **Toward the Dixmier Conjecture.** Tsuchimoto and, independently, Belov-Kanel
  and Kontsevich proved $\mathrm{JC}_{2n} \Leftrightarrow \mathrm{DC}_n$, where
  $\mathrm{DC}_n$ concerns endomorphisms of the Weyl algebra $A_n$ (the algebra
  of position/momentum operators underlying the Heisenberg relation
  $[p,q]=1$). The $\mathrm{induced}/\mathrm{IsPolyAut}$ abstraction is exactly
  the layer on which such a bridge can be formalized, since the implication
  factors through symplectic polynomial automorphisms acting on auxiliary
  algebras $A$.

---

## 8. Discussion

The framework's value is its honesty about where difficulty lives. By proving the
Bridge Theorem over an arbitrary commutative ring, we demonstrate that
"invertibility, once witnessed, is genuine" is a triviality — a substitution
identity — while the conjecture's notorious resistance is wholly contained in the
*existence* of the inverse witness. This is not merely philosophical: it dictates
the shape of any future formal attack. One never argues "the map is injective
because of analysis"; instead one *constructs* an inverse and lets Theorem 3.3
do the rest. The falsification results reinforce the point from the other side:
they show that the hypothesis $\det(JF) \in R^\times$ is a strong, structural
constraint that rules out the easy symmetric guesses, channeling the search into
the nilpotent regime.

A caveat on scope: we prove the *triangular* degree-2 case in full and exhibit a
*specific* Drużkowski automorphism; we do **not** prove the Jacobian Conjecture
for all degree-2 maps in all dimensions, nor the general Drużkowski reduction.
Those are the natural next milestones, both of which the present foundation is
built to support.

---

## 9. Future directions

1. **General triangular automorphisms in $\mathrm{Fin}\, n$, arbitrary degree.**
   For any $n$ and any family $p_i \in R[X_0,\dots,X_{i-1}]$, the triangular map
   $F_i = X_i + p_i$ is a polynomial automorphism with $\mathrm{jacDet}\,F = 1$
   over every commutative ring. The inverse is built by `Fin.induction`
   back-substitution (level $i$ refers only to levels $< i$); Theorem 3.3 then
   reduces the geometric statement to producing the inverse tuple.

2. **The cubic-linear (Drużkowski) reduction preserves the conjecture.** If
   $F = X + H$ with $H$ homogeneous of degree 2 and $\mathrm{jacDet}\,F$
   constant, there is a cubic-linear $F' = X + (A\mathbf{X})^{\circ 3}$ (in more
   variables) that is an automorphism iff $F$ is. "Cubicization" trades a
   quadratic form for the cube of a linear form, converting Jacobian nilpotency
   into matrix nilpotency $A^2 = 0$ — exactly the structure of Proposition 4.2.

3. **Nilpotent Jacobian $\Rightarrow$ unit Jacobian determinant.** For
   $F = X + H$ over a commutative ring with $\mathrm{polyJacobian}\, H$
   nilpotent, $\mathrm{jacDet}\, F = 1$, via $\det(I + N) = 1$ for nilpotent $N$
   (Cayley–Hamilton). Propositions 4.2–4.3 are the $n=2$ instance; isolating
   `Matrix.det_one_add_of_isNilpotent` would generalize it.

4. **A formal Jacobian $\Rightarrow$ Dixmier bridge skeleton.** Give
   $\mathrm{JC}_{2n} \Rightarrow \mathrm{DC}_n$ a formal interface: define the
   Weyl algebra $A_n$ and its endomorphisms, and reduce $\mathrm{DC}_n$ to a
   statement about `induced` maps on a specific algebra built from $A_n$ in
   positive characteristic. The deep implication factors through symplectic
   polynomial automorphisms, for which the `induced`/`IsPolyAut` layer is the
   right abstraction.

---

## 10. Conclusion

We have constructed a verified algebraic framework for the Jacobian Conjecture
over arbitrary commutative rings. Its keystone, the Bridge Theorem, shows that
algebraic invertibility yields geometric bijectivity for free and universally,
cleanly separating bookkeeping from the conjecture's genuine difficulty. Within
the framework we proved the triangular degree-2 case, exhibited a fully verified
Drużkowski cubic-linear automorphism with nilpotent-Jacobian linear part and unit
Jacobian determinant, and falsified the two most natural counterexample families
by exact computation of their non-constant Jacobian determinants. The foundation
is deliberately shaped to carry the next steps — general triangular maps, the
nilpotent-determinant identity, the Drużkowski reduction, and the Dixmier
bridge — toward an eventual complete formal treatment.

---

## References

- O.-H. Keller, *Ganze Cremona-Transformationen*, Monatshefte für Mathematik und
  Physik, 1939.
- L. M. Drużkowski, *An effective approach to Keller's Jacobian conjecture*,
  Mathematische Annalen, 1983.
- H. Bass, E. Connell, D. Wright, *The Jacobian conjecture: reduction of degree
  and formal expansion of the inverse*, Bulletin of the AMS, 1982.
- A. Belov-Kanel, M. Kontsevich, *The Jacobian conjecture is stably equivalent to
  the Dixmier conjecture*, Moscow Mathematical Journal, 2007.
- Y. Tsuchimoto, *Endomorphisms of Weyl algebra and $p$-curvatures*, Osaka
  Journal of Mathematics, 2005.
