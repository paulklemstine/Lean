# Controlled Failure of Associativity: Thinness, Coherence, and a Catalan Census of Rebracketing

## Abstract

We study categorical structures in which the associativity of composition (or of
a tensor product) is not required to hold on the nose, but only up to a
distinguished invertible comparison, the *associator*. We isolate a simple
hypothesis — **thinness**, the requirement that between any two objects there be
at most one morphism — and show that under it Mac Lane's coherence conditions
(the pentagon and triangle identities, together with all naturality squares) are
satisfied automatically by *any* choice of tensor data. We then exhibit an
explicit, hands-on model: the **parenthesization category** $\mathrm{PTree}(\alpha)$,
whose objects are fully-bracketed words over an alphabet $\alpha$ and whose
morphisms record agreement of underlying words. This category is a genuine
non-strict monoidal category — its tensor product fails to be associative on
objects, provably so by a size argument — yet it is coherent for free, its
associators are unique, and its skeleton is the free monoid $(\mathrm{List}\,\alpha, +\!+, [])$.
Finally, we give a combinatorial census of the reassociation groupoid: the
connected components are the words, and the size of the component built from
$n+1$ factors is the Catalan number $C_n$, satisfying the Segner convolution
recurrence. Together these results characterize a *loop-tolerant* associativity
as equivalent data to a strict monoid decorated by a Catalan-indexed bookkeeping
of bracketings.

**Keywords:** monoidal category, associator, coherence, pentagon identity, thin
category, free monoid, binary trees, Catalan numbers, Segner recurrence,
strictification.

---

## 1. Introduction

### 1.1 The problem of grouping

Associativity — the identity $(a\cdot b)\cdot c = a\cdot(b\cdot c)$ — is the
law that lets us drop parentheses from a chain of operations. In elementary
algebra it holds strictly and is quickly forgotten. In higher algebra and
category theory, however, the natural comparisons between differently-grouped
products are frequently *isomorphisms* rather than *equalities*. One keeps the
brackets and supplies, for every triple of objects $A,B,C$, a distinguished
invertible morphism

$$\alpha_{A,B,C} \colon (A \otimes B)\otimes C \xrightarrow{\ \cong\ } A\otimes(B\otimes C),$$

the **associator**. This is the setting of *monoidal categories*, and the
associator is exactly the datum witnessing that "composition loops back":
different bracketings of the same product are reversibly identified, but not
equated.

Allowing invertible comparisons in place of equalities raises the question of
**coherence**. Different sequences of associator moves connecting the same pair
of bracketings must land on the same isomorphism, or the theory becomes
ambiguous. Mac Lane's coherence theorem singles out two diagrams whose
commutativity suffices for *all* such diagrams to commute: the **pentagon**,
relating the five bracketings of a quadruple product, and the **triangle**,
relating the associator to the unit isomorphisms.

### 1.2 Contributions

This paper develops three results, arranged as a single narrative arc from
abstract sufficiency to concrete model to combinatorial measurement.

1. **Free coherence from thinness (Section 3).** If a category is *thin* — any
   two parallel morphisms are equal — then any tensor data on it satisfies the
   pentagon, triangle, and all naturality conditions automatically. Coherence
   is not merely provable but vacuous: the two sides of each coherence diagram
   are parallel morphisms and hence equal.

2. **A concrete non-strict monoidal category (Section 4).** The
   parenthesization category $\mathrm{PTree}(\alpha)$ realizes controlled
   non-associativity explicitly. Its tensor product is genuinely
   non-associative on objects (Theorem 4.4), yet it is a monoidal category whose
   associators are unique (Theorem 4.5), and its skeleton is the free monoid
   (Section 4.4).

3. **A Catalan census of the loops (Section 5).** The connected components of
   the reassociation groupoid are the underlying words; the component of a
   product of $n+1$ factors has cardinality the Catalan number $C_n$
   (Theorem 5.5), and this census satisfies the Segner convolution recurrence
   (Theorem 5.6).

The unifying slogan: *a loop-tolerant (coherent, non-strict) associative
structure carries exactly the information of a strict monoid together with a
Catalan-indexed record of how bracketings are glued.*

---

## 2. Preliminaries

