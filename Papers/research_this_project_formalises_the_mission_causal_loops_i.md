# Monoidal Strictification of the Parenthesization Category

**Author:** Aristotle
**Date:** 2026-07-12

## Abstract

We study a concrete monoidal category built entirely from formal
parenthesizations — the category $\mathsf{P}(\alpha)$ whose objects are binary
trees with leaves labelled by an alphabet $\alpha$ and whose morphisms are
witnesses that two trees share the same underlying leaf-word. The tensor product
is tree-grafting; it is deliberately **not associative on objects**, and its
associativity is repaired instead by a canonical invertible associator. We show
that $\mathsf{P}(\alpha)$ is a *thin* category (at most one morphism between any
pair of objects) and observe that on a thin category every coherence law of a
monoidal structure — the pentagon, the triangle, and all naturality squares —
holds automatically. Consequently $\mathsf{P}(\alpha)$ is a genuine, and
genuinely non-strict, monoidal category. We then construct the **flattening
functor** $\mathrm{Flat}\colon \mathsf{P}(\alpha) \to \mathsf{D}(\alpha)$ into
the discrete strict monoidal category of words in the free monoid
$\mathsf{F}(\alpha)$ under concatenation, prove that it is a strong monoidal
functor with identity comparison data, and upgrade the resulting categorical
equivalence $\mathsf{P}(\alpha) \simeq \mathsf{D}(\alpha)$ to a **monoidal
equivalence**. This realizes, for this family, the full content of Mac Lane's
strictification theorem: a coherent non-strict monoidal structure is monoidally
equivalent to a strict one. Finally we show that under strictification the
associator is contracted to an identity-type morphism, exhibiting the "causal
loop" of reassociations collapsing to a point.

## 1. Introduction

Associativity is the quiet backbone of algebra. In a set with a binary operation
we typically demand $(a\cdot b)\cdot c = a\cdot(b\cdot c)$ as an equation, and
then we drop parentheses forever. In higher-dimensional and categorical settings,
however, the natural objects of study — spaces, systems, processes — are
combined by operations whose associativity holds only *up to a specified
isomorphism*, not up to equality. The two groupings $(a\otimes b)\otimes c$ and
$a\otimes(b\otimes c)$ become distinct objects joined by a chosen comparison
morphism, the **associator**. A **monoidal category** is precisely a category
equipped with such a tensor, a unit, an associator, and unit-law isomorphisms.

Once associativity is mediated by morphisms rather than equations, one must ask
whether the mediating morphisms are mutually consistent. Mac Lane's **coherence
theorem** answers this: if the associator and unitors satisfy two basic
diagrams — the **pentagon** and the **triangle** — then *every* formal diagram
built from them commutes, so any two ways of reassociating a product agree. A
sharper structural statement, the **strictification theorem**, asserts that every
monoidal category is monoidally equivalent to a *strict* one, in which
associativity and the unit laws hold on the nose.

This paper is a self-contained development of these ideas for one especially
transparent family: the category of formal parenthesizations. We take the objects
of associativity — the bracketings themselves — as the objects of a category, so
that the failure of strict associativity is visible and honest. We then show that
the category is *thin*, which trivializes all coherence, and we carry out the
strictification explicitly. The result is a small but complete laboratory in
which coherence and strictification can be seen operating with no moving parts
hidden.

Throughout, $\alpha$ is a fixed type ("alphabet") of leaf labels, and
$\mathsf{F}(\alpha)$ denotes the free monoid on $\alpha$: finite words in the
letters of $\alpha$ under concatenation, with the empty word $1$ as unit.

## 2. Thin categories and free coherence

**Definition 2.1 (Thin category).** A category $\mathcal{C}$ is *thin* if for any
objects $X, Y$ and any two morphisms $f, g \colon X \to Y$ we have $f = g$; that
is, every hom-set has at most one element.

Thinness is equivalent to saying that all hom-sets are subsingletons. Its
defining virtue is:

**Lemma 2.2 (Every diagram commutes).** In a thin category, any two parallel
composites are equal. In particular any square, pentagon, or triangle of
morphisms commutes automatically.

*Proof.* Two parallel composites are two morphisms with the same source and
target; by thinness they coincide. $\qquad\blacksquare$

A **monoidal structure** on $\mathcal{C}$ consists of a tensor bifunctor
$\otimes$, a unit object $\mathbb{1}$, and natural isomorphisms
$$\alpha_{X,Y,Z}\colon (X\otimes Y)\otimes Z \to X\otimes(Y\otimes Z),\quad
\lambda_X\colon \mathbb{1}\otimes X \to X,\quad
\rho_X\colon X\otimes\mathbb{1}\to X,$$
subject to the pentagon and triangle axioms and the naturality of $\alpha,
\lambda, \rho$. When only the *data* (the objects, morphisms, and the three
families of isomorphisms) are given without the axioms, we call it a *monoidal
structure datum*.

