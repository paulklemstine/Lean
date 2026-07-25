# Codiscrete One-Object Bicategories and the Associativity Obstruction to Strictness

**Aristotle**  
**24 July 2026**

## Abstract

We give a uniform construction of a one-object bicategory from any unital magma. The $1$-cells are the elements of the magma, their composition is the magma multiplication, and every pair of $1$-cells is connected by a unique $2$-cell. Codiscreteness makes all $2$-cells invertible and forces the pentagon, triangle, whiskering, and interchange laws: every coherence diagram compares parallel $2$-cells, and parallel $2$-cells are unique. We then characterize strictness on the fixed data. The resulting bicategory admits a strict structure if and only if the magma multiplication is associative. Thus the associator absorbs arbitrary associativity defects at the bicategorical level, while strictness detects those defects exactly. We illustrate the obstruction with a unital multiplication $\star$ on $\mathbb N$ for which $(1\star1)\star1=5$ and $1\star(1\star1)=7$. The associated bicategory is coherent and genuinely non-strict. We also present finite algorithms for associativity testing, defect enumeration, and coherence-path simulation, discuss complexity and applications, and identify extensions to nontrivial automorphism groups, cohomological obstructions, and strictification up to biequivalence.

## 1. Introduction

Associativity is the algebraic principle that permits parentheses to be omitted. A binary operation $*$ is associative when

$$
(a*b)*c=a*(b*c)
$$

for all triples. Ordinary categories impose this equation on composition. Bicategories weaken the equation without abandoning control: the two bracketings need not be equal as $1$-cells, but they must be connected by a specified invertible $2$-cell, the associator. Associators must themselves satisfy the pentagon coherence law, while identity $1$-cells are governed by left and right unitors satisfying a triangle law.

This distinction between equality and coherent equivalence appears throughout higher-dimensional algebra. It is especially clear in the one-object case, where $1$-cell composition resembles multiplication. The present construction asks how little algebra is needed to support a bicategory. The answer is: a binary operation with a two-sided unit is enough, provided the hom-category is codiscrete.

Let $(M,*,e)$ be a unital magma, with no associativity hypothesis. Construct a single-object system whose $1$-cells are elements of $M$. Declare exactly one $2$-cell between each ordered pair of $1$-cells. Then every desired structural comparison exists uniquely. In particular, there is a unique invertible associator

$$
\alpha_{a,b,c}:(a*b)*c\Rightarrow a*(b*c).
$$

All coherence equations follow from uniqueness. This turns every unital magma, associative or not, into a bicategory.

The construction does not trivialize the distinction between weak and strict composition. If a strict structure is required on the same $1$-cells and the same multiplication, strict associativity becomes an equality in $M$. Conversely, if $M$ is associative, codiscreteness ensures that all comparison data agree with the equality-induced comparisons. We obtain the exact criterion

$$
\text{strictness on the fixed data}\quad\Longleftrightarrow\quad\text{associativity of }*.
$$

The phrase “on the fixed data” matters. A bicategory may potentially be biequivalent to a strict $2$-category after changing its presentation. Our negative result concerns the stronger demand that the given $1$-cells and their given multiplication themselves support strictness.

The paper is organized as follows. Section 2 introduces the required definitions. Section 3 constructs the codiscrete bicategory and establishes coherence. Section 4 proves the strictness characterization. Section 5 gives a concrete nonassociative operation on the natural numbers. Section 6 develops computational procedures. Sections 7 and 8 discuss interpretation, applications, limitations, and future directions.

## 2. Definitions and basic structure

### 2.1. Unital magmas

**Definition 2.1 (Unital magma).** A **unital magma** is a triple $(M,*,e)$ consisting of a set $M$, a binary operation $*:M\times M\to M$, and an element $e\in M$ such that

$$
e*a=a,
\qquad
a*e=a
$$

for every $a\in M$.

No equation is imposed on products of three nonunit elements. A **monoid** is a unital magma satisfying associativity:

$$
(a*b)*c=a*(b*c)
$$

for all $a,b,c\in M$.

**Definition 2.2 (Associativity defect).** An **associativity defect** is a triple $(a,b,c)\in M^3$ for which

$$
(a*b)*c\ne a*(b*c).
$$

The ordered pair

$$
\delta(a,b,c)=\big((a*b)*c,\ a*(b*c)\big)
$$

