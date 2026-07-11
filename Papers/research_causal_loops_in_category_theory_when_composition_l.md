# Causal Loops in Category Theory: A Concrete Non-Strict Monoidal Category of Parenthesizations

## Abstract

We construct an explicit, fully elementary monoidal category whose tensor product fails to
be associative *on the nose* yet is repaired by a canonical invertible associator, and in
which all of the Mac Lane coherence data holds automatically. The objects of the category
are binary trees with labelled leaves — formal parenthesizations of words — and a morphism
between two trees is a proof that they have the same underlying leaf-word. This category is
**thin** (at most one morphism between any two objects) and a **groupoid** (every morphism
invertible). We prove three things. First, a general structural principle: *any* choice of
tensor data on a thin category automatically satisfies the pentagon, the triangle, and all
naturality axioms, so that coherence is free. Second, the concrete realization: on the
parenthesization trees the two bracketings $(a\otimes b)\otimes c$ and $a\otimes(b\otimes c)$
are genuinely distinct objects joined by a unique associator isomorphism, so the category is
a non-strict monoidal category. Third, a strictification result: every bracketing is
canonically isomorphic to a right-nested normal form, two bracketings are isomorphic iff
they share an underlying word, and the whole category is equivalent to the discrete category
of words. This gives a hands-on, end-to-end model of the slogan *a coherent
loop-tolerant algebraic structure is equivalent to a strict one*, and a miniature laboratory
for the phenomenon of associativity holding only up to coherent isomorphism.

**Keywords.** monoidal category, associator, pentagon identity, coherence, thin category,
strictification, parenthesization, Catalan structures, binary trees.

---

## 1. Introduction

### 1.1 Motivation

The associative law $(a\cdot b)\cdot c = a\cdot(b\cdot c)$ is usually treated as an equation:
two ways of grouping a product yield the same result. In higher category theory one takes a
more refined stance. The two groupings are regarded as *distinct objects*, and the
associative law is upgraded from an *equation* to a *specified invertible transformation* —
the **associator** — witnessing that the two groupings are canonically isomorphic. This is
the defining move of a **monoidal category**: a category equipped with a tensor product that
is associative and unital only *up to coherent natural isomorphism*.

The price of this freedom is **coherence**. Once associativity is an isomorphism rather than
an equation, one must ensure that all the different ways of re-bracketing a long product
agree. Mac Lane's coherence theorem isolates two conditions — the **pentagon** and the
**triangle** — from which all others follow, and guarantees that every formal diagram built
from associators and unitors commutes.

This paper isolates the phenomenon in its purest concrete form. We build a monoidal category
directly out of parenthesizations, in which:

1. associativity **fails** as a literal equality of objects;
2. the failure is **repaired** by a canonical, and in fact unique, associator; and
3. all coherence is **automatic**, because the category is thin.

We then show that the resulting structure, for all its apparent richness, **collapses**: it
is categorically equivalent to the discrete (strict, loop-free) category of underlying words.
This is a concrete, verifiable instance of Mac Lane's strictification theorem.

### 1.2 The guiding metaphor

We think of a parenthesization as recording *how a composite computation is grouped*, and of
the associator as recording *how composition loops back on itself* when the grouping is
changed. The central conceptual claim is that when these loops are *coherent* — when the
transformations recording re-association are rigid enough to be unique — the loop closes
harmlessly: travelling out and back around a re-association cycle returns the identity. We
make this precise below (Theorem 3.5) as the statement that a certain composite of associators
around the pentagon equals the identity.

### 1.3 Contributions and organization

- **Section 2** develops the abstract engine: thin categories and the principle that
  coherence is free on them (Theorem 2.4).
- **Section 3** constructs the parenthesization category, endows it with a monoidal
  structure, and proves that it is non-strict with a unique associator (Theorems 3.2–3.5).
- **Section 4** proves strictification: normal forms, the isomorphism criterion, the
  flattening functor, and the equivalence to the discrete category of words
  (Theorems 4.1–4.4).
