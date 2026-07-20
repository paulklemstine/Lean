# Causal Loops in Category Theory: A Concrete Genuinely Non-Strict Bicategory

**Aristotle**  
**20 July 2026**

## Abstract

We construct an explicit one-object bicategory whose one-dimensional composition is unital but genuinely nonassociative. The one-dimensional arrows are the natural numbers, the identity is $0$, and composition is the twisted operation

$$
a\mathbin{\bigstar}b=
\begin{cases}
b,&a=0,\\
a,&b=0,\\
a+2b,&a,b>0.
\end{cases}
$$

Between every pair of one-dimensional arrows there is exactly one two-dimensional arrow. These codiscrete hom-categories supply invertible associators and unitors, while uniqueness of parallel two-dimensional arrows forces the pentagon and triangle coherence equations. For the distinguished arrow $u=1$, the two bracketings of a triple are $(u\bigstar u)\bigstar u=5$ and $u\bigstar(u\bigstar u)=7$. Thus composition is not associative as an equality, although the two composites are linked by an invertible associator. We prove that no strict bicategory structure can preserve this fixed one-dimensional composition. We also give algorithms for evaluating composites, enumerating bracketings, and auditing coherence diagrams. The construction isolates a basic principle of higher-dimensional algebra: a failure of equality can be controlled by coherent equivalence.

## 1. Introduction

Associativity permits parentheses to be suppressed. In a semigroup, $(ab)c=a(bc)$; in an ordinary category, the two composites of three compatible arrows are equal. Many mathematical and computational constructions, however, are naturally associative only up to a reversible comparison. Tensor products, spans, gluing operations, transformations with auxiliary choices, and staged process composition frequently behave this way. Bicategories capture this phenomenon by replacing the associativity equation with an invertible two-dimensional arrow and requiring these arrows to satisfy coherence laws.

The purpose of this paper is to exhibit the distinction in a minimal, fully explicit example. We use a single object, natural numbers as one-dimensional arrows, and a composition law whose nonassociativity can be read from the elementary calculation $5\ne 7$. We then make each hom-category codiscrete: between any two one-dimensional arrows there is precisely one two-dimensional arrow. The associator therefore exists even when its endpoints are unequal, and all coherence diagrams commute because parallel two-dimensional arrows are unique.

This example has three useful features. First, the defect of associativity is arithmetically visible. Second, the repair occurs strictly at the next categorical dimension: it never identifies distinct natural numbers. Third, the example cannot be made strict without changing the specified composition. It is therefore a genuinely non-strict bicategory on its fixed data, rather than a strict example equipped with redundant notation.

The construction does not establish that every vaguely “loop-tolerant” algebraic structure is automatically a higher category. Such a statement requires specified dimensions, comparison cells, composition operations, and coherence axioms. What the example does establish is a precise local paradigm: an arbitrary associativity defect can be absorbed by invertible two-cells when the hom-categories provide suitable comparisons, and codiscreteness makes all required coherence automatic.

## 2. Bicategorical preliminaries

### 2.1. Bicategories

A **bicategory** consists of the following data.

1. A collection of objects $A,B,C,\ldots$.
2. For every pair $(A,B)$, a category $\mathcal B(A,B)$. Its objects are called **one-cells** $f:A\to B$, and its morphisms are called **two-cells** $\eta:f\Rightarrow g$.
3. For every triple of objects, a composition functor

$$
\circ:\mathcal B(B,C)\times\mathcal B(A,B)\longrightarrow\mathcal B(A,C).
$$

4. For each object $A$, an identity one-cell $1_A:A\to A$.
5. For composable one-cells $f,g,h$, a natural invertible two-cell, the **associator**,

$$
\alpha_{f,g,h}:(f\circ g)\circ h\Rightarrow f\circ(g\circ h).
$$

6. For each one-cell $f:A\to B$, invertible left and right unitors

$$
\lambda_f:1_B\circ f\Rightarrow f,
\qquad
\rho_f:f\circ 1_A\Rightarrow f.
$$

The associator and unitors must satisfy the pentagon and triangle equations. We use a left-to-right notation $igstar$ for the concrete one-cell composition below; the role of source and target is harmless because the example has one object.

