# Strictification of the Reassociation Groupoid: The Free Monoid as the Skeleton of Coherent Bracketing

## Abstract

We study *causal loops* in category theory — structures where a tensor product
or composition fails to be associative on the nose but is repaired by a canonical
invertible $2$-cell, with coherence holding automatically. We realize this
phenomenon concretely through the **parenthesization category** $\mathrm{PTree}(\alpha)$:
objects are binary trees (formal bracketings) with leaves labelled in an alphabet
$\alpha$, and a morphism $s \to t$ is a proof that $s$ and $t$ flatten to the same
underlying word. Associativity fails at the level of objects — the trees
$(a\cdot b)\cdot c$ and $a\cdot(b\cdot c)$ are genuinely distinct — yet the
category is *thin* (at most one morphism between any two objects) and a
*groupoid* (every morphism is invertible). Our central result is a
**strictification theorem**: $\mathrm{PTree}(\alpha)$ is equivalent, as a
category, to the discrete category $\mathrm{Disc}(\mathrm{List}\,\alpha)$ on words.
We prove this both by an explicit adjoint equivalence (flattening versus
right-nested normalization) and, independently, by verifying that the flattening
functor is fully faithful and essentially surjective. The equivalence carries the
non-strict tensor (tree-joining) to concatenation of words, exhibiting the free
monoid $(\mathrm{List}\,\alpha, \mathbin{+\!\!+}, [\,])$ as the *skeleton* of the
loop-tolerant tensor. Finally we connect the structure to a classical
enumeration: the number of bracketings of $n+1$ factors is the Catalan number
$C_n$, obeying the Segner convolution recurrence, and bracketings with equally
many factors are always isomorphic objects.

**Keywords:** monoidal category, coherence, strictification, groupoid, free
monoid, associativity, Catalan numbers, parenthesization, thin category,
equivalence of categories.

---

## 1. Introduction

### 1.1 Motivation

The associative law $(a\cdot b)\cdot c = a\cdot(b\cdot c)$ is so familiar that it
is easy to overlook a basic distinction: the two *expressions* it equates are not
the same syntactic object. One prescribes combining $a$ and $b$ first; the other,
$b$ and $c$ first. In arithmetic these different procedures land on the same
value, so we suppress parentheses entirely. But the moment one refuses to
identify computations with their outputs — as one must in category theory, type
theory, and the theory of higher structures — associativity ceases to be an
equation between objects and becomes instead a *comparison morphism*, the
**associator**, relating two genuinely distinct constructions.

A monoidal category is precisely a category equipped with a tensor product
$\otimes$ that is associative only *up to* a natural isomorphism
$\alpha_{X,Y,Z}\colon (X\otimes Y)\otimes Z \xrightarrow{\ \sim\ } X\otimes(Y\otimes Z)$,
subject to Mac Lane's *pentagon* coherence condition. Mac Lane's coherence
theorem then guarantees that *all* formal diagrams built from associators
commute: there is essentially a unique way to reassociate. This is the sense in
which "composition loops back" — the associator is a canonical $2$-cell that
repairs the failure of on-the-nose associativity, and coherence is the statement
that these repairs are globally consistent.

The goal of this paper is to isolate this phenomenon in its purest, most
transparent instance and to prove a **strictification theorem** for it: a
statement that the coherent-but-non-strict world is equivalent to a fully strict
one, so that nothing is lost by collapsing all the canonical reassociation
$2$-cells.

### 1.2 Contributions

Working over an arbitrary alphabet $\alpha$, we:

1. Construct the **parenthesization category** $\mathrm{PTree}(\alpha)$ of formal
   bracketings, with morphisms recording sameness of underlying word
   (Section 2).
2. Prove it is **thin** and a **groupoid**, and that *coherence equals
   connectedness*: two bracketings are isomorphic iff they flatten to the same
   word (Section 3).
3. Prove the **strictification theorem** $\mathrm{PTree}(\alpha)\simeq
   \mathrm{Disc}(\mathrm{List}\,\alpha)$ via an explicit equivalence, and again,
   independently, via the fully-faithful-plus-essentially-surjective criterion
   (Section 4).
4. Show the equivalence carries the non-strict tensor to concatenation, so the
   **free monoid is the skeleton** of the loop-tolerant tensor (Section 5).