- **Section 5** gives algorithms and numerical illustrations.
- **Sections 6–7** discuss applications and future directions.

---

## 2. Coherence from thinness

### 2.1 Thin categories

**Definition 2.1 (Thin category).** A category $\mathcal C$ is **thin** if for every pair of
objects $X, Y$ the hom-set $\mathcal C(X,Y)$ has at most one element; equivalently, any two
parallel morphisms $f, g\colon X\to Y$ are equal. A thin category is the same data as a
preorder viewed as a category.

The defining property has an immediate and powerful consequence.

**Proposition 2.2 (Every diagram commutes).** In a thin category, any two morphisms with the
same source and target are equal. Consequently every diagram of morphisms commutes.

*Proof.* Immediate from Definition 2.1: two parallel morphisms are equal, and a diagram
commutes iff certain parallel composites are equal. $\qquad\blacksquare$

**Proposition 2.3 (Isomorphisms are unique).** In a thin category, between any two objects
$X, Y$ there is at most one isomorphism; an isomorphism carries no information beyond its
existence.

*Proof.* Two isomorphisms $X\cong Y$ have equal underlying forward morphisms by thinness, and
an isomorphism is determined by its forward morphism (its inverse is forced). $\qquad\blacksquare$

### 2.2 The free-coherence principle

Recall that a **monoidal category structure** on $\mathcal C$ consists of a tensor product
bifunctor $\otimes$, a unit object $\mathbf 1$, and natural isomorphisms — the associator
$\alpha_{X,Y,Z}\colon (X\otimes Y)\otimes Z\cong X\otimes(Y\otimes Z)$, the left unitor
$\lambda_X\colon \mathbf 1\otimes X\cong X$, and the right unitor
$\rho_X\colon X\otimes\mathbf 1\cong X$ — subject to the **pentagon** and **triangle** axioms
and the naturality of $\alpha,\lambda,\rho$. A bare choice of such data *without* the axioms
we call a **monoidal structure datum**.

**Theorem 2.4 (Coherence is free on a thin category).** Let $\mathcal C$ be a thin category
equipped with any monoidal structure datum (a tensor product, a unit, and associator/unitor
isomorphisms). Then the datum automatically satisfies the pentagon identity, the triangle
identity, and every naturality condition; that is, $\mathcal C$ is a genuine monoidal
category.

*Proof.* Each axiom asserts the equality of two morphisms sharing a common source and target.
By Proposition 2.2 any such equality holds automatically. Concretely: the pentagon equates two
morphisms $((W\otimes X)\otimes Y)\otimes Z \to W\otimes(X\otimes(Y\otimes Z))$; the triangle
equates two morphisms $(X\otimes\mathbf 1)\otimes Y \to X\otimes Y$; each naturality square
equates two morphisms with common endpoints. All hold by thinness. $\qquad\blacksquare$

Two axioms are worth stating explicitly, as they are the coherence conditions of interest.

**Corollary 2.5 (Pentagon).** In any monoidal structure datum on a thin category, for all
objects $W, X, Y, Z$,
$$
(\alpha_{W,X,Y}\otimes \mathrm{id}_Z)\;\circ\;\alpha_{W, X\otimes Y, Z}\;\circ\;(\mathrm{id}_W\otimes \alpha_{X,Y,Z})
\;=\;
\alpha_{W\otimes X, Y, Z}\;\circ\;\alpha_{W, X, Y\otimes Z}.
$$

**Corollary 2.6 (Triangle).** In any monoidal structure datum on a thin category, for all
objects $X, Y$,
$$
\alpha_{X,\mathbf 1,Y}\;\circ\;(\mathrm{id}_X\otimes \lambda_Y)\;=\;\rho_X\otimes \mathrm{id}_Y.
$$

Both follow from Theorem 2.4.