will be called the endpoint defect at $(a,b,c)$. This terminology records two endpoints rather than attempting subtraction, since a general magma has no additive structure.

### 2.2. Codiscrete categories

**Definition 2.3 (Codiscrete category).** Given a set $S$, its **codiscrete category** has the elements of $S$ as objects and exactly one morphism $x\to y$ for every ordered pair $(x,y)$.

Identities and composition are forced by uniqueness. Every morphism $x\to y$ is invertible: the unique morphism $y\to x$ is its inverse, since each composite is the unique endomorphism of its endpoint, hence the identity.

**Lemma 2.4 (Uniqueness of parallel arrows).** In a codiscrete category, any two morphisms with the same source and target are equal. Consequently, any two isomorphisms with the same source and target are equal.

**Proof sketch.** There is exactly one member of each hom-set by definition. An isomorphism is determined by its forward arrow, and that arrow is unique. $\square$

### 2.3. Bicategories

A bicategory consists of objects, $1$-cells between objects, and $2$-cells between parallel $1$-cells. Each pair of objects has a hom-category: its objects are the $1$-cells and its morphisms are the $2$-cells. There are identity $1$-cells and a composition operation on $1$-cells. Horizontal operations on $2$-cells include left and right whiskering.

Composition of $1$-cells is associative and unital only up to specified invertible $2$-cells. For composable $1$-cells $f,g,h$, the associator is

$$
\alpha_{f,g,h}:(f\circ g)\circ h\Rightarrow f\circ(g\circ h).
$$

For a $1$-cell $f:A\to B$, the unitors are

$$
\lambda_f:1_A\circ f\Rightarrow f,
\qquad
\rho_f:f\circ1_B\Rightarrow f.
$$

These data obey naturality, functoriality of whiskering, interchange, the pentagon law for four composable $1$-cells, and the triangle law connecting associator and unitors.

**Definition 2.5 (Strict structure on fixed data).** A bicategory is **strict on its fixed data** if the existing composition satisfies literal identity and associativity equalities, and its unitors and associator coincide with the canonical isomorphisms induced by those equalities. Thus strictness requires more than the mere existence of some invertible comparisons.

## 3. The codiscrete construction

Fix a unital magma $(M,*,e)$.

**Construction 3.1.** Define a higher-dimensional compositional system as follows.

1. There is one object, denoted $\bullet$.
2. The $1$-cells $\bullet\to\bullet$ are the elements of $M$.
3. The identity $1$-cell is $e$.
4. The composite of $a$ followed by $b$ is $a*b$.
5. For every $a,b\in M$, there is exactly one $2$-cell $a\Rightarrow b$.
6. Vertical composition and identity $2$-cells are those of the codiscrete category.
7. Whiskering and horizontal composition are the unique $2$-cells with the required endpoints.
8. The associator and unitors are the unique isomorphisms with the required endpoints.

The direction convention for $a*b$ is immaterial to the structural results, provided it is used consistently.

**Lemma 3.2 (Invertibility of structural comparisons).** Every $2$-cell in Construction 3.1 is invertible. In particular, all associators and unitors are isomorphisms.

**Proof sketch.** Given the unique $2$-cell $u:a\Rightarrow b$, let $v:b\Rightarrow a$ be the unique reverse $2$-cell. The composites $v\circ u$ and $u\circ v$ are respectively the unique endomorphisms of $a$ and $b$, and therefore are identities. $\square$

**Theorem 3.3 (Codiscrete Bicategory Theorem).** Every unital magma $(M,*,e)$ gives rise to a one-object bicategory by Construction 3.1, regardless of whether $*$ is associative.

**Proof sketch.** The hom-category is codiscrete, so its identities and vertical compositions satisfy the category laws. Every operation on $2$-cells is uniquely determined by its endpoints. The unit conditions on the $1$-cell identity follow from $e*a=a$ and $a*e=a$.

For $a,b,c\in M$, the required associator is the unique isomorphism

$$
\alpha_{a,b,c}:(a*b)*c\Rightarrow a*(b*c).
$$

It exists even when the endpoints are unequal. The unitors are the unique isomorphisms

$$
\lambda_a:e*a\Rightarrow a,
\qquad
\rho_a:a*e\Rightarrow a.
$$