**Theorem 2.3 (Coherence from thinness).** Let $\mathcal{C}$ be a thin category
equipped with a monoidal structure datum. Then all the monoidal axioms — the
pentagon identity, the triangle identity, naturality of the associator and both
unitors, and the interchange/functoriality laws for $\otimes$ — hold
automatically. Hence $\mathcal{C}$ is a genuine monoidal category.

*Proof.* Each axiom asserts the equality of two parallel morphisms in
$\mathcal{C}$. By Lemma 2.2 every such equality holds. $\qquad\blacksquare$

Theorem 2.3 is the engine of the paper: it lets us specify a monoidal structure
on a thin category by merely choosing the tensor, unit, and comparison
isomorphisms, with no verification of coherence required.

## 3. The parenthesization category

**Definition 3.1 (Trees).** Let $\mathsf{P}(\alpha)$ be the set of binary trees
with leaves labelled by $\alpha$, generated inductively by:

- $\mathrm{nil}$ — the empty tree;
- $\mathrm{leaf}(a)$ for each $a \in \alpha$;
- $\mathrm{node}(s, t)$ for trees $s, t$ — the bracketed product, read as
  $(s \cdot t)$.

**Definition 3.2 (Flattening).** The *flattening* map
$\mathrm{flat}\colon \mathsf{P}(\alpha) \to \mathsf{F}(\alpha)$ reads the leaves
left to right:
$$\mathrm{flat}(\mathrm{nil}) = 1,\qquad
\mathrm{flat}(\mathrm{leaf}(a)) = a,\qquad
\mathrm{flat}(\mathrm{node}(s,t)) = \mathrm{flat}(s)\cdot\mathrm{flat}(t).$$

**Definition 3.3 (The category $\mathsf{P}(\alpha)$).** Make $\mathsf{P}(\alpha)$
a category by declaring
$$\mathrm{Hom}(s, t) := \{\text{proofs that } \mathrm{flat}(s) = \mathrm{flat}(t)\},$$
a set with one element if $\mathrm{flat}(s) = \mathrm{flat}(t)$ and none
otherwise. Identities are reflexivity and composition is transitivity of
equality.

**Proposition 3.4 (Thin groupoid).** $\mathsf{P}(\alpha)$ is a thin category, and
every morphism is an isomorphism; that is, $\mathsf{P}(\alpha)$ is a thin
groupoid.

*Proof.* Two morphisms $s \to t$ are two proofs of the single proposition
$\mathrm{flat}(s) = \mathrm{flat}(t)$; since the hom-set carries the structure of
a subsingleton, they are equal, so the category is thin. Given a morphism
$s \to t$, i.e. $\mathrm{flat}(s) = \mathrm{flat}(t)$, the symmetric equality
$\mathrm{flat}(t) = \mathrm{flat}(s)$ provides an inverse. $\qquad\blacksquare$

We record a convenient packaging lemma.

**Lemma 3.5 (Isomorphisms from word equalities).** For trees $s, t$, any equality
$\mathrm{flat}(s) = \mathrm{flat}(t)$ determines an isomorphism $s \cong t$; by
thinness it is the unique isomorphism between $s$ and $t$.

**Definition 3.6 (Monoidal structure datum on $\mathsf{P}(\alpha)$).** Set
$$s \otimes t := \mathrm{node}(s, t),\qquad \mathbb{1} := \mathrm{nil}.$$
Whiskering (the action of $\otimes$ on morphisms) is induced by congruence of
multiplication in $\mathsf{F}(\alpha)$. The comparison isomorphisms are read off
from the free monoid via Lemma 3.5:
$$\alpha_{s,t,u}\ \text{from}\ (\mathrm{flat}\,s\cdot\mathrm{flat}\,t)\cdot\mathrm{flat}\,u = \mathrm{flat}\,s\cdot(\mathrm{flat}\,t\cdot\mathrm{flat}\,u),$$
$$\lambda_s\ \text{from}\ 1\cdot\mathrm{flat}\,s = \mathrm{flat}\,s,\qquad
\rho_s\ \text{from}\ \mathrm{flat}\,s\cdot 1 = \mathrm{flat}\,s.$$

**Theorem 3.7 ($\mathsf{P}(\alpha)$ is monoidal).** With the datum of Definition
3.6, $\mathsf{P}(\alpha)$ is a monoidal category.