For four composable one-cells $f,g,h,i$, the **pentagon equation** says that the two canonical composites of associators from $((f\bigstar g)\bigstar h)\bigstar i$ to $f\bigstar(g\bigstar(h\bigstar i))$ are equal. Suppressing whiskering notation, its structural form is

$$
(\alpha_{f,g,h}\bigstar 1_i)\,;
\alpha_{f,g\bigstar h,i}\,;
(1_f\bigstar\alpha_{g,h,i})
=
\alpha_{f\bigstar g,h,i}\,;
\alpha_{f,g,h\bigstar i}.
$$

The **triangle equation** compares reassociation past an identity with the two unitors. In structural notation it is

$$
\alpha_{f,1,g}\,;(1_f\bigstar\lambda_g)
=
\rho_f\bigstar 1_g.
$$

These equations guarantee that repeated reassociation and removal of identities do not introduce path-dependent ambiguity.

### 2.2. Strict bicategories

A bicategory is **strict** when the associativity and identity laws hold as literal equalities of one-cells and the structural comparisons are identities. In particular, strictness forces

$$
(f\bigstar g)\bigstar h=f\bigstar(g\bigstar h)
$$

for every composable triple. A non-strict bicategory permits unequal endpoints connected by an invertible associator.

### 2.3. Codiscrete categories

A category is **codiscrete** if for every ordered pair of objects $x,y$ there is exactly one morphism $x\to y$. The unique morphisms $x\to y$ and $y\to x$ are mutually inverse: their composites are endomorphisms, and each endpoint has only one endomorphism, necessarily its identity.

**Lemma 2.1 (Codiscrete invertibility).** In a codiscrete category, every morphism is an isomorphism.

**Proof sketch.** Let $p:x\to y$ be the unique morphism and let $q:y\to x$ be the unique reverse morphism. Both $q\circ p$ and $1_x$ are morphisms $x\to x$, hence they agree. Similarly, $p\circ q=1_y$. Thus $q$ is the inverse of $p$. $\square$

**Lemma 2.2 (Uniqueness of parallel two-cells).** If a hom-category is codiscrete, then any two two-cells $\eta,\theta:f\Rightarrow g$ are equal.

**Proof sketch.** Codiscreteness asserts that the morphism set from $f$ to $g$ has one element. $\square$

The second lemma is the engine of coherence in our example. Every side of a coherence equation is a two-cell with the same source and target, so the two sides agree.

## 3. The twisted unital magma

Let $M=\mathbb N$. Define $igstar:M\times M\to M$ by

$$
a\mathbin{\bigstar}b=
\begin{cases}
b,&a=0,\\
a,&a\ne0\text{ and }b=0,\\
a+2b,&a\ne0\text{ and }b\ne0.
\end{cases}
\tag{3.1}
$$

The first clause takes priority when both arguments vanish, although both identity requirements give the same result.

**Proposition 3.1 (Two-sided unit).** The element $0$ is a two-sided identity for $igstar$. For every $a\in\mathbb N$,

$$
0\mathbin{\bigstar}a=a,
\qquad
a\mathbin{\bigstar}0=a.
$$

**Proof.** The first equality is the first clause of (3.1). For the second, if $a=0$, the first clause yields $0\bigstar0=0$; if $a\ne0$, the second clause yields $a\bigstar0=a$. $\square$

Thus $(\mathbb N,\bigstar,0)$ is a unital magma. It is not a monoid.

**Proposition 3.2 (Explicit associativity defect).** With $u=1$,

$$
(u\mathbin{\bigstar}u)\mathbin{\bigstar}u=5,
\qquad
u\mathbin{\bigstar}(u\mathbin{\bigstar}u)=7.
$$

In particular, $igstar$ is not associative.

**Proof.** Since all entries are positive,

$$
u\bigstar u=1+2=3.
$$

Therefore

$$
(u\bigstar u)\bigstar u=3\bigstar1=3+2=5,
$$

whereas

$$
u\bigstar(u\bigstar u)=1\bigstar3=1+6=7.
$$

The natural numbers $5$ and $7$ are unequal. $\square$

The defect is not isolated. For positive $a,b,c$, direct expansion gives

$$
(a\bigstar b)\bigstar c=a+2b+2c,
$$

and

$$
a\bigstar(b\bigstar c)=a+2b+4c.
$$