All remaining bicategory laws are equalities between parallel $2$-cells. This includes identity and composition laws for whiskering, compatibility of left and right whiskering, interchange, naturality of structural isomorphisms, the pentagon, and the triangle. By Lemma 2.4, each such pair is equal. $\square$

### 3.1. The pentagon and triangle

For four $1$-cells $a,b,c,d$, the pentagon compares two composites of associators from

$$
((a*b)*c)*d
$$

to

$$
a*(b*(c*d)).
$$

The intermediate bracketings may all be distinct elements of $M$. Nevertheless, the two boundary routes are parallel $2$-cells, so codiscreteness identifies them.

The triangle compares the route using an associator and a unitor with the route using the other unitor. Its endpoints involve a unit $e$, and the magma unit laws identify the appropriate $1$-cells. Again, the two resulting $2$-cells are parallel and therefore equal.

**Corollary 3.4 (Automatic coherence).** In the codiscrete construction, every well-typed diagram of $2$-cells commutes.

**Proof sketch.** Any two paths in such a diagram with common source and target compose to parallel $2$-cells. Parallel $2$-cells are unique. $\square$

This corollary is stronger than the specific pentagon and triangle requirements. It explains why no hidden higher coherence obstruction appears in the construction.

## 4. Strictness and associativity

We now determine exactly when Construction 3.1 can be strict without changing $M$, $*$, or $e$.

**Proposition 4.1 (Strictness forces associativity).** If the codiscrete bicategory associated with $(M,*,e)$ admits a strict structure on its fixed data, then $*$ is associative.

**Proof sketch.** A strict structure supplies literal equality

$$
(a*b)*c=a*(b*c)
$$

for every triple of $1$-cells. Since the $1$-cells are exactly the elements of $M$ and their composition is exactly $*$, this is the associative law in $M$. $\square$

**Proposition 4.2 (Associativity produces strictness).** If $*$ is associative, then the codiscrete bicategory associated with $(M,*,e)$ admits a strict structure on its fixed data.

**Proof sketch.** The left and right identity equalities are the unit axioms of the magma. The associativity equality is the hypothesis. It remains to compare the pre-existing bicategorical unitors and associator with the canonical isomorphisms induced by these equalities. In each case, the two isomorphisms have identical endpoints in a codiscrete hom-category. Lemma 2.4 makes them equal. Thus all requirements of strictness hold. $\square$

**Theorem 4.3 (Strictness Characterization).** Let $(M,*,e)$ be a unital magma. Its associated codiscrete one-object bicategory admits a strict structure on the fixed $1$-cells and fixed composition if and only if $M$ is associative.

**Proof sketch.** Proposition 4.1 proves necessity and Proposition 4.2 proves sufficiency. $\square$

**Corollary 4.4 (Monoid case).** Every monoid gives rise to a strict codiscrete one-object bicategory.

**Proof sketch.** A monoid is associative by definition, so Theorem 4.3 applies. $\square$

**Corollary 4.5 (Defect obstruction).** If a unital magma has even one associativity defect, then its codiscrete bicategory is coherent but admits no strict structure on its fixed data.

**Proof sketch.** Coherence follows from Theorem 3.3. A defect negates associativity, so Theorem 4.3 rules out strictness. $\square$

### 4.1. Why codiscreteness is essential to sufficiency

Associativity of the underlying multiplication alone need not force an arbitrary bicategory structure to be strict. Strictness also asks that chosen unitors and associators agree with equality-induced isomorphisms. If hom-categories contain multiple parallel automorphisms, those choices can differ. Codiscreteness removes this ambiguity: there is only one candidate.

Thus the two implications of Theorem 4.3 rest on different mechanisms. Necessity extracts an algebraic equation from strictness. Sufficiency constructs strict structure using the algebraic equation plus uniqueness of comparison maps.

## 5. A concrete genuinely non-strict example

Define a binary operation $\star$ on $\mathbb N$ by

$$
a\star b=
\begin{cases}
b,&a=0,\\
a,&b=0,\\
a+2b,&a>0\text{ and }b>0.
\end{cases}
$$

**Lemma 5.1 (Unit law).** The element $0$ is a two-sided unit for $\star$.

**Proof sketch.** The first branch gives $0\star b=b$. If $a>0$, the second branch gives $a\star0=a$; when $a=0$, both sides are $0$. $\square$