We work with ordinary categories. Recall that a **category** $\mathcal{C}$
consists of objects, morphisms (arrows) $f\colon X\to Y$, an identity
$\mathrm{id}_X$ for each object, and an associative composition. A morphism $f$
is an **isomorphism** if it has a two-sided inverse; we write $X\cong Y$ when an
isomorphism exists. A **groupoid** is a category in which every morphism is an
isomorphism.

A **monoidal structure** on $\mathcal{C}$ consists of a tensor product functor
$\otimes\colon\mathcal{C}\times\mathcal{C}\to\mathcal{C}$, a unit object
$\mathbf{1}$, a natural associator isomorphism
$\alpha_{A,B,C}\colon (A\otimes B)\otimes C\cong A\otimes(B\otimes C)$, and
natural left/right unitors
$\lambda_A\colon \mathbf{1}\otimes A\cong A$,
$\rho_A\colon A\otimes\mathbf{1}\cong A$. It is a **monoidal category** if it
additionally satisfies:

- **Pentagon identity.** For all $W,X,Y,Z$,
$$
(\alpha_{W,X,Y}\otimes \mathrm{id}_Z)\ ;\ \alpha_{W,\,X\otimes Y,\,Z}\ ;\ (\mathrm{id}_W\otimes \alpha_{X,Y,Z})
\;=\;
\alpha_{W\otimes X,\,Y,\,Z}\ ;\ \alpha_{W,\,X,\,Y\otimes Z}.
$$
- **Triangle identity.** For all $X,Y$,
$$
\alpha_{X,\mathbf{1},Y}\ ;\ (\mathrm{id}_X\otimes \lambda_Y) \;=\; \rho_X \otimes \mathrm{id}_Y .
$$

(We write composition left-to-right as $f\, ;\, g$, and use $\triangleright,
\triangleleft$ informally for whiskering, i.e. tensoring a morphism with an
identity.) A monoidal category is **strict** if $\alpha,\lambda,\rho$ are all
identities; otherwise **non-strict**.

Mac Lane's **coherence theorem** asserts that in any monoidal category, every
formal diagram built from associators and unitors commutes; equivalently, every
monoidal category is monoidally equivalent to a strict one.

---

## 3. Coherence is free in a thin category

### 3.1 Thin categories

**Definition 3.1 (Thin category).** A category $\mathcal{C}$ is *thin* if for
any objects $X,Y$ and any parallel morphisms $f,g\colon X\to Y$ one has $f=g$.
Equivalently, each hom-set is a subsingleton, and $\mathcal{C}$ is (the category
associated to) a preorder.

Two immediate consequences record the rigidity of the thin world.

**Lemma 3.2 (Uniqueness of morphisms and isomorphisms).** In a thin category,
each hom-set $\mathrm{Hom}(X,Y)$ has at most one element, and the class of
isomorphisms $X\cong Y$ likewise has at most one element.

*Proof.* The first claim is the definition. For the second, two isomorphisms
$\varphi,\psi\colon X\cong Y$ have equal underlying morphisms by thinness, and
an isomorphism is determined by its underlying morphism; hence $\varphi=\psi$.
$\qquad\blacksquare$

### 3.2 The free-coherence theorem

**Theorem 3.3 (Coherence is free in a thin category).** Let $\mathcal{C}$ be a
thin category equipped with *any* monoidal-structure data: a tensor product on
objects and morphisms, a unit, an associator, and unitors. Then $\mathcal{C}$ is
a monoidal category. That is, the pentagon identity, the triangle identity, and
every naturality condition (of the associator, of the two unitors, and the
interchange/functoriality laws of $\otimes$) hold automatically.

*Proof.* Each required identity is an equation between two morphisms with a
common source and a common target. By Definition 3.1, any two such parallel
morphisms are equal. Hence every coherence and naturality equation holds
without further hypotheses. $\qquad\blacksquare$

The theorem is the abstract engine behind everything that follows: it converts
*any* "controlled failure of associativity" living in a thin category into a
bona fide monoidal (indeed bicategorical) structure with no coherence
obligations whatsoever.

**Corollary 3.4 (Pentagon and triangle).** In any monoidal structure on a thin
category $\mathcal{C}$, the pentagon and triangle identities of Section 2 hold.