Hence the right-associated result exceeds the left-associated result by $2c$ whenever $c>0$. The unit clauses create special cases containing $0$, but the positive region displays systematic nonassociativity.

**Proposition 3.3 (Positive triple defect formula).** For $a,b,c>0$,

$$
a\bigstar(b\bigstar c)-((a\bigstar b)\bigstar c)=2c.
$$

**Proof.** Under positivity every composition uses the third clause of (3.1). Expanding both sides as above and subtracting gives $2c$. $\square$

## 4. Construction of the bicategory

Define a structure $\mathcal L$ as follows.

- There is one object, denoted $\ast$.
- The one-cells $\ast\to\ast$ are the natural numbers.
- The identity one-cell is $0$.
- The composite of one-cells $a$ and $b$ is $a\bigstar b$.
- For every pair of one-cells $m,n$, there is exactly one two-cell $m\Rightarrow n$.
- Vertical composition, horizontal composition, and whiskering are the unique two-cells with the required boundaries.
- The associator $\alpha_{a,b,c}$ is the unique two-cell

$$
(a\bigstar b)\bigstar c\Rightarrow a\bigstar(b\bigstar c).
$$

- The left and right unitors are the unique two-cells with the required unit boundaries.

Because $0$ is a strict unit for the underlying magma, the unitor endpoints are already equal as natural numbers. This is convenient but not essential to the codiscrete method: unique isomorphisms could also bridge unequal unit composites.

**Theorem 4.1 (Codiscrete bicategory construction).** The data above define a bicategory.

**Proof sketch.** For the unique object, the hom-category has natural numbers as objects and a singleton morphism set between every pair. Identity and vertical composition are forced by uniqueness and satisfy the category axioms. The operation $igstar$ specifies one-cell composition. On two-cells, the composition functor and whiskering operations are again forced, because each relevant target hom-set is a singleton.

For each triple, the required associator exists and is invertible by Lemma 2.1. The left and right unitors exist and are invertible for the same reason. Naturality conditions compare parallel two-cells and therefore follow from Lemma 2.2. Finally, each side of the pentagon equation is a two-cell between the same two bracketed composites, so the sides are equal. The same argument proves the triangle equation. Hence all bicategory axioms hold. $\square$

**Corollary 4.2 (Controlled reassociation).** For every $f,g,h\in\mathbb N$, there is an invertible two-cell

$$
\alpha_{f,g,h}:
(f\bigstar g)\bigstar h
\Longrightarrow
f\bigstar(g\bigstar h).
$$

**Proof.** This is the associator supplied by Theorem 4.1. Its inverse is the unique two-cell in the reverse direction. $\square$

**Corollary 4.3 (The $5$–$7$ associator).** There is an invertible two-cell $5\Rightarrow7$ connecting the two composites of three copies of $u=1$.

**Proof.** Proposition 3.2 identifies the source and target of $\alpha_{1,1,1}$ as $5$ and $7$. $\square$

It is important that Corollary 4.3 does not imply $5=7$. Natural-number equality concerns equality of one-cells. The associator is instead a morphism inside the hom-category, hence a two-cell of the bicategory.

## 5. Coherence

### 5.1. The pentagon

For four one-cells, there are five full binary bracketings. Associators connect adjacent rebracketings, producing the classical pentagon. In a general bicategory, proving the equality of the two routes is substantive. Here, both routes are parallel two-cells.

**Theorem 5.1 (Pentagon coherence).** For all $f,g,h,i\in\mathbb N$, the two canonical composites of associators from $((f\bigstar g)\bigstar h)\bigstar i$ to $f\bigstar(g\bigstar(h\bigstar i))$ are equal.

**Proof.** Both routes have the same source and target. The relevant two-cell set is a singleton, so Lemma 2.2 identifies them. $\square$

### 5.2. The triangle

**Theorem 5.2 (Triangle coherence).** For all $f,g\in\mathbb N$, the reassociation route involving $f\bigstar0\bigstar g$ agrees with the route using the right unitor of $f$ and the left unitor of $g$.

**Proof.** The two routes are parallel two-cells. Codiscrete uniqueness forces equality. $\square$

### 5.3. General diagrammatic coherence in the example

**Theorem 5.3 (Parallel-cell coherence).** Every pair of parallel two-cells in $\mathcal L$ is equal. Consequently, every diagram of two-cells whose paths share endpoints commutes.

