# Additive Steiner Completion and Nonassociative Hall Coordinates

## A structural bridge between nine-point triple geometry, nuclei, and symmetry loss

**Aristotle**  
**20 July 2026**

## Abstract

We study a nine-point coordinate system whose additive structure is $H=(\mathbb Z/3\mathbb Z)^2$ and whose canonical third-point operation is $T(x,y)=-(x+y)$. The exponent-three identity $3x=0$ turns this operation into a Steiner triple geometry: every distinct pair has a unique completion, the three completed points are pairwise distinct, and translations preserve all triples. We prove a general preservation theorem stating that every zero-preserving additive map between abelian groups commutes with third-point completion. Applied to the right-distributive Hall multiplication on $H$, this implies that every right multiplication preserves the additive triple structure. At the same time, the multiplication is nonassociative in a precise sense: its left nucleus is a proper subset of $H$. Thus triple preservation and associativity failure coexist but arise from logically separate laws. For the associated Hall family, we also state a quantitative comparison with the projective-linear benchmark: for every integer $q\ge 3$, the Hall collineation order is strictly smaller, and the benchmark-to-Hall ratio, with a harmless unit regularization in the denominator, is at least $q^4$. We provide finite algorithms for enumerating triples, checking preservation, computing nuclei, and testing the numerical bound. The results illustrate how a compact algebraic “genome” can preserve an incidence skeleton while encoding a substantial departure from classical field geometry.

## 1. Introduction

A coordinate system does more than label points. Its algebra determines which configurations are natural, which transformations preserve them, and which classical geometric laws remain valid. The simplest example is affine geometry over a field: addition generates translations, scalar multiplication generates dilations, and associativity and distributivity support the familiar theory of lines and planes. More unusual coordinate algebras can preserve part of this architecture while breaking another part.

The present study isolates such a phenomenon on nine points. The carrier is

$$
H=(\mathbb Z/3\mathbb Z)^2,
$$

with componentwise addition. Given $x,y\in H$, define their third-point completion by

$$
T(x,y)=-(x+y).
$$

The resulting equation

$$
x+y+T(x,y)=0
$$

encodes a three-point block. Since $H$ has exponent three, this completion behaves exactly as the third point of a Steiner triple system should: it is symmetric, reversible, and distinct from either input whenever the inputs are distinct.

The same carrier supports a Hall-type multiplication, written $x\circ y$. The feature relevant here is right distributivity: for every fixed $c$, the map $x\mapsto x\circ c$ preserves addition and zero. Consequently, right multiplication preserves the additive triples. However, the multiplication is not associative. Its left nucleus—the elements that associate on the left with every pair of factors—is proper.

The two facts form the main structural bridge of the paper. They show that a rich incidence pattern can be stable under a family of algebraic transformations even though the ambient multiplication fails a central field law. The preservation theorem uses additivity only; the nucleus theorem records associativity failure separately. This logical separation clarifies exactly what survives when the coordinate algebra departs from the classical setting.

A second theme is quantitative. In the broader Hall family, the order of the collineation group lies strictly below a projective-linear benchmark, and the normalized gap grows at least as $q^4$. This turns “loss of symmetry” from a qualitative observation into a scale-dependent estimate.

The paper is organized as follows. Section 2 introduces additive completion. Section 3 proves the abstract identities and the Steiner property on $H$. Section 4 establishes functorial preservation by additive maps. Section 5 applies this principle to Hall right multiplication and contrasts it with the proper left nucleus. Section 6 presents the symmetry estimate. Section 7 gives computational algorithms and examples. Sections 8–10 discuss interpretation, applications, limitations, and future work.

## 2. Additive third-point geometry

### 2.1. The ambient group

Let $A$ be an abelian group, written additively, with identity $0$ and inverse $-x$. We use the following operation.

**Definition 2.1 (third-point completion).** For $x,y\in A$, define

$$
T_A(x,y)=-(x+y).
$$

When the group is clear, we write $T(x,y)$. A triple $(x,y,z)$ is called an **additive zero-sum triple** if $x+y+z=0$. By construction, $(x,y,T(x,y))$ is always such a triple.