**Corollary 3.5 (A causal loop closes to the identity).** In any monoidal
structure on a thin category, the composite consisting of the long Mac Lane
route around the pentagon followed by the inverse of the short route,
$$
\Big((\alpha_{W,X,Y}\triangleright Z)\ ;\ \alpha_{W,X\otimes Y,Z}\ ;\ (W\triangleleft \alpha_{X,Y,Z})\Big)\ ;\ \big(\alpha_{W\otimes X,Y,Z}\ ;\ \alpha_{W,X,Y\otimes Z}\big)^{-1},
$$
equals the identity morphism. When composition loops back, it loops back to
where it started.

*Proof.* Both displayed composites are endomorphisms of a fixed object; by
thinness the composite equals $\mathrm{id}$. $\qquad\blacksquare$

---

## 4. The parenthesization category

We now build an explicit thin monoidal category in which associativity fails on
objects. Fix a type (alphabet) $\alpha$.

### 4.1 Objects: bracketings as binary trees

**Definition 4.1 (Parenthesization trees).** Let $\mathrm{PTree}(\alpha)$ be the
set of binary trees with leaves labelled in $\alpha$, generated by:
- $\mathsf{nil}$, the empty tree;
- $\mathsf{leaf}(a)$ for each $a\in\alpha$;
- $\mathsf{node}(s,t)$ for trees $s,t$, read as the bracketed product $(s\cdot t)$.

The **flattening** $\mathrm{flat}\colon \mathrm{PTree}(\alpha)\to \mathrm{List}(\alpha)$
forgets the bracketing:
$$
\mathrm{flat}(\mathsf{nil}) = [\,],\qquad
\mathrm{flat}(\mathsf{leaf}\,a) = [a],\qquad
\mathrm{flat}(\mathsf{node}(s,t)) = \mathrm{flat}(s) \,+\!+\, \mathrm{flat}(t).
$$

### 4.2 Morphisms: agreement of words

**Definition 4.2 (The parenthesization category).** Make $\mathrm{PTree}(\alpha)$
a category by declaring
$$
\mathrm{Hom}(s,t) \;=\; \{\text{proofs that } \mathrm{flat}(s) = \mathrm{flat}(t)\},
$$
a set with at most one element. The identity is reflexivity of equality, and
composition is its transitivity.

**Proposition 4.3 (Thinness and groupoid structure).** $\mathrm{PTree}(\alpha)$
is a thin category, and it is a groupoid: every morphism $s\to t$ (a proof
$\mathrm{flat}(s)=\mathrm{flat}(t)$) has an inverse (its symmetric proof).

*Proof.* Any two morphisms $s\to t$ are proofs of the same equality of words,
hence identified; this is thinness. Given $f\colon s\to t$, the symmetric
equality provides $t\to s$, and both composites are morphisms in singleton
hom-sets, hence identities. $\qquad\blacksquare$

### 4.3 The monoidal structure and genuine non-strictness

Define tensor data on $\mathrm{PTree}(\alpha)$:
- **tensor of objects:** $s\otimes t = \mathsf{node}(s,t)$;
- **unit:** $\mathbf{1} = \mathsf{nil}$;
- **whiskerings:** a morphism $f\colon a\to b$ tensored with an object $X$ uses
  the congruence $\mathrm{flat}(X)\,+\!+\,(-)$ (resp. $(-)\,+\!+\,\mathrm{flat}(X)$)
  applied to the underlying equality;
- **associator:** $\alpha_{a,b,c}$ is the isomorphism obtained from the
  associativity of list concatenation,
  $(\mathrm{flat}(a)+\!+\mathrm{flat}(b))+\!+\mathrm{flat}(c) = \mathrm{flat}(a)+\!+(\mathrm{flat}(b)+\!+\mathrm{flat}(c))$;
- **unitors:** obtained from $[\,]+\!+w = w = w+\!+[\,]$.

By Theorem 3.3 (thinness), these data form a monoidal category with no further
verification.

**Theorem 4.4 (Associativity fails on the nose).** For all objects $a,b,c$ the
objects $(a\otimes b)\otimes c = \mathsf{node}(\mathsf{node}(a,b),c)$ and
$a\otimes(b\otimes c) = \mathsf{node}(a,\mathsf{node}(b,c))$ are **distinct**.
In particular the associator is a non-identity isomorphism, and
$\mathrm{PTree}(\alpha)$ is a genuinely non-strict monoidal category (witnessed
already at $a=b=c=\mathsf{nil}$).