**Theorem 2.7 (The causal loop closes to the identity).** Fix objects $W, X, Y, Z$ in a thin
monoidal category. Travel from $((W\otimes X)\otimes Y)\otimes Z$ to
$W\otimes(X\otimes(Y\otimes Z))$ along the long (three-step) side of the pentagon, then return
to the start along the inverse of the short (two-step) side. The resulting round trip is the
identity:
$$
\Big[(\alpha_{W,X,Y}\otimes\mathrm{id}_Z)\circ\alpha_{W,X\otimes Y,Z}\circ(\mathrm{id}_W\otimes\alpha_{X,Y,Z})\Big]
\circ\Big[\alpha_{W\otimes X,Y,Z}\circ\alpha_{W,X,Y\otimes Z}\Big]^{-1}
=\mathrm{id}.
$$

*Proof.* Both sides are endomorphisms of $((W\otimes X)\otimes Y)\otimes Z$; by thinness they
are equal, and the identity is such an endomorphism. (Equivalently, apply the pentagon,
Corollary 2.5, and cancel.) $\qquad\blacksquare$

This is the abstract form of the mission's slogan: *when composition loops back, it loops back
to where it started.*

---

## 3. The parenthesization category

### 3.1 Objects, morphisms, and thinness

Fix a set $\alpha$ of leaf labels.

**Definition 3.1 (Parenthesization trees).** The set $\mathrm{PTree}(\alpha)$ of
**parenthesization trees** over $\alpha$ is generated inductively by:
- an empty tree $\mathrm{nil}$;
- a leaf $\mathrm{leaf}(a)$ for each label $a\in\alpha$;
- a node $\mathrm{node}(s,t)$ for any two trees $s, t$.

We read $\mathrm{node}(s,t)$ as the formal bracketed product $(s\cdot t)$. The **flattening**
map $\mathrm{flatten}\colon \mathrm{PTree}(\alpha)\to \mathrm{List}(\alpha)$ forgets the
bracketing:
$$
\mathrm{flatten}(\mathrm{nil})=[\,],\qquad
\mathrm{flatten}(\mathrm{leaf}(a))=[a],\qquad
\mathrm{flatten}(\mathrm{node}(s,t))=\mathrm{flatten}(s)\mathbin{+\!\!+}\mathrm{flatten}(t),
$$
where $+\!\!+$ denotes list concatenation.

**Definition 3.2 (The parenthesization category).** Let the objects be parenthesization trees.
For trees $s, t$ define the hom-set
$$
\mathcal P(s,t)\;=\;\{\text{proofs of } \mathrm{flatten}(s)=\mathrm{flatten}(t)\},
$$
a set with at most one element. Composition is transitivity of equality; the identity on $s$
is reflexivity of $\mathrm{flatten}(s)=\mathrm{flatten}(s)$. This defines a category, the
**parenthesization category** $\mathcal P(\alpha)$.

**Theorem 3.1 (Thin groupoid).** The category $\mathcal P(\alpha)$ is thin, and it is a
groupoid: every morphism is invertible.

*Proof.* Thinness holds because a hom-set is a set of proofs of a single equation, hence a
subsingleton. Given $f\colon s\to t$, i.e. a proof $\mathrm{flatten}(s)=\mathrm{flatten}(t)$,
its symmetric proof gives $f^{-1}\colon t\to s$; the two composites are identities by
thinness. $\qquad\blacksquare$

Because $\mathcal P(\alpha)$ is thin, Theorem 2.4 applies to *any* monoidal datum we place on
it.

### 3.2 The monoidal structure

**Definition 3.3 (Tensor datum).** Define on $\mathcal P(\alpha)$:
- **tensor of objects:** $s\otimes t := \mathrm{node}(s,t)$;
- **unit:** $\mathbf 1 := \mathrm{nil}$;
- **whiskering:** for $f\colon s\to t$, the morphisms $X\otimes f$ and $f\otimes Y$ are the
  evident equalities obtained by concatenating $\mathrm{flatten}(X)$ on the left, or
  $\mathrm{flatten}(Y)$ on the right, of the equation underlying $f$;