5. Enumerate the loops: the census of bracketings is the **Catalan sequence**,
   satisfying the **Segner convolution recurrence**, and equinumerous
   bracketings are isomorphic (Section 6).

---

## 2. The parenthesization category

### 2.1 Trees and words

Fix a type (alphabet) $\alpha$.

> **Definition 2.1 (Parenthesization trees).** The type $\mathrm{PTree}(\alpha)$
> of *parenthesization trees* over $\alpha$ is generated inductively by:
> - $\mathrm{nil}$, the empty tree;
> - $\mathrm{leaf}(a)$ for each $a\in\alpha$, a single labelled leaf;
> - $\mathrm{node}(s, t)$ for trees $s, t$, the formal bracketed product,
>   written $s\cdot t$.

A tree is a *formal parenthesization*: $\mathrm{node}(s,t)$ is the bracketed
product $(s\cdot t)$, recording explicitly which subexpressions are combined and
in which order.

> **Definition 2.2 (Flattening).** The *underlying word* of a tree is the list of
> its leaves read left to right, defined recursively by
> $$
> \operatorname{flatten}(\mathrm{nil}) = [\,],\quad
> \operatorname{flatten}(\mathrm{leaf}\,a) = [a],\quad
> \operatorname{flatten}(\mathrm{node}\,s\,t) = \operatorname{flatten}(s)\mathbin{+\!\!+}\operatorname{flatten}(t),
> $$
> where $\mathbin{+\!\!+}$ denotes list concatenation.

Flattening forgets the bracketing and retains only the ordered multiset of
ingredients.

### 2.2 The category structure

> **Definition 2.3 (Parenthesization category).** The category
> $\mathrm{PTree}(\alpha)$ has parenthesization trees as objects, and a morphism
> $s \to t$ is a proof that $\operatorname{flatten}(s) = \operatorname{flatten}(t)$.
> The identity on $s$ is the reflexivity proof, and composition of $f\colon s\to t$
> and $g\colon t\to u$ is the transitivity proof concatenating the two equalities.

Concretely, the hom-set $\operatorname{Hom}(s,t)$ is inhabited precisely when $s$
and $t$ share a word, and then it is a singleton. The categorical axioms hold
because equality is reflexive, transitive, and its proofs are canonical.

This is the concrete model of the "causal loop": the objects distinguish
bracketings, but the morphisms testify that all bracketings of a common word are
interchangeable — the associator and all its iterates are subsumed into these
sameness-of-word witnesses.

---

## 3. Thinness, groupoid structure, and coherence

Two structural facts drive everything that follows.

> **Proposition 3.1 (Thinness).** $\mathrm{PTree}(\alpha)$ is *thin*: for all
> objects $s, t$, any two morphisms $f, g\colon s\to t$ are equal.

*Proof sketch.* A morphism is a proof of the proposition
$\operatorname{flatten}(s)=\operatorname{flatten}(t)$. Equality proofs of a fixed
proposition are unique (proof irrelevance), so any two parallel morphisms
coincide. $\square$

> **Proposition 3.2 (Groupoid).** Every morphism of $\mathrm{PTree}(\alpha)$ is
> an isomorphism; the category is a groupoid.

*Proof sketch.* If $f\colon s\to t$ witnesses
$\operatorname{flatten}(s)=\operatorname{flatten}(t)$, then the symmetric proof
witnesses $\operatorname{flatten}(t)=\operatorname{flatten}(s)$ and hence gives a
morphism $t\to s$. The two round-trip composites are parallel to identities and
so equal to them by thinness. $\square$

These combine into the paper's organizing principle.

> **Theorem 3.3 (Coherence is connectedness).** For all trees $s, t$,
> $$
> \exists\ (s \cong t)\quad\Longleftrightarrow\quad \operatorname{flatten}(s)=\operatorname{flatten}(t).
> $$
> That is, two bracketings are isomorphic exactly when they have the same
> underlying word.

*Proof sketch.* ($\Rightarrow$) An isomorphism $s\cong t$ contains in particular
a morphism $s\to t$, i.e. a proof of the word equality. ($\Leftarrow$) Given such
a proof $h$, the pair $(h, h^{-1})$ forms an isomorphism, its coherence conditions
holding automatically by thinness. $\square$

Theorem 3.3 is the transparent form of Mac Lane coherence in this setting: the
isomorphism class of a bracketing remembers exactly its word and nothing about
its shape, and there is never more than one isomorphism to choose. In particular:

> **Corollary 3.4 (Genuine non-strictness).** The objects $\mathrm{node}(\mathrm{node}(a,b),c)$
> and $\mathrm{node}(a,\mathrm{node}(b,c))$ are distinct, yet canonically
> isomorphic.

*Proof sketch.* Distinctness is a structural fact about the inductive type:
equating the two trees would force a proper subtree to equal the whole, a size
contradiction. Canonical isomorphism follows from Theorem 3.3 since both flatten
to $[a,b,c]$. $\square$

### 3.1 Normal forms

> **Definition 3.5 (Right-nested normal form).** For a word
> $\ell = [a_1, \dots, a_n]$, its *right-nested bracketing* is
> $$
> \mathrm{ofList}(\ell) = a_1\cdot(a_2\cdot(\cdots\cdot(a_n\cdot\mathrm{nil}))),
> $$
> defined recursively by $\mathrm{ofList}([\,]) = \mathrm{nil}$ and
> $\mathrm{ofList}(a::\ell') = \mathrm{node}(\mathrm{leaf}\,a, \mathrm{ofList}(\ell'))$.

> **Lemma 3.6 (Section property).** $\operatorname{flatten}(\mathrm{ofList}(\ell)) = \ell$
> for every word $\ell$.

*Proof sketch.* Induction on $\ell$; the cons step uses
$\operatorname{flatten}(\mathrm{node}(\mathrm{leaf}\,a, r)) = [a]\mathbin{+\!\!+}\operatorname{flatten}(r)$. $\square$

Consequently every tree $s$ is canonically isomorphic to $\mathrm{ofList}(\operatorname{flatten}(s))$,
its normal form — the concrete, thin incarnation of coherence.

---

## 4. The strictification theorem

Let $\mathrm{Disc}(\mathrm{List}\,\alpha)$ denote the **discrete category** on
words: objects are words, and the only morphisms are identities. This is the
strictest imaginable category — an inert set viewed as a category.

### 4.1 The two functors

> **Definition 4.1 (Flattening functor $F$).** Define
> $F\colon \mathrm{PTree}(\alpha)\to\mathrm{Disc}(\mathrm{List}\,\alpha)$ on objects by
> $F(s) = \operatorname{flatten}(s)$ and on a morphism $f\colon s\to t$ (a proof
> $\operatorname{flatten}(s)=\operatorname{flatten}(t)$) by the corresponding
> identification in the discrete category.

> **Definition 4.2 (Normalization functor $G$).** Define
> $G\colon \mathrm{Disc}(\mathrm{List}\,\alpha)\to\mathrm{PTree}(\alpha)$ on objects
> by $G(\ell) = \mathrm{ofList}(\ell)$ and on identities by identities.

Functoriality of both is automatic: on morphisms there is nothing to check beyond
what thinness (in $\mathrm{PTree}$) and discreteness (in the target) already
force.

### 4.2 The equivalence

> **Theorem 4.3 (Strictification).** The functors $F$ and $G$ form an equivalence
> of categories
> $$
> \mathrm{PTree}(\alpha)\ \simeq\ \mathrm{Disc}(\mathrm{List}\,\alpha).
> $$

*Proof sketch.* We exhibit unit and counit natural isomorphisms.

- **Counit.** $F\circ G$ sends a word $\ell$ to
  $\operatorname{flatten}(\mathrm{ofList}(\ell)) = \ell$ by Lemma 3.6, so
  $F\circ G = \mathrm{id}$ on the nose; the counit is the identity natural
  isomorphism.
- **Unit.** $G\circ F$ sends a tree $s$ to $\mathrm{ofList}(\operatorname{flatten}(s))$,
  its normal form, which is canonically isomorphic to $s$ by Theorem 3.3
  (both flatten to $\operatorname{flatten}(s)$). These isomorphisms assemble into a
  natural isomorphism $\mathrm{id}\Rightarrow G\circ F$; naturality is automatic
  by thinness.
- The triangle identity $F\varepsilon \circ \eta F = \mathrm{id}$ holds
  automatically, again by thinness of the target's relevant hom-sets. $\square$

### 4.3 An independent proof via the standard criterion

The equivalence can also be certified by the classical criterion: a functor is an
equivalence iff it is *fully faithful* and *essentially surjective*.

> **Proposition 4.4 ($F$ is faithful).** $F$ is faithful.