*Proof.* $\mathsf{P}(\alpha)$ is thin (Proposition 3.4), so Theorem 2.3 supplies
every coherence axiom. $\qquad\blacksquare$

**Proposition 3.8 (Non-strictness).** For beads $a, b, c$, the trees
$(a\otimes b)\otimes c = \mathrm{node}(\mathrm{node}(a,b),c)$ and
$a\otimes(b\otimes c) = \mathrm{node}(a,\mathrm{node}(b,c))$ are distinct objects.
Hence $\mathsf{P}(\alpha)$ is a non-strict monoidal category: associativity fails
at the level of objects and is repaired only by the associator $\alpha_{a,b,c}$,
which by Lemma 3.5 is the unique isomorphism between these objects.

*Proof.* The two trees have different shapes, hence are unequal as data, even
though they flatten to the same word $\mathrm{flat}(a)\mathrm{flat}(b)\mathrm{flat}(c)$.
$\qquad\blacksquare$

Proposition 3.8 is the whole point: associativity has been made to fail honestly,
and coherence (Theorem 3.7) then guarantees the failure is harmless.

## 4. Flattening as a strong monoidal functor

Let $\mathsf{D}(\alpha)$ denote the **discrete** category on the underlying set
of $\mathsf{F}(\alpha)$: objects are words, and the only morphisms are
identities. Concatenation of words makes $\mathsf{D}(\alpha)$ a **strict**
monoidal category, since concatenation is associative on the nose with the empty
word as strict unit. This is the strict skeleton toward which we strictify.

**Definition 4.1 (Flattening functor).** Define
$\mathrm{Flat}\colon \mathsf{P}(\alpha) \to \mathsf{D}(\alpha)$ by
$$\mathrm{Flat}(s) := \mathrm{flat}(s),\qquad
\mathrm{Flat}(f) := \mathrm{id}\ \text{(the unique morphism given by } f\text{)}.$$
On morphisms this is well defined because a morphism $f\colon s\to t$ certifies
$\mathrm{flat}(s) = \mathrm{flat}(t)$, i.e. $\mathrm{Flat}(s) = \mathrm{Flat}(t)$
as objects of the discrete category, so it maps to the identity/coincidence
morphism there. Functoriality is automatic because $\mathsf{D}(\alpha)$ is thin.

**Lemma 4.2 (Flattening respects the monoidal structure strictly).** For all
trees $s, t$,
$$\mathrm{flat}(s\otimes t) = \mathrm{flat}(s)\cdot\mathrm{flat}(t),
\qquad \mathrm{flat}(\mathbb{1}) = 1.$$
Both hold as literal equalities.

*Proof.* Immediate from Definition 3.2 and the choice
$s\otimes t = \mathrm{node}(s,t)$, $\mathbb{1} = \mathrm{nil}$. $\qquad\blacksquare$

**Theorem 4.3 (Strong monoidality of flattening).** The functor $\mathrm{Flat}$
carries the structure of a strong monoidal functor. The unit comparison
$\varepsilon\colon \mathbb{1}_{\mathsf{D}} \to \mathrm{Flat}(\mathbb{1})$ and the
tensorator $\mu_{s,t}\colon \mathrm{Flat}(s)\cdot\mathrm{Flat}(t) \to
\mathrm{Flat}(s\otimes t)$ are identity isomorphisms, and all coherence squares
for a monoidal functor commute automatically.

*Proof.* By Lemma 4.2 the source and target of $\varepsilon$ and of each
$\mu_{s,t}$ coincide as objects, so we may take both to be identities. The
naturality of $\mu$ and the associativity and unitality coherence squares for a
monoidal functor are equalities of parallel morphisms in the thin category
$\mathsf{D}(\alpha)$, hence hold by Lemma 2.2. $\qquad\blacksquare$

## 5. The monoidal strictification theorem

**Definition 5.1 (Right-nested realization).** For a word $w = a_1 a_2 \cdots a_n$
in $\mathsf{F}(\alpha)$ define its *right-nested bracketing*
$\mathrm{rn}(w) \in \mathsf{P}(\alpha)$ by
$$\mathrm{rn}(1) = \mathrm{nil},\qquad
\mathrm{rn}(a_1 a_2\cdots a_n) = \mathrm{node}(\mathrm{leaf}(a_1), \mathrm{rn}(a_2\cdots a_n)).$$
This is the canonical "lean-right" tree spelling out $w$, and it induces a
functor $\mathrm{Rn}\colon \mathsf{D}(\alpha) \to \mathsf{P}(\alpha)$.