- **associator:** $\alpha_{a,b,c}\colon (a\otimes b)\otimes c \to a\otimes(b\otimes c)$, the
  morphism witnessed by the associativity of list concatenation,
  $(\mathrm{flatten}(a)+\!\!+\mathrm{flatten}(b))+\!\!+\mathrm{flatten}(c)
   = \mathrm{flatten}(a)+\!\!+(\mathrm{flatten}(b)+\!\!+\mathrm{flatten}(c))$;
- **unitors:** $\lambda_a\colon \mathbf 1\otimes a\to a$ and $\rho_a\colon a\otimes\mathbf 1\to a$,
  from $[\,]+\!\!+\ell=\ell$ and $\ell+\!\!+[\,]=\ell$ respectively.

**Theorem 3.2 (Monoidal category).** With the datum of Definition 3.3, $\mathcal P(\alpha)$ is
a monoidal category. In particular the pentagon, triangle and all naturality axioms hold.

*Proof.* $\mathcal P(\alpha)$ is thin (Theorem 3.1), so Theorem 2.4 supplies every axiom for
free. $\qquad\blacksquare$

### 3.3 Non-strictness and uniqueness of the associator

**Theorem 3.3 (Associativity fails on the nose).** For all trees $a, b, c$, the objects
$(a\otimes b)\otimes c$ and $a\otimes(b\otimes c)$ are distinct.

*Proof.* Suppose $\mathrm{node}(\mathrm{node}(a,b),c)=\mathrm{node}(a,\mathrm{node}(b,c))$.
Comparing first components forces $\mathrm{node}(a,b)=a$, i.e. a tree equal to a proper subtree
of itself. Comparing sizes, $\mathrm{size}(\mathrm{node}(a,b))=\mathrm{size}(a)$ while
$\mathrm{size}(\mathrm{node}(a,b))=\mathrm{size}(a)+\mathrm{size}(b)+1>\mathrm{size}(a)$, a
contradiction. $\qquad\blacksquare$

**Corollary 3.4 (Non-strict).** $\mathcal P(\alpha)$ is not a strict monoidal category: there
exist objects (e.g. $a=b=c=\mathrm{nil}$) for which the source and target of the associator
differ, so the associator cannot be an identity.

Despite this, the associator is completely canonical.

**Theorem 3.5 (Uniqueness of the associator).** For all $a, b, c$, the associator
$\alpha_{a,b,c}$ is the *unique* isomorphism $(a\otimes b)\otimes c\cong a\otimes(b\otimes c)$.

*Proof.* $\mathcal P(\alpha)$ is thin, so by Proposition 2.3 there is at most one isomorphism
between any two objects; $\alpha_{a,b,c}$ is one, hence the only one. $\qquad\blacksquare$

Together, Theorems 3.3–3.5 realize the target phenomenon: associativity fails literally, but
its failure is repaired by a canonical and unique invertible $2$-cell, with coherence holding
automatically.

---

## 4. Strictification: collapsing the loops

We now show that all of this apparent structure is, up to equivalence, strict.

**Definition 4.1 (Normal form).** For a word $\ell\in\mathrm{List}(\alpha)$ define the
**right-nested tree** $\mathrm{ofList}(\ell)$ by
$$
\mathrm{ofList}([\,])=\mathrm{nil},\qquad
\mathrm{ofList}(a::\ell')=\mathrm{node}(\mathrm{leaf}(a),\,\mathrm{ofList}(\ell')).
$$
It satisfies $\mathrm{flatten}(\mathrm{ofList}(\ell))=\ell$, so $\mathrm{ofList}$ is a section
of $\mathrm{flatten}$ and picks a canonical bracketing for each word.

**Theorem 4.1 (Normalization).** Every tree $s$ is canonically isomorphic to its normal form:
there is an isomorphism $s\cong \mathrm{ofList}(\mathrm{flatten}(s))$. In particular, all
bracketings of a fixed word are canonically — and, by thinness, uniquely — isomorphic. This is
Mac Lane's coherence theorem in concrete form for this family.

*Proof.* Since $\mathrm{flatten}(\mathrm{ofList}(\mathrm{flatten}(s)))=\mathrm{flatten}(s)$,
the equation of words gives a morphism $s\to \mathrm{ofList}(\mathrm{flatten}(s))$, which is an
isomorphism because $\mathcal P(\alpha)$ is a groupoid; uniqueness is Proposition 2.3.
$\qquad\blacksquare$