**Proof.** Every two-cell hom-set is a singleton. Any two path composites with common endpoints belong to that singleton. $\square$

This theorem is stronger than the individual pentagon and triangle equations for this particular example. It explains why no additional higher ambiguity remains: the space of comparisons has been made contractible in the strongest elementary sense, with one arrow between any two one-cells.

## 6. Genuine non-strictness

The existence of coherent associators does not make the chosen one-cell composition associative. Indeed, it records precisely how the two bracketings differ.

**Theorem 6.1 (No strict structure on the fixed composition).** There is no strict bicategory having the same sole object, the same natural-number one-cells, identity $0$, and composition $igstar$.

**Proof.** Suppose such a strict structure existed. Strict associativity, applied to $u=1$, would imply

$$
(u\bigstar u)\bigstar u=u\bigstar(u\bigstar u).
$$

By Proposition 3.2, the left side is $5$ and the right side is $7$. This would give $5=7$, a contradiction. $\square$

The qualifier “on the fixed composition” is essential. The theorem is an obstruction to strictness as equality without altering the underlying one-cell data. It does not deny the possibility of a different strict two-category biequivalent to $\mathcal L$. Strictification up to biequivalence changes the standard of sameness and may replace the original one-cells by more elaborate representatives.

## 7. Algorithms and computational exploration

Although the coherence proof is structural, finite calculations illuminate the construction.

### 7.1. Twisted composition evaluation

Given $a,b\in\mathbb N$, evaluate (3.1) by testing for the identity cases and otherwise returning $a+2b$. This takes constant time in a unit-cost arithmetic model and bit complexity linear in the output bit length under standard integer arithmetic.

For a parenthesized expression, recursively evaluate the left and right subexpressions and apply $igstar$. An expression with $n$ leaves requires exactly $n-1$ composition calls, so its structural running time is $O(n)$, apart from integer bit costs.

### 7.2. Enumeration of bracketings

All full parenthesizations of $n$ inputs can be generated recursively. Split the input after position $k$, generate every bracketing of the left and right blocks, and combine every pair. The number of outputs is the Catalan number

$$
C_{n-1}=\frac{1}{n}\binom{2n-2}{n-1}.
$$

Any complete enumeration therefore requires $\Omega(C_{n-1})$ output operations. Memoizing subintervals avoids repeated generation work, though materializing all trees still has Catalan-scale space usage.

For four copies of $1$, the five bracketings evaluate as follows:

$$
((1\bigstar1)\bigstar1)\bigstar1=7,
$$

$$
(1\bigstar(1\bigstar1))\bigstar1=9,
$$

$$
(1\bigstar1)\bigstar(1\bigstar1)=9,
$$

$$
1\bigstar((1\bigstar1)\bigstar1)=11,
$$

$$
1\bigstar(1\bigstar(1\bigstar1))=15.
$$

These unequal values are the vertices connected by the associator pentagon. The coherence theorem concerns equality of the two-dimensional path composites, not equality of these vertex labels.

### 7.3. Coherence auditing

A finite coherence audit can represent a bracketing as a binary tree and an elementary associator as the local rotation

$$
((X\bigstar Y)\bigstar Z)\longleftrightarrow
(X\bigstar(Y\bigstar Z)).
$$

One can enumerate rotation paths between two trees. In the present bicategory, every such path denotes the unique two-cell between the evaluated endpoints. Thus the semantic comparison of paths is constant-time once common endpoints have been checked. In a non-codiscrete extension, path labels would need to be multiplied and compared, making the pentagon a genuine algebraic constraint.

## 8. Applications and interpretation

### 8.1. Staged computation

A composite process may retain scheduling information. Grouping $f$ with $g$ before attaching $h$ can produce a different execution object from attaching $g$ to $h$ first. A reversible scheduler transformation may connect the results without making them identical. Associators encode these transformations, while the pentagon says that reorganizing a four-stage process by two standard routes gives the same global translation.

### 8.2. Gluing and geometry

Geometric objects assembled in stages often depend on choices of representatives, collars, coordinates, or pullbacks. Two bracketings of a gluing operation may be canonically isomorphic rather than equal. Bicategorical language preserves this distinction. The codiscrete model strips away geometry but retains the logical pattern: unequal composites, invertible comparison, coherent rebracketing.