*Proof sketch.* Immediate from thinness of $\mathrm{PTree}(\alpha)$: parallel
morphisms are already equal, so no map can identify distinct ones. $\square$

> **Proposition 4.5 ($F$ is full).** $F$ is full.

*Proof sketch.* A morphism $F(s)\to F(t)$ in the discrete category exists only
when $\operatorname{flatten}(s) = \operatorname{flatten}(t)$, and is then the
identity. That equality is exactly the data of a morphism $s\to t$ in
$\mathrm{PTree}(\alpha)$ mapping onto it. $\square$

> **Proposition 4.6 ($F$ is essentially surjective).** $F$ is essentially
> surjective.

*Proof sketch.* Any word $\ell$ is $F(\mathrm{ofList}(\ell))$ up to the identity
isomorphism, by Lemma 3.6. $\square$

> **Corollary 4.7.** $F$ is an equivalence of categories, reproving Theorem 4.3.

Both routes make the same point: the flattening functor forgets *nothing
essential*. The apparent complexity of the reassociation groupoid is entirely
contained in redundant, canonically invertible morphisms.

---

## 5. The free monoid as skeleton

The strictification is not merely an equivalence of bare categories; it respects
the operation that makes the story monoidal.

> **Proposition 5.1 (Tensor becomes concatenation).** For all trees $s, t$,
> $$
> \operatorname{flatten}(\mathrm{node}(s,t)) = \operatorname{flatten}(s)\ \mathbin{+\!\!+}\ \operatorname{flatten}(t).
> $$
> Equivalently, $F$ carries the non-strict tensor $\mathrm{node}$ to
> concatenation of words.

*Proof sketch.* This is the defining clause of $\operatorname{flatten}$ on
$\mathrm{node}$. $\square$

> **Proposition 5.2 (Normalization is monoidal on words).**
> $\mathrm{ofList}(x\mathbin{+\!\!+}y)$ and $\mathrm{node}(\mathrm{ofList}(x),\mathrm{ofList}(y))$
> flatten to the same word, hence are canonically isomorphic in
> $\mathrm{PTree}(\alpha)$.

*Proof sketch.* Both flatten to $x\mathbin{+\!\!+}y$ (using Lemma 3.6 and
Proposition 5.1), so Theorem 3.3 supplies the isomorphism. $\square$

Together these say that the equivalence of Theorem 4.3 transports the loop-tolerant
tensor product exactly onto the strictly associative concatenation of words.

> **Interpretation (Skeleton = free monoid).** The *skeleton* of a category — a
> maximal full subcategory with one object per isomorphism class — records the
> essential content after removing redundant isomorphic copies. By Theorem 3.3,
> the isomorphism classes of $\mathrm{PTree}(\alpha)$ are exactly the words, and by
> Propositions 5.1–5.2 the induced operation on classes is concatenation with unit
> the empty word. Hence the skeleton is precisely the **free monoid**
> $(\mathrm{List}\,\alpha,\ \mathbin{+\!\!+},\ [\,])$ on $\alpha$.

This is the rigorous meaning of the slogan *"when composition loops back, its
skeleton is the free monoid."* The associativity that fails on the nose, together
with all the canonical $2$-cells repairing it, collapses to the strictly
associative, boringly perfect concatenation of lists.

---

## 6. The census of loops: Catalan enumeration

We turn from structure to enumeration. Consider *shapes* — parenthesization trees
regarded up to relabelling, i.e. counted by their number of leaves (factors).

> **Theorem 6.1 (Catalan census).** The number of distinct bracketings (binary-tree
> shapes) of $n+1$ factors equals the Catalan number $C_n$, where
> $$
> C_n = \frac{1}{n+1}\binom{2n}{n} = 1, 1, 2, 5, 14, 42, 132, \dots \quad(n = 0, 1, 2, \dots).
> $$

*Proof sketch.* A bracketing of $n+1$ factors is either a single leaf (when
$n=0$) or a top node splitting the factors into a left group of $i+1$ and a right
group of $(n-i)$ factors. This bijection between bracketings and pairs of
sub-bracketings is exactly the combinatorial content of the Catalan recurrence. $\square$

> **Theorem 6.2 (Segner convolution recurrence).** The census $c(n)$ of
> bracketings of $n+1$ factors satisfies
> $$
> c(n+1) = \sum_{i=0}^{n} c(i)\, c(n-i),\qquad c(0)=1.
> $$