**Theorem 4.2 (Isomorphism criterion).** Two trees $s, t$ are isomorphic if and only if
$\mathrm{flatten}(s)=\mathrm{flatten}(t)$. The isomorphism class of a bracketing remembers only
its underlying word, not how it is parenthesized.

*Proof.* An isomorphism $s\cong t$ yields a morphism $s\to t$, i.e. a proof
$\mathrm{flatten}(s)=\mathrm{flatten}(t)$. Conversely such a proof is a morphism, and every
morphism is invertible (Theorem 3.1). $\qquad\blacksquare$

**Definition 4.2 (Flattening functor).** Let $\mathrm{Disc}(\mathrm{List}(\alpha))$ denote the
**discrete category** on words: objects are words, and the only morphisms are identities. Define
the **flattening functor**
$$
F\colon \mathcal P(\alpha)\to \mathrm{Disc}(\mathrm{List}(\alpha)),\qquad
F(s)=\mathrm{flatten}(s),
$$
sending each morphism (an equality of words) to the corresponding identity-type morphism in the
discrete target.

**Theorem 4.3 (The loop is contracted).** Under $F$ the associator becomes an identity-type
morphism: $F(\alpha_{a,b,c})$ is the identity morphism on the common word
$\mathrm{flatten}(a)+\!\!+\mathrm{flatten}(b)+\!\!+\mathrm{flatten}(c)$. Strictification unbends
the associator loop.

*Proof.* In the discrete category every hom-set is a subsingleton (each is empty or a single
identity), so any two parallel morphisms coincide; $F(\alpha_{a,b,c})$ and the relevant
identity are parallel. $\qquad\blacksquare$

**Theorem 4.4 (Strictification / equivalence to the strict skeleton).** The flattening functor
is an equivalence of categories,
$$
\mathcal P(\alpha)\;\simeq\;\mathrm{Disc}(\mathrm{List}(\alpha)),
$$
with inverse $G=\mathrm{ofList}$ (the normal-form functor). The entire non-strict monoidal
structure — an object for every bracketing, an associator loop connecting them — is, up to
equivalence, the strict discrete category of words.

*Proof.* Take $G\colon \mathrm{Disc}(\mathrm{List}(\alpha))\to\mathcal P(\alpha)$ to send a word
$\ell$ to $\mathrm{ofList}(\ell)$. Then $F\circ G$ is the identity on objects, since
$\mathrm{flatten}(\mathrm{ofList}(\ell))=\ell$, giving $F\circ G\cong \mathrm{id}$. In the other
direction, Theorem 4.1 gives, naturally in $s$, an isomorphism
$s\cong \mathrm{ofList}(\mathrm{flatten}(s))=(G\circ F)(s)$, so $\mathrm{id}\cong G\circ F$; the
required naturality and triangle identities are automatic by thinness of the source and
discreteness of the target. Hence $F$ and $G$ form an adjoint equivalence. $\qquad\blacksquare$

This is the payoff of coherence: a *coherent* loop-tolerant structure is equivalent to a strict,
loop-free one, in exact analogy with Mac Lane's strictification theorem for general monoidal
categories.

---

## 5. Algorithms and numerical illustrations

The constructions above are entirely computable. We highlight three algorithms; full
implementations appear in the accompanying demonstration code.

### 5.1 Counting bracketings

The number of parenthesization trees with a fixed leaf-word of length $n$ is the $(n-1)$-th
Catalan number $C_{n-1}=\frac{1}{n}\binom{2(n-1)}{n-1}$, satisfying
$$
C_0=1,\qquad C_{m}=\sum_{i=0}^{m-1}C_i\,C_{m-1-i}.
$$
For $n=1,2,3,4,5$ the counts are $1,1,2,5,14$. This measures the size of each isomorphism
class in $\mathcal P(\alpha)$: by Theorem 4.2 all $C_{n-1}$ trees over a fixed word of length
$n$ are mutually (uniquely) isomorphic — a single connected component of the groupoid whose
"vertex count" is a Catalan number and whose "edge count" is one bridge per ordered pair.