*Proof.* Suppose $\mathsf{node}(\mathsf{node}(a,b),c) = \mathsf{node}(a,\mathsf{node}(b,c))$.
Matching left children gives $\mathsf{node}(a,b) = a$, which is impossible by a
size (structural depth) count: the left-hand side is strictly larger than $a$.
$\qquad\blacksquare$

**Theorem 4.5 (Uniqueness of the associator; coherence is connectedness).** For
all $a,b,c$ the associator $\alpha_{a,b,c}$ is the *unique* isomorphism
$(a\otimes b)\otimes c \cong a\otimes(b\otimes c)$. More generally, two
bracketings $s,t$ are isomorphic if and only if they flatten to the same word:
$$
(s \cong t)\ \Longleftrightarrow\ \mathrm{flat}(s) = \mathrm{flat}(t).
$$

*Proof.* Uniqueness is Lemma 3.2 applied to the thin category
$\mathrm{PTree}(\alpha)$. For the equivalence: an isomorphism $s\cong t$ is in
particular a morphism, i.e. a proof $\mathrm{flat}(s)=\mathrm{flat}(t)$;
conversely such a proof yields the isomorphism directly. $\qquad\blacksquare$

### 4.4 Strictification: the skeleton is the free monoid

**Definition 4.6 (Normal form).** For a word $w=[a_1,\dots,a_k]$ let
$\mathrm{ofList}(w)$ be the right-nested bracketing
$\mathsf{node}(\mathsf{leaf}\,a_1,\mathsf{node}(\mathsf{leaf}\,a_2,\dots))$,
with $\mathrm{ofList}([\,]) = \mathsf{nil}$. Then $\mathrm{flat}(\mathrm{ofList}(w))=w$.

**Theorem 4.7 (Concrete coherence / strictification).**
(a) Every object $s$ is canonically isomorphic to the normal form of its word:
$s \cong \mathrm{ofList}(\mathrm{flat}(s))$.
(b) Normal forms multiply by concatenation:
$$\mathrm{ofList}(w_1)\otimes \mathrm{ofList}(w_2) \;\cong\; \mathrm{ofList}(w_1 +\!+ w_2),$$
with unit $\mathrm{ofList}([\,]) = \mathbf{1}$. Hence the skeleton of
$\mathrm{PTree}(\alpha)$ — objects up to isomorphism, i.e. words — is the **free
monoid** $(\mathrm{List}(\alpha), +\!+, [\,])$.

*Proof.* (a) $\mathrm{flat}(s) = \mathrm{flat}(\mathrm{ofList}(\mathrm{flat}\,s))$
since $\mathrm{flat}\circ\mathrm{ofList} = \mathrm{id}$; apply Theorem 4.5. (b)
Both sides flatten to $w_1+\!+w_2$; apply Theorem 4.5. Isomorphism classes are
words by Theorem 4.5, and the induced operation is concatenation, which is the
free-monoid multiplication. $\qquad\blacksquare$

Theorem 4.7 is Mac Lane's coherence theorem made utterly concrete: because every
associator diagram commutes (thinness), one may replace the tower of associators
by strict equality of words with no loss of information.

---

## 5. A combinatorial census of the loops

We now measure the reassociation groupoid: how many bracketings sit inside a
single isomorphism class?

### 5.1 Abstract bracketing shapes

**Definition 5.1 (Shapes).** A *bracketing shape* is a binary tree recording how
a product is bracketed while forgetting the factors:
- $\mathsf{lf}$, a single factor;
- $\mathsf{br}(l,r)$, a binary product of shapes $l,r$.

Define the number of **leaves** (factors) and **products** (internal nodes):
$$
\mathrm{leaves}(\mathsf{lf})=1,\quad \mathrm{leaves}(\mathsf{br}(l,r))=\mathrm{leaves}(l)+\mathrm{leaves}(r),
$$
$$
\mathrm{prod}(\mathsf{lf})=0,\quad \mathrm{prod}(\mathsf{br}(l,r))=\mathrm{prod}(l)+\mathrm{prod}(r)+1.
$$