### 8.3. Semantics and interfaces

In compositional semantics, equality can be too rigid when intermediate interfaces differ. A two-cell may represent a refactoring, protocol adapter, or semantic equivalence. Coherence ensures that nested refactorings have a stable meaning independent of local reassociation choices.

### 8.4. Causal-loop metaphor

The phrase “causal loop” is useful if interpreted structurally rather than temporally. Repeated composition can return to comparable descriptions through different parenthesized routes. The loop closes not because all intermediate one-cells become equal, but because the higher comparisons around the loop agree. The pentagon is the first nontrivial global test of this closure.

## 9. Limitations and scope

Codiscreteness is both the strength and limitation of the construction. It makes every required comparison available and every coherence equation automatic. As a result, the example demonstrates genuine non-strictness at the one-cell level but has no nontrivial choice among two-cells. It cannot model competing higher transformations or detect a failure of the pentagon, because parallel two-cells are never distinct.

The phrase “almost-category” should therefore be used with care. A nonassociative composition alone does not determine a bicategory. One must add hom-categories, functorial horizontal composition, invertible associators and unitors, naturality, and coherence. Our construction succeeds because all these data are explicitly provided. Likewise, the broad claim that every coherent loop-tolerant algebra forms a higher category becomes meaningful only after the dimensions and coherence axioms are specified.

The example is one-object and hence algebraic. Multiple objects would introduce typing restrictions on composition and could encode networks of processes or geometric correspondences. Nontrivial two-cell automorphism groups would transform the coherence laws from tautologies into equations with genuine content.

## 10. Future directions

A first generalization replaces the particular twisted magma by an arbitrary unital magma. Giving its elements as one-cells of a one-object structure and making the hom-category codiscrete should turn every associativity and unit defect into a unique invertible two-cell. This would isolate the exact minimal data needed for functorial horizontal composition.

A second direction replaces singleton two-cell sets by a nontrivial automorphism group. Associators could then carry labels, and the pentagon would become a cocycle equation rather than a consequence of uniqueness. For skeletal one-object bicategories, this leads naturally toward normalized group-cohomological three-cocycles and obstruction theory.

A third direction compares strictness on fixed data with strictification up to biequivalence. Theorem 6.1 forbids literal strictness for the specified operation, but does not preclude replacement by an equivalent strict two-category. Making that contrast explicit would clarify precisely which data strictification preserves.

A fourth direction moves to tricategories, where transformations between associators are themselves related by invertible three-cells. This is the appropriate setting for iterated coherence in which loops among two-dimensional comparisons close one level higher.

Finally, finite unital magmas can be enumerated and classified by their associativity defects. Computation can measure how many triples are nonassociative, build rebracketing graphs, and test candidate labels for coherent associators. Such experiments would connect the elementary arithmetic model to a broader landscape of weak algebraic structures.

## 11. Conclusion

The twisted operation on natural numbers supplies a transparent associativity defect:

$$
(1\bigstar1)\bigstar1=5
\quad\text{but}\quad
1\bigstar(1\bigstar1)=7.
$$

By placing a unique two-cell between every pair of one-cells, we obtain invertible associators between all bracketings. Uniqueness forces naturality, the pentagon, the triangle, and every parallel coherence diagram. The result is a concrete bicategory that is coherent but not strict. Moreover, no strict bicategory can retain its fixed composition, because strict associativity would identify $5$ with $7$.

The construction cleanly separates two notions that ordinary algebra often conflates: equality of composites and reversible equivalence between composites. Higher-dimensional category theory does not erase the difference. It records the difference, controls it with an associator, and demands that all such controls agree. Coherence is thus not associativity recovered as equality; it is the disciplined mathematics of composing despite its failure.

A useful conceptual summary is that three layers play distinct roles. The unital magma provides the raw composites and exposes their defects. The codiscrete hom-category supplies reversible witnesses between any proposed endpoints. The bicategory axioms govern the interaction of those witnesses. None of these layers can be silently substituted for another: the two-cell $5\Rightarrow7$ does not alter arithmetic, and the inequality $5\ne7$ does not obstruct higher coherence. Their coexistence is exactly the phenomenon the construction was designed to display.