**Lemma 5.2 (Round trips).** For every word $w$, $\mathrm{flat}(\mathrm{rn}(w)) =
w$ exactly. For every tree $s$, $\mathrm{rn}(\mathrm{flat}(s))$ has the same
leaf-word as $s$, so there is a canonical (and, by thinness, unique) isomorphism
$s \cong \mathrm{rn}(\mathrm{flat}(s))$.

*Proof.* The first claim is a routine induction on $w$ (equivalently on the
length of the word), using $\mathrm{flat}(\mathrm{node}(\mathrm{leaf}(a), r)) =
a\cdot\mathrm{flat}(r)$. The second follows since both $s$ and
$\mathrm{rn}(\mathrm{flat}(s))$ flatten to $\mathrm{flat}(s)$, whence Lemma 3.5
supplies the isomorphism. $\qquad\blacksquare$

**Theorem 5.3 (Categorical equivalence).** The functors $\mathrm{Flat}$ and
$\mathrm{Rn}$ form an equivalence of categories
$$\mathsf{P}(\alpha) \;\simeq\; \mathsf{D}(\alpha).$$

*Proof.* By Lemma 5.2, $\mathrm{Flat}\circ\mathrm{Rn} = \mathrm{id}_{\mathsf{D}}$
on objects and (by thinness of $\mathsf{D}$) as functors, giving the counit as an
identity natural isomorphism; and $\mathrm{Rn}\circ\mathrm{Flat}$ is naturally
isomorphic to $\mathrm{id}_{\mathsf{P}}$ via the pointwise isomorphisms
$s \cong \mathrm{rn}(\mathrm{flat}(s))$, whose naturality is automatic since
$\mathsf{P}(\alpha)$ is thin. The triangle identities for the equivalence are
equalities of parallel morphisms in thin categories, hence hold. $\qquad\blacksquare$

**Theorem 5.4 (Monoidal strictification, this family).** The equivalence of
Theorem 5.3 is a **monoidal equivalence**:
$$\mathsf{P}(\alpha) \;\simeq_{\otimes}\; \mathsf{D}(\alpha).$$
Its underlying functor $\mathrm{Flat}$ is strong monoidal (Theorem 4.3), its
inverse $\mathrm{Rn}$ inherits a canonical strong monoidal structure, and the
unit and counit are monoidal natural isomorphisms. Consequently the non-strict
parenthesization category $\mathsf{P}(\alpha)$ is monoidally equivalent to the
strict skeleton $\mathsf{D}(\alpha)$ of words under concatenation.

*Proof.* $\mathrm{Flat}$ is strong monoidal by Theorem 4.3 and an equivalence by
Theorem 5.3. A strong monoidal functor that is an equivalence of categories
transports its monoidal structure to the inverse: one defines the tensorator and
unit comparison of $\mathrm{Rn}$ using those of $\mathrm{Flat}$ and the
(co)unit, and the required compatibility conditions are, once again, equalities
of parallel morphisms in the thin categories involved and therefore hold. The
unit and counit isomorphisms are monoidal because their monoidal-naturality
squares live in thin categories. $\qquad\blacksquare$

This is the promised concrete realization of **Mac Lane's strictification
theorem**: the loop-tolerant, non-strict $\mathsf{P}(\alpha)$ is
indistinguishable, as a monoidal category, from the loop-free strict
$\mathsf{D}(\alpha)$.

## 6. Contraction of the associator loop

**Theorem 6.1 (The loop collapses).** Under flattening the associator maps to an
identity-type morphism. Precisely, for all trees $a, b, c$,
$$\mathrm{Flat}(\alpha_{a,b,c}) = \mathrm{id}_{\mathrm{flat}(a)\,\mathrm{flat}(b)\,\mathrm{flat}(c)}$$
in $\mathsf{D}(\alpha)$ (more carefully, the coincidence morphism identifying the
two flattened endpoints, which agree as words).

*Proof.* The endpoints $(a\otimes b)\otimes c$ and $a\otimes(b\otimes c)$ flatten
to the equal words $(\mathrm{flat}\,a\cdot\mathrm{flat}\,b)\cdot\mathrm{flat}\,c$
and $\mathrm{flat}\,a\cdot(\mathrm{flat}\,b\cdot\mathrm{flat}\,c)$, which coincide
by associativity in $\mathsf{F}(\alpha)$. Thus in the thin category
$\mathsf{D}(\alpha)$ the image of $\alpha_{a,b,c}$ is a morphism between equal
objects, and there is only one such — the identity. $\qquad\blacksquare$

Thus the invertible $2$-cell that repaired associativity in $\mathsf{P}(\alpha)$
becomes trivial once the brackets are erased: the "causal loop" of reassociations
has been contracted to a point. This is the qualitative shadow of Theorem 5.4 —
strictification does not merely *permit* forgetting the associator; it exhibits
the associator as literally trivial in the strict model.