**Definition 2.2 (exponent three).** An abelian group $A$ has exponent three if

$$
x+x+x=0
$$

for every $x\in A$.

The group $H=(\mathbb Z/3\mathbb Z)^2$ has exponent three because each coordinate does. It contains nine points.

### 2.2. Universal completion identities

The first two identities do not require exponent three.

**Theorem 2.3 (symmetry and involution).** In every abelian group $A$, third-point completion satisfies

$$
T(x,y)=T(y,x)
$$

and

$$
T(x,T(x,y))=y
$$

for all $x,y\in A$.

**Proof sketch.** Commutativity gives $x+y=y+x$, and taking negatives yields symmetry. For involution, expand the definition:

$$
T(x,T(x,y))=-\bigl(x+(-(x+y))\bigr)
=-(-y)=y.
$$

Only the abelian-group laws are used. $\square$

The second identity says that for fixed $x$, the map $y\mapsto T(x,y)$ is an involution. Therefore completion is reversible: knowing any two entries of a zero-sum triple determines the third.

### 2.3. Distinctness in exponent three

Exponent three rules out degeneracy.

**Lemma 2.4 (distinct completion).** Let $A$ be an abelian group of exponent three. If $x\ne y$, then

$$
T(x,y)\ne x
\qquad\text{and}\qquad
T(x,y)\ne y.
$$

**Proof sketch.** Suppose $T(x,y)=x$. Then $-(x+y)=x$, so $2x+y=0$. Since $3x=0$, subtraction gives $y=x$, a contradiction. The other inequality follows by symmetry. $\square$

This lemma is the point at which the exponent-three law becomes geometrically decisive.

**Theorem 2.5 (Steiner completion on the nine-point group).** Let $H=(\mathbb Z/3\mathbb Z)^2$. For every pair $x,y\in H$, there is a unique point $z$ satisfying

$$
z=T(x,y).
$$

If $x\ne y$, then $x$, $y$, and $z$ are pairwise distinct. Consequently, the subsets

$$
\{x,y,T(x,y)\},\qquad x\ne y,
$$

form a Steiner triple system: every unordered pair of distinct points belongs to exactly one three-point block.

**Proof sketch.** Existence and uniqueness follow directly from the explicit formula $z=-(x+y)$. Pairwise distinctness follows from Lemma 2.4. If an unordered pair $\{x,y\}$ lay in two blocks, both third points would have to equal the unique completion $T(x,y)$. $\square$

There are $\binom 92=36$ unordered pairs. Each block contains three pairs, so the system contains

$$
\frac{36}{3}=12
$$

blocks. This count also follows by direct enumeration.

## 3. Translation covariance

Translations are the basic symmetries of an additive geometry.

**Theorem 3.1 (translation covariance).** Let $A$ be an abelian group of exponent three. For all $x,y,t\in A$,

$$
T(x+t,y+t)=T(x,y)+t.
$$

**Proof sketch.** Expand the left side:

$$
T(x+t,y+t)=-(x+y+2t)=-(x+y)-2t.
$$

Because $3t=0$, one has $-2t=t$. Substitution gives the result. $\square$

Thus every translation $\tau_t(x)=x+t$ maps blocks to blocks. In $H$, translations act transitively on points: any point can be moved to any other point by choosing the appropriate $t$. The triple system is therefore spatially homogeneous.

A useful distinction is visible here. The identity $T(x,T(x,y))=y$ is universal for abelian groups, whereas translation covariance in the displayed form depends on exponent three. Keeping these hypotheses separate prevents the geometric argument from attributing too much to a single law.

## 4. Preservation by additive maps

The completion operation is natural with respect to additive maps.

**Theorem 4.1 (additive preservation).** Let $A$ and $B$ be abelian groups. Suppose $f:A\to B$ satisfies

$$
f(0)=0
$$

and

$$
f(x+y)=f(x)+f(y)
$$

for all $x,y\in A$. Then

$$
f(T_A(x,y))=T_B(f(x),f(y))
$$

for all $x,y\in A$.

**Proof sketch.** Additivity and preservation of zero imply preservation of inverses, because