**Lemma 5.2 (Explicit associativity defect).** The triple $(1,1,1)$ is an associativity defect for $\star$, with

$$
(1\star1)\star1=5
\qquad\text{and}\qquad
1\star(1\star1)=7.
$$

**Proof sketch.** Since both inputs are positive, $1\star1=1+2=3$. Therefore

$$
(1\star1)\star1=3\star1=3+2=5,
$$

while

$$
1\star(1\star1)=1\star3=1+6=7.
$$

Since $5\ne7$, associativity fails. $\square$

**Theorem 5.3 (Concrete Non-Strict Bicategory).** The one-object codiscrete bicategory associated with $(\mathbb N,\star,0)$ is coherent and genuinely non-strict on its fixed data. Its associator at $(1,1,1)$ is the unique invertible $2$-cell

$$
5\Rightarrow7,
$$

and no strict structure can retain the same $1$-cells and composition.

**Proof sketch.** Lemma 5.1 permits the codiscrete construction, and Theorem 3.3 supplies the bicategory and all coherence laws. Lemma 5.2 shows that $\star$ is not associative. Theorem 4.3 therefore rules out strictness. $\square$

For positive $a,b,c$, the defect has a simple closed form. Because all intermediate values are positive,

$$
(a\star b)\star c=(a+2b)+2c=a+2b+2c,
$$

whereas

$$
a\star(b\star c)=a+2(b+2c)=a+2b+4c.
$$

The right bracketing exceeds the left by $2c$. Hence every positive triple is a defect. The witness $(1,1,1)$ is merely the smallest.

**Proposition 5.4 (Positive defect formula).** If $a,b,c>0$, then

$$
a\star(b\star c)-((a\star b)\star c)=2c>0.
$$

**Proof sketch.** Expand both products using the positive-input branch and subtract. $\square$

## 6. Algorithms and numerical exploration

Although the construction is structural, finite examples admit direct analysis.

### 6.1. Associativity decision algorithm

Let $M$ be finite with $n$ elements and suppose multiplication is provided by a lookup table.

**Algorithm 6.1 (Exhaustive strictness test).** Iterate through every $(a,b,c)\in M^3$. Compute $L=(a*b)*c$ and $R=a*(b*c)$. If $L\ne R$, return “non-strict” with witness $(a,b,c,L,R)$. If no witness occurs, return “strict.”

**Proposition 6.2 (Correctness).** Algorithm 6.1 returns “strict” exactly when the associated codiscrete bicategory admits a strict structure.

**Proof sketch.** The algorithm returns “strict” exactly when the multiplication is associative. Apply Theorem 4.3. When it returns a witness, Corollary 4.5 makes that witness a certificate of non-strictness. $\square$

With constant-time table access, the worst-case running time is $O(n^3)$ and the auxiliary space is $O(1)$. Early termination can make nonassociative cases much faster.

### 6.2. Defect enumeration

**Algorithm 6.3 (Associativity defect census).** For each triple in $M^3$, compute both bracketings and record the triple and endpoints whenever they differ.

The running time is $O(n^3)$. Output storage is $O(k)$, where $k\le n^3$ is the number of defects. The ratio $k/n^3$ gives a simple finite measure of how frequently multiplication fails associativity. This statistic does not alter the strictness criterion—one defect is enough—but it distinguishes sparse from pervasive failure.

### 6.3. Coherence-path simulation

For a word of four elements, compute the five parenthesized products:

$$
((a*b)*c)*d,
\quad
(a*(b*c))*d,
\quad
(a*b)*(c*d),
\quad
a*((b*c)*d),
\quad
a*(b*(c*d)).
$$

These may be five different $1$-cells. The pentagon consists of canonical $2$-cells between adjacent bracketings. In the codiscrete setting, both composites from the leftmost to the rightmost endpoint are the unique $2$-cell between those endpoints. A simulator can display numerical endpoints and graph edges, but equality of paths follows structurally from uniqueness rather than from equality of endpoint values.

For the twisted product and the word $(1,1,1,1)$, the five values need not collapse. Their diversity visualizes why bicategorical coherence is not the same as numerical associativity.

## 7. Interpretation and applications

### 7.1. Equality versus coherent comparison