*Proof sketch.* Split a bracketing of $(n+2)$ factors at its outermost node into a
left bracketing of $(i+1)$ factors and a right bracketing of $(n-i+1)$ factors;
sum over $i$. This is Segner's classical eighteenth-century recurrence for the
Catalan numbers, matching the census term-by-term. $\square$

Finally, enumeration meets structure:

> **Proposition 6.3 (Equinumerous bracketings are isomorphic).** Any two
> bracketings with the same number of factors (over a common list of leaf labels)
> flatten to the same word and are therefore isomorphic objects of
> $\mathrm{PTree}(\alpha)$.

*Proof sketch.* If both bracket the same ordered list of labels, their flattenings
agree, so Theorem 3.3 applies. $\square$

Thus the Catalan multitude of shapes, vast and classically structured, collapses —
for each fixed word — to a single isomorphism class, consistent with the
strictification of Section 4.

---

## 7. Algorithms

The constructive content yields simple, total algorithms.

**Flattening.** Given a tree, compute its word by a post-order traversal
concatenating leaf lists; linear in the number of nodes.

**Right-nested normalization.** Given a word, fold from the right building
$\mathrm{ofList}$; linear in word length. Composed with flattening, this computes
a canonical representative of each isomorphism class — an explicit witness of the
skeleton map.

**Catalan census.** Compute $c(n)$ by dynamic programming on the Segner
convolution, in $O(n^2)$ arithmetic operations, or in closed form via
$C_n = \binom{2n}{n}/(n+1)$.

**Bracketing enumeration.** Generate all bracketings of $n$ factors recursively by
splitting at every top-node position, cross-producing left and right sub-lists;
the number produced is $C_{n-1}$, providing an executable check of Theorem 6.1.

---

## 8. Applications and discussion

**Compiler optimization and parallelism.** Reassociating a long chain of an
associative operation into a balanced tree enables parallel evaluation. The
coherence proved here — that the result is independent of bracketing, with a
unique canonical translation between any two — is the correctness guarantee such
transformations rely on.

**Type theory and dependent equality.** By modelling morphisms as equality proofs,
the development makes the *proof-irrelevance* of associativity witnesses the
engine of the whole theorem. This is a template for turning coherence problems
into thinness observations.

**Higher category theory.** Strictification theorems govern when structures
associative "up to coherent isomorphism" can be replaced by strictly associative
ones. Our result is the base case in its most transparent form and a sanity check
for more elaborate coherence theorems.

**Process theories and physics.** In categorical models of composing systems, the
freedom to rebracket a composite without changing its meaning — provided the
rebracketing is canonical — is exactly the content of Theorem 3.3.

---

## 9. Future directions

Several natural extensions remain open.

1. **Monoidal strictification.** Upgrade the equivalence of Theorem 4.3 to a
   *monoidal* equivalence, endowing $\mathrm{Disc}(\mathrm{List}\,\alpha)$ with its
   strict monoidal structure from concatenation. Thinness should again render all
   coherence data automatic.
2. **Bicategorical form.** Package the $\mathrm{PTree}$ families over a base as a
   genuine bicategory and prove a $2$-categorical strictification.
3. **Tamari lattice.** Refine the discrete groupoid $\mathrm{PTree}(\alpha)$ to the
   Tamari order by retaining only right-rotations, and relate the resulting poset
   to the associahedron.
4. **Beyond thinness.** Replace the thin hypothesis by a weaker "unique-associator"
   axiom and characterize exactly when coherence still holds.

---

## 10. Conclusion

We have exhibited, in its cleanest form, the passage from a coherent-but-non-strict
tensor to a strictly associative one. The parenthesization category
$\mathrm{PTree}(\alpha)$ makes the failure of associativity concrete — distinct
bracketings are distinct objects — while a single design choice, defining
morphisms as sameness-of-word proofs, makes the category thin and a groupoid, so
that coherence reduces to connectedness. The resulting strictification identifies
$\mathrm{PTree}(\alpha)$ with the discrete category of words and its skeleton with
the free monoid, carrying the non-strict tensor to concatenation. Enumeration
places the construction alongside the Catalan numbers and the Segner recurrence.
The causal loops of reassociation, far from paradoxical, resolve into the most
elementary algebraic object of all: a list of ingredients, combined in order.