$$
f(-a)+f(a)=f(-a+a)=f(0)=0,
$$

so $f(-a)=-f(a)$. Therefore

$$
f(T_A(x,y))=f(-(x+y))=-f(x+y)=-(f(x)+f(y))=T_B(f(x),f(y)).
$$

$\square$

This theorem is stronger than a statement about the nine-point example. It identifies the exact mechanism behind triple preservation. No multiplication, finiteness, or exponent assumption is needed. Whenever completion is defined by the negative of a sum, additive maps commute with it.

**Corollary 4.2 (transport of zero-sum triples).** Under the hypotheses of Theorem 4.1, if $x+y+z=0$ and $z=T_A(x,y)$, then

$$
f(x)+f(y)+f(z)=0
$$

and $f(z)=T_B(f(x),f(y))$.

**Proof sketch.** Apply the theorem to $z=T_A(x,y)$ and use the definition of completion in $B$. $\square$

The corollary explains why the construction is robust under coordinate changes. Any additive isomorphism carries the entire triple system to an isomorphic one.

## 5. Hall multiplication: preservation without associativity

### 5.1. Structural assumptions

Equip $H$ with a Hall-type multiplication $\circ$. The results below use two established properties.

First, right multiplication is additive and zero-preserving: for each $c\in H$,

$$
(a+b)\circ c=(a\circ c)+(b\circ c)
$$

and

$$
0\circ c=0.
$$

Second, multiplication is nonassociative: there exist $a,b,c\in H$ such that

$$
a\circ(b\circ c)\ne(a\circ b)\circ c.
$$

The first property controls the triple geometry; the second distinguishes the coordinate algebra from an associative ring or field.

### 5.2. Right multiplication preserves completion

**Theorem 5.1 (right-multiplication preservation).** For every $x,y,c\in H$,

$$
T(x,y)\circ c=T(x\circ c,y\circ c).
$$

**Proof sketch.** Fix $c$ and define $R_c(x)=x\circ c$. Right distributivity and $0\circ c=0$ say exactly that $R_c$ is zero-preserving and additive. Theorem 4.1 then yields

$$
R_c(T(x,y))=T(R_c(x),R_c(y)),
$$

which is the displayed identity. $\square$

This proof isolates a reusable pattern: first view an algebraic action as an additive map, then invoke the naturality of completion. The triple-preserving conclusion does not depend on associativity.

### 5.3. The associativity nucleus

**Definition 5.2 (left nucleus).** The left nucleus of $(H,\circ)$ is

$$
N_{\ell}=\{a\in H: a\circ(b\circ c)=(a\circ b)\circ c\text{ for all }b,c\in H\}.
$$

An element belongs to $N_{\ell}$ precisely when it never witnesses a failure of associativity while occupying the leftmost position.

**Theorem 5.3 (proper left nucleus).** The left nucleus is a proper subset of $H$:

$$
N_{\ell}\ne H.
$$

**Proof sketch.** Nonassociativity supplies $a,b,c\in H$ with

$$
a\circ(b\circ c)\ne(a\circ b)\circ c.
$$

That particular $a$ fails the defining condition for membership in $N_{\ell}$. Hence not every element lies in the nucleus. $\square$

The theorem packages a global failure of associativity as a geometrically meaningful distinguished subset.

**Theorem 5.4 (triple–nonassociativity bridge).** In the order-nine Hall coordinate algebra, the following statements hold simultaneously:

1. every right multiplication preserves additive third-point completion;
2. the left nucleus is a proper subset of the nine-point carrier.

**Proof sketch.** Statement 1 is Theorem 5.1 and statement 2 is Theorem 5.3. Their conjunction is meaningful because the arguments use different structural laws: additivity of right multiplication proves preservation, while an associativity counterexample proves properness. $\square$

The bridge theorem is the principal conceptual result. It demonstrates that incidence preservation does not force an associative coordinate algebra. Conversely, nonassociativity does not erase every geometric regularity.

## 6. Quantitative loss of projective-linear symmetry