**Lemma 5.2 (Factors versus products).** For every shape $s$,
$\mathrm{leaves}(s) = \mathrm{prod}(s) + 1$. A product of $n+1$ factors uses
exactly $n$ brackets.

*Proof.* Induction on $s$: the leaf case is $1 = 0+1$, and the branch case adds
the two inductive equalities and one product. $\qquad\blacksquare$

### 5.2 Shapes are binary trees

**Proposition 5.3 (Shapes $\cong$ finite binary trees).** The map sending
$\mathsf{lf}$ to the empty tree and $\mathsf{br}(l,r)$ to an internal node with
subtrees the images of $l,r$ is a bijection between bracketing shapes and finite
binary trees. Under it, the number of products of a shape equals the number of
internal nodes of the corresponding tree.

*Proof.* The inverse sends the empty tree to $\mathsf{lf}$ and an internal node
to $\mathsf{br}$ of the images of its subtrees; the two composites are the
identity by structural induction. The node-count identity is a further
induction. $\qquad\blacksquare$

**Definition 5.4 (The finite set of bracketings).** Let $\mathrm{Brk}(n)$ be the
finite set of all bracketing shapes with exactly $n$ products (equivalently
$n+1$ factors), obtained by transporting, across the bijection of
Proposition 5.3, the set of binary trees with $n$ internal nodes. A shape $s$
lies in $\mathrm{Brk}(n)$ iff $\mathrm{prod}(s)=n$.

### 5.3 The Catalan census and its recurrence

Recall the **Catalan numbers**, defined by $C_0=1$ and the Segner recurrence
$C_{n+1}=\sum_{i=0}^{n} C_i C_{n-i}$; equivalently $C_n = \frac{1}{n+1}\binom{2n}{n}$.
The first values are $1,1,2,5,14,42,132,\dots$.

**Theorem 5.5 (The census of loops).** The number of bracketings of a product of
$n+1$ factors is the Catalan number:
$$
\big|\mathrm{Brk}(n)\big| \;=\; C_n .
$$
Equivalently, each connected component of the reassociation groupoid — the set
of all bracketings sharing a fixed word of length $n+1$ — has exactly $C_n$
members, all mutually and uniquely isomorphic.

*Proof.* By Definition 5.4 the set $\mathrm{Brk}(n)$ is in bijection with the set
of binary trees having $n$ internal nodes (Proposition 5.3), and the cardinality
of the latter is the classical Catalan count $C_n$. $\qquad\blacksquare$

**Theorem 5.6 (Segner convolution for the census).** The census obeys
$$
\big|\mathrm{Brk}(n+1)\big| \;=\; \sum_{i=0}^{n} \big|\mathrm{Brk}(i)\big|\cdot\big|\mathrm{Brk}(n-i)\big|.
$$

*Proof.* Substitute Theorem 5.5 into the Segner recurrence for the Catalan
numbers. Combinatorially, splitting a bracketing at its outermost bracket
decomposes it uniquely into a left bracketing of $i+1$ factors and a right
bracketing of $(n-i)+1$ factors, and summing over the split point $i$ yields the
convolution. $\qquad\blacksquare$

### 5.4 Bridging the census to the parenthesization category

To connect the abstract count to the concrete category, realize each shape as an
object over the one-letter alphabet.

**Definition 5.7.** Let $\mathrm{real}\colon \mathrm{Shape}\to \mathrm{PTree}(\{\ast\})$
send $\mathsf{lf}\mapsto \mathsf{leaf}(\ast)$ and
$\mathsf{br}(l,r)\mapsto\mathsf{node}(\mathrm{real}(l),\mathrm{real}(r))$.

**Proposition 5.8 (Realization is faithful on shapes).** The map $\mathrm{real}$
is injective, and $\mathrm{flat}(\mathrm{real}(s))$ is the constant word $\ast$
repeated $\mathrm{leaves}(s)$ times.

*Proof.* The flattening identity is an induction using
$\mathrm{leaves}(\mathsf{br}(l,r))=\mathrm{leaves}(l)+\mathrm{leaves}(r)$ and the
concatenation of repeated letters. Injectivity is an induction matching the
constructors. $\qquad\blacksquare$