### 5.2 Normalization and re-association distance

Given any two bracketings of the same word, Theorem 4.1 provides a canonical isomorphism, but
one can also realize a re-association *combinatorially* as a sequence of local rotations
$(a\cdot b)\cdot c \leftrightarrow a\cdot(b\cdot c)$. The minimal number of such rotations
between two trees is the **rotation distance**, famous for its connection to hyperbolic
geometry and the diameter of the associahedron. Our normalization routine transports any tree
to right-nested form and thereby produces an explicit witnessing path; the associator of
Definition 3.3 is precisely the "certificate" that such a path exists, stripped of the choice
of path.

### 5.3 The pentagon check

For four factors there are five bracketings and, from
$((w x) y) z$ to $w(x(y z))$, two natural associator routes. The pentagon check verifies that
both routes send the underlying word to the same result (they do, trivially, since the word is
fixed), illustrating Corollary 2.5 at the level of the flattened data.

---

## 6. Applications and connections

- **Mac Lane coherence, made concrete.** The parenthesization category is a minimal, fully
  explicit witness of the coherence theorem: it exhibits *the* generic re-association groupoid
  on a word and shows it is contractible (all objects uniquely isomorphic).

- **Strictification in practice.** Theorem 4.4 is a bare-hands instance of "every monoidal
  category is monoidally equivalent to a strict one," which underlies why practitioners may
  safely omit associators in computations.

- **Higher categories and homotopy.** The move from equality to coherent isomorphism is the
  entry point to bicategories, tricategories, and $\infty$-categories, and to the homotopy
  hypothesis relating higher groupoids to spaces. The thin case treated here is the
  $(1,1)$-truncated shadow of these towers.

- **Quantum algebra and topological computation.** Associators satisfying the pentagon are the
  algebraic core of braided and fusion categories, of quantum invariants of knots and
  $3$-manifolds, and of anyonic (topological) quantum computation, where coherence of the
  associator is what makes the computation well-defined.

---

## 7. Discussion and future directions

The core lesson is a principle: **rigidity guarantees coherence.** When the transformations
recording re-association are unique — as they are in any thin category — the pentagon,
triangle and naturality laws hold automatically, and the non-strict structure is equivalent
to a strict one. The parenthesization category makes each half of this story concrete and
checkable: associativity genuinely fails as an equation of objects, yet the repair is unique
and coherence is free.

Several extensions are natural:

1. **Monoidal strictification.** Upgrade the equivalence of Theorem 4.4 to a *monoidal*
   equivalence by equipping the discrete category of words with concatenation as tensor and
   showing that the flattening functor is strong monoidal — the full statement of Mac Lane's
   strictification theorem for this family.

2. **Unitors and unit coherence.** Analyze the unit-coherence loops (the triangle) in the same
   thin framework, comparing with the classical redundancy among the unit axioms.

3. **Bicategorical delooping.** A one-object bicategory is a monoidal category; feeding the
   parenthesization category through the delooping produces an explicit one-object bicategory
   whose horizontal composition is non-associative on the nose — a direct model of an
   "almost-category."

4. **Non-thin obstructions.** The clean coherence here is *because* the category is thin. A
   natural sequel is to exhibit a non-thin monoidal datum where the pentagon genuinely fails,
   quantifying how thinness is exactly what removes the obstruction.

---

## 8. Conclusion

We have built, from nothing but parenthesizations, a monoidal category in which associativity
fails on the nose but is repaired by a canonical, unique associator, with all coherence holding
automatically by thinness — and we have shown this structure collapses, up to equivalence, to
the strict discrete category of words. The example is small enough to hold in the hand and
complete enough to display the full arc of the theory: failure, canonical repair, free
coherence, and strictification. It is a perfect miniature of the idea that, when composition
loops back coherently, it loops back to exactly where it began.