Let $q$ be an integer with $q\ge 3$. Denote by $C(q)$ the Hall-family collineation order and by $P(q^2)$ the order of the corresponding projective-linear benchmark over the parameter $q^2$. The exact formulas are not needed for the structural conclusion; what matters is the proved comparison.

**Theorem 6.1 (Hall-family symmetry gap).** For every integer $q\ge 3$,

$$
C(q)<P(q^2)
$$

and

$$
q^4\le \left\lfloor\frac{P(q^2)}{C(q)+1}\right\rfloor.
$$

**Proof sketch.** The first inequality follows from the order comparison between the Hall collineation family and the projective-linear family. The second follows from the corresponding growth estimate for their ratio. Combining the two estimates gives the stated conjunction. $\square$

The denominator $C(q)+1$ avoids degeneracy and makes the integer quotient unambiguous. The first inequality records strict symmetry loss. The second proves that the benchmark is not merely larger by a constant factor: the regularized ratio is at least quartic in $q$.

This statement is deliberately limited. Group-order comparison alone does not classify a collineation group, and nonassociativity alone does not constitute a complete incidence-level derivation of every non-Desarguesian property. The theorem asserts the numerical gap and no more.

## 7. Algorithms and numerical examples

All finite computations below use points represented as pairs $(a,b)$ with coordinates reduced modulo $3$.

### 7.1. Unique block enumeration

To enumerate the Steiner system, loop over unordered pairs $x<y$, compute $z=-(x+y)$ coordinatewise modulo $3$, sort the three points, and insert the resulting triple into a set. There are $36$ pairs, each requiring constant-time arithmetic. The algorithm therefore runs in $O(n^2)$ time for $n=9$ points and uses $O(b)$ storage for $b=12$ blocks.

For instance,

$$
T((1,0),(0,1))=(2,2),
$$

so $\{(0,1),(1,0),(2,2)\}$ is a block. Likewise,

$$
T((0,0),(1,2))=(2,1),
$$

so $\{(0,0),(1,2),(2,1)\}$ is a block.

A complete enumeration returns exactly twelve distinct blocks and confirms that each of the $36$ unordered pairs appears once.

### 7.2. Testing an additive map

A map $f:H\to H$ can be checked for additivity by testing all $9^2=81$ ordered pairs. If it is additive and sends zero to zero, no separate triple-preservation search is mathematically necessary: Theorem 4.1 guarantees preservation. For demonstration, one may nevertheless test all $9^2$ pairs and compare

$$
f(T(x,y))
$$

with

$$
T(f(x),f(y)).
$$

For the linear map

$$
f(a,b)=(a+b,a+2b)\pmod 3,
$$

all tests succeed.

### 7.3. Computing a left nucleus

Given the full multiplication table of any finite magma $(M,\circ)$, the left nucleus is computed by retaining those $a\in M$ for which the associativity equation holds for every pair $(b,c)\in M^2$. This requires at most $|M|^3$ comparisons and $O(|M|)$ output storage. A proper result is equivalent to finding at least one associativity witness.

### 7.4. Checking the symmetry inequality

If routines for $C(q)$ and $P(q^2)$ are supplied, the symmetry theorem is numerically checked by evaluating

$$
C(q)<P(q^2)
$$

and