**Theorem 5.9 (Components are the isomorphism classes).** If two shapes have the
same number of factors, $\mathrm{leaves}(s)=\mathrm{leaves}(t)$, then their
realizations are isomorphic, $\mathrm{real}(s)\cong \mathrm{real}(t)$.
Consequently the $C_n$ distinct bracketings of $n+1$ factors form a single
connected, "contractible" component of the reassociation groupoid, whose size is
$C_n$.

*Proof.* By Proposition 5.8 both realizations flatten to the same repeated word,
so they are isomorphic by Theorem 4.5. That the isomorphisms are unique is again
Lemma 3.2. $\qquad\blacksquare$

---

## 6. Algorithms

The constructive content of the paper yields three algorithms.

**(A) Enumerate bracketings.** Generate all bracketing shapes of $n+1$ factors
by the recursive split: a shape is either a leaf (base case $n=0$), or a branch
whose left part has $i+1$ factors and right part has $(n-i)+1$ factors for some
$0\le i\le n-1$. This directly realizes the Segner recurrence and produces
exactly $C_n$ shapes.

**(B) Normalize a bracketing.** Given any bracketing, flatten it to its word and
re-emit the right-nested normal form; by Theorem 4.7 this is the canonical
representative of its isomorphism class, and it computes the unique associator
path between any two bracketings of a word.

**(C) Count the census.** Compute $C_n$ either by dynamic programming on the
Segner convolution or by the closed form $\frac{1}{n+1}\binom{2n}{n}$, and
cross-check the two against a direct enumeration from (A).

---

## 7. Applications and discussion

**Physics and computation.** In topological and categorical models of quantum
systems, the order in which processes are composed carries information stored in
the associator; the pentagon is the consistency law those models must obey. Our
free-coherence result identifies a broad regime — thin/preorder-like comparison
data — in which that consistency is automatic, and the concrete parenthesization
model gives a minimal testbed where non-associativity is real but tame.

**Parsing and data aggregation.** Bracketings are parse trees; the census
$C_n$ counts the distinct parse trees of an $n+1$-ary associative operator, and
the normal-form algorithm is exactly the canonicalization used when an
aggregation is known to be associative.

**Coherence philosophy.** The results make precise the intuition that coherence
"costs nothing when there is nothing to disagree about." Thinness removes all
room for two distinct rebracketing witnesses to differ; the Catalan census then
quantifies exactly how much the associator glues together within each word.

---

## 8. Future directions

**Associahedra.** The reassociation moves between bracketings of $n$ factors are
directed (each associator points from one bracketing to another). We conjecture
these moves assemble into a regular CW-complex whose face lattice is the Tamari
lattice and whose realization is the associahedron $K_n$; the Catalan census
counts its vertices, and the maximal chains of the Tamari lattice count its
top-dimensional cells.

**Sharpness of thinness.** We proved thinness is *sufficient* for free
coherence. We conjecture it is also *necessary*: free coherence holds for a
category iff each isomorphism class is thin (locally a preorder), and any two
parallel non-equal isomorphisms admit tensor data violating the pentagon.

**Higher arities and Fuss–Catalan.** Replacing binary products by $k$-ary
products should yield a reassociation groupoid whose components are still words
but whose component sizes are the Fuss–Catalan numbers
$C^{(k)}_n = \frac{1}{(k-1)n+1}\binom{kn}{n}$, recovering the ordinary Catalan
census at $k=2$. The tree bijection generalizes verbatim to $k$-ary plane trees.

---

## 9. Conclusion

A controlled failure of associativity — where $(A\otimes B)\otimes C$ and
$A\otimes(B\otimes C)$ are distinct but uniquely isomorphic — is best understood
through three linked facts. In a thin world, coherence is free: the pentagon and
triangle hold because parallel morphisms coincide. The parenthesization category
realizes this concretely as a genuinely non-strict monoidal category whose
skeleton is the free monoid. And the reassociation groupoid's connected
components are the words, with each component's size the Catalan number $C_n$,
obeying the Segner convolution. Loop-tolerant associativity is thus equivalent
data to a strict monoid together with a Catalan-indexed bookkeeping of
bracketings.