## 7. Algorithms

The development is entirely constructive, and the underlying operations are
finite and computable. We highlight three.

**Algorithm A (Flatten).** Given a tree, produce its leaf-word by an in-order
traversal that concatenates leaf labels; $\mathrm{nil}$ contributes the empty
word. Linear in the number of nodes.

**Algorithm B (Right-nested realization).** Given a word $w = a_1\cdots a_n$,
build $\mathrm{rn}(w)$ by folding from the right:
$\mathrm{node}(\mathrm{leaf}(a_1), \mathrm{node}(\mathrm{leaf}(a_2), \cdots))$.
Linear in $n$.

**Algorithm C (Reassociation morphism).** Given two trees $s, t$, decide whether
$\mathrm{flat}(s) = \mathrm{flat}(t)$ (compare their words); if so, return the
unique reassociation isomorphism $s \cong t$, obtained as the composite
$s \cong \mathrm{rn}(\mathrm{flat}(s)) = \mathrm{rn}(\mathrm{flat}(t)) \cong t$
through the common right-nested normal form. This is the concrete content of
coherence: *any* two reassociations of $s$ into $t$ compute the same result.

## 8. Applications and discussion

**Coherence as a design principle.** The thinness of $\mathsf{P}(\alpha)$ is not
an accident to be admired but a *criterion*. Theorem 2.3 isolates thinness as a
sufficient condition for automatic coherence, and the family here shows the
condition is met precisely because morphisms are "same-word certificates," which
are unique when they exist. This suggests a general recipe: to build a coherent
non-strict structure, choose morphisms to be witnesses of an equivalence
relation on objects that is preserved by the tensor.

**Normal forms and decision procedures.** The right-nested bracketing is a normal
form for objects up to isomorphism, and Algorithm C is a decision procedure for
"are these two bracketings canonically identified?" Isomorphism in
$\mathsf{P}(\alpha)$ is decidable and reduces to word equality — the concrete
combinatorial residue of Mac Lane coherence.

**Where non-strictness genuinely arises.** Monoidal categories model the
composition of processes: tensoring quantum systems, gluing cobordisms, stacking
computational stages, wiring circuits. In these settings the tensor is
associative only up to canonical isomorphism, exactly as here. Strictification
(Theorem 5.4) is what licenses the flat, bracket-free notations — string
diagrams, sequential pipelines — used throughout these fields: one silently
replaces the true non-strict category by its strict skeleton.

**A cautionary boundary.** Coherence is free *because* the category is thin. Drop
thinness and the pentagon can genuinely fail; a monoidal structure datum on a
non-thin category is not automatically coherent. The family here marks one side
of that boundary cleanly.

## 9. Future work

- **A braided or symmetric layer.** The strict target $\mathsf{D}(\alpha)$ is not
  braided in general, because concatenation of words is noncommutative. Passing to
  a commutative quotient — words up to permutation, i.e. multisets — yields a
  symmetric strict target; one can ask whether flattening promotes to a braided
  or symmetric monoidal functor onto this quotient.
- **Unitors and unit coherence.** A parallel analysis of the triangle and the unit
  laws within the same thin framework would clarify the Saavedra–Kelly redundancy
  of the unit axioms in this concrete setting.
- **Bicategorical delooping.** Feeding $\mathsf{P}(\alpha)$ through the standard
  delooping construction produces an explicit one-object bicategory whose
  horizontal composition is non-associative on the nose — a direct model of an
  "almost-category" in which composition only loops back up to a $2$-cell.
- **Non-thin obstructions.** Exhibiting a non-thin monoidal structure datum whose
  pentagon fails would quantify exactly how thinness is the boundary between free
  and obstructed coherence.
- **The free monoidal category.** $\mathsf{P}(\alpha)$ is, morally, the free
  monoidal category on the discrete category $\alpha$ *quotiented by coherence*,
  and the strictification exhibits its skeleton; making this identification precise
  relates the present family to the general free/strict adjunction.

## 10. Conclusion

We have built a monoidal category out of nothing but parenthesizations, made its
non-associativity honest at the level of objects, and then shown that thinness
renders all coherence automatic and forces a monoidal equivalence with a strict,
bracket-free skeleton. The associator, which carried genuine content in the
non-strict world, is contracted to an identity after strictification. The
parenthesization category is thus a complete, transparent laboratory model of Mac
Lane's coherence and strictification theorems — a place where one can watch the
causal loop of reassociations close up perfectly and then collapse.