$$
q^4\le P(q^2)\mathbin{//}(C(q)+1),
$$

where $//$ denotes integer division. Each test uses a constant number of arithmetic operations; bit complexity is governed by multiplication and division of integers whose lengths grow logarithmically with the order values.

## 8. Applications and interpretation

### 8.1. Incidence geometry from additive data

The construction offers an economical representation of a Steiner triple system. Rather than store twelve blocks independently, one stores the group law and recovers every block by $T(x,y)=-(x+y)$. This is useful in combinatorial generation, coding constructions, and experimental geometry, where canonical completion avoids ambiguity.

### 8.2. Structure-preserving transformations

The additive preservation theorem gives a certification principle. To prove that a transformation preserves all triples, it is enough to prove that it preserves zero and addition. This reduces a potentially quadratic block-by-block task to verification of algebraic laws. In finite implementations the laws can still be tested exhaustively, but the theorem explains why the test succeeds and generalizes beyond nine points.

### 8.3. Separating inherited structure from mutation

The coexistence theorem is also a model for comparing axiom systems. Associativity may be altered while right additivity remains. The inherited additive layer continues to support triples and their preservers, whereas the altered multiplicative layer creates a proper nucleus. This suggests viewing a theory through its structures and structure-preserving maps rather than through syntax alone: a change in one axiom can preserve a substantial semantic substructure.

### 8.4. Symmetry as a quantitative diagnostic

The quartic lower bound gives a scalable diagnostic of departure from the classical benchmark. It complements local algebraic witnesses. A single associativity failure proves that the multiplication is nonassociative; the family estimate shows that the associated symmetry deficit grows systematically with the parameter.

## 9. Discussion and limitations

Three logical boundaries deserve emphasis.

First, the involution identity for completion is more general than the exponent-three geometry. It follows in every abelian group, but pairwise distinct Steiner blocks require the additional exponent-three argument.

Second, preservation by right multiplication follows from right additivity and preservation of zero. It does not require associativity. This is not an accidental omission but the reason preservation and nonassociativity can coexist.

Third, neither nonassociativity nor a symmetry-order inequality should be overinterpreted. A complete incidence classification requires additional hypotheses and arguments. In particular, universal claims about nonclassical planes at every prime-power order would be false in small orders where the projective plane is uniquely classical. The order-nine construction and the valid parameterized symmetry estimate avoid such claims.

The phrase “algebraic genome” is therefore best understood as a structural metaphor. The exponent law, additive completion, distributivity, and nucleus encode different phenotypic features of the geometry. The metaphor does not assert that every theorem is literally reducible to one operation; rather, it highlights how compact algebraic laws govern families of objects and transformations.

## 10. Future research

A natural next step is to place these finite examples in a broader semantic framework. One may regard a mathematical theory through its category of models and ask how axiom changes induce functors, adjunctions, localizations, or quotients between model categories. Several concrete directions emerge.

A **localization–monad–Morita factorization** would seek to decompose suitable interpretations of essentially algebraic theories into a reflective localization, a free construction for a finitary monad, and a final equivalence of model categories. Such a decomposition would separate discarding models, freely adding operations, and changing presentation without changing semantic content.

A **classification by mutation monads** would ask whether reflective axiom additions over a coherent base theory are equivalent precisely when their induced idempotent monads are isomorphic. This would encode a closure operation independently of incidental syntax.

A **reversible mutation criterion** would characterize equivalences by invertibility of the unit and counit of an adjunction. In locally presentable settings, it is plausible that testing these maps on a small dense subcategory of finitely presentable models suffices.

A **homotopy-invariant genome** would replace ordinary model categories by simplicial localizations, retaining higher deformation information and treating Quillen equivalences as reversible evolutionary paths.

Finally, **logical contexts as semantic operators** would study finitary propositional contexts as endofunctors on suitable categories of valuations and entailments, with substitution of semantically equivalent formulas represented by natural isomorphisms.

For the finite Hall setting itself, further work includes determining the exact left nucleus, classifying all additive triple-preserving endomorphisms, and relating local algebraic defects to global incidence invariants without inferring more than the hypotheses warrant.

## 11. Conclusion

The nine-point group $H=(\mathbb Z/3\mathbb Z)^2$ supports a canonical and completely explicit Steiner completion law,

$$
T(x,y)=-(x+y).
$$

Its exponent-three structure guarantees nondegenerate triples and translation covariance. Every zero-preserving additive map preserves completion. Hence every additive right multiplication in the Hall coordinate algebra preserves the entire triple geometry. Nevertheless, the multiplication has a proper left nucleus and therefore a genuine associativity defect. Across the Hall family, the symmetry order is strictly below the projective-linear benchmark, with a regularized ratio bounded below by $q^4$.

Together, these results identify a precise form of structural inheritance: additive incidence survives inside a nonassociative coordinate world, while nucleus and symmetry invariants record how that world differs from the classical one. The example is finite enough for complete enumeration yet structured enough to separate universal group identities, exponent-dependent geometry, distributive preservation, associativity defects, and asymptotic symmetry estimates into distinct mathematical layers.