The construction isolates the logical role of the associator. An associator does not assert that its source and target $1$-cells are equal. It supplies a reversible $2$-dimensional comparison. In the concrete example, $5$ and $7$ remain distinct natural numbers even though the bicategory contains an invertible $2$-cell between the corresponding $1$-cells.

This is analogous to distinguishing equal objects from canonically isomorphic objects. At the next categorical dimension, the comparison itself must satisfy coherence. Codiscreteness guarantees that coherence because no alternative comparison is available.

### 7.2. Process composition

A unital magma can model processes whose combination has an identity but whose intermediate grouping matters. The construction says that such processes can still inhabit a coherent two-dimensional calculus if all processes are treated as uniquely intertransformable. This codiscrete assumption is too strong for many applications, but it provides a baseline model separating endpoint behavior from coherence behavior.

Potential interpretations include workflow aggregation, syntax trees with rebracketing transformations, stateful data pipelines, and coarse models of distributed composition. In each case, literal outcomes may depend on grouping while a higher-level semantics identifies all outcomes through canonical transformations.

### 7.3. Rewriting and parsing

Binary expressions correspond to parenthesized trees. Associators rotate one tree into another. For a sequence of four factors, the rotation graph is a pentagon. The codiscrete bicategory labels every allowable comparison uniquely, making every rebracketing path equivalent. This provides a minimal semantic model of confluent rebracketing even when evaluation in the underlying magma is not invariant under tree rotation.

### 7.4. The scope of the obstruction

Theorem 4.3 rules out strictness only on fixed data. It does not claim that the bicategory cannot be replaced by a biequivalent strict $2$-category. Equality of presentations and equivalence of higher categories are different notions. This distinction is central: a strictification theorem at the level of biequivalence can coexist with an obstruction to imposing strictness on a chosen multiplication.

## 8. Discussion, limitations, and future work

The construction is deliberately extreme. Codiscreteness ensures existence, invertibility, and uniqueness of every $2$-cell. As a result, all coherence diagrams commute, but they carry no additional information. This is both the strength and the limitation of the model.

The principal result is a sharp dichotomy: the codiscrete bicategory attached to a unital magma is strict exactly when the magma is associative. The associator absorbs every endpoint defect sufficiently to form a bicategory, yet it cannot turn unequal endpoints into equal ones. In this sense, the associator is both a remedy for nonassociativity and a witness to the obstruction against strictness.

Several extensions follow naturally.

First, one may replace unique $2$-cells by nontrivial automorphism groups. If automorphisms are valued in an abelian group $A$, associators become choices rather than forced arrows. The pentagon should then become a normalized $3$-cocycle equation, and changing associators by coherent reparameterization should correspond to adding a $3$-coboundary.

Second, in a one-object bicategory whose $1$-cells form a group, the obstruction to strictification on fixed $1$-cells is expected to define a class in third group cohomology. The codiscrete case has trivial automorphism coefficients, so this richer invariant collapses and only endpoint associativity remains.

Third, strictification up to biequivalence should be studied separately from strictness on fixed data. The concrete theorem excludes the latter for nonassociative multiplication but leaves open replacement by an equivalent strict $2$-category.

Fourth, higher analogues can introduce $3$-cells witnessing coherence among associators. Tricategorical models would make it possible to ask when distinct proofs of bicategorical coherence are themselves coherently related.

Finally, finite computation offers a systematic experimental program. Small unital magmas can be enumerated, their associativity defects classified, and their defect densities compared. Introducing nontrivial $2$-cell labels would allow computational searches for cocycles and coboundaries.

## 9. Conclusion

Every unital magma supports a one-object bicategory when its hom-category is made codiscrete. Arbitrary associativity defects are bridged by unique invertible associators, and all coherence follows from uniqueness of parallel $2$-cells. Strictness remains exacting: it exists on the fixed data if and only if multiplication is associative.

The twisted natural-number product supplies a concrete witness. Its unit is $0$, but the two bracketings of three copies of $1$ evaluate to $5$ and $7$. The associated bicategory contains a coherent reversible comparison from one to the other, while the inequality prevents any strict structure using the same composition.

The resulting picture is concise but foundational. Weak composition does not erase algebraic defects; it relocates them into a higher dimension and controls them through coherence. Codiscreteness is the limiting case in which that control is automatic. Moving beyond it leads directly toward cocycles, cohomological obstructions, and the distinction between strict equality and equivalence in higher category theory.