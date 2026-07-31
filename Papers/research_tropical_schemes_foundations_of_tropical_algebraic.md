# Tropical Schemes from Bend Equations: Corner Loci and Semiring-Valued Gluing

**Aristotle**  
**July 31, 2026**

## Abstract

We present a self-contained foundational model of tropical hypersurfaces as semiring schemes. A tropical polynomial is represented by a family of ordered term-value functions. Its classical corner locus consists of points where at least two distinct terms attain the minimum. Its scheme-theoretic support is defined instead by simultaneous bend equations: for each term, deleting that term must leave another term with no larger value. We prove the Corner–Bend Theorem: whenever a minimum exists, the corner condition is equivalent to satisfaction of all bend equations. Consequently, when minima exist pointwise—as they do for finite min-plus tropical polynomials—the bend vanishing set equals the classical corner locus.

We also develop the local-to-global structure needed for a scheme interpretation. For a commutative semiring $K$ and a topological space $X$, the assignment sending $U\subseteq X$ to all functions $U\to K$ is a presheaf of commutative semirings. We prove its full existence-and-uniqueness gluing property for arbitrary indexed covers. A semiring scheme over $K$ is then a topological space equipped with such a sheaf and a map from scalars to global sections. The principal tropical scheme of a term family is the bend vanishing set with its canonical function sheaf. Its points are exactly the polynomial’s corners, and its structure sheaf satisfies arbitrary-cover gluing. This gives a direct bridge between the polyhedral and Grothendieck-style descriptions of tropical geometry without requiring additive inverses.

## 1. Introduction

Tropical algebra replaces ordinary addition by an order operation. In the min-plus convention,

$$
a\oplus b=\min(a,b),\qquad a\odot b=a+b.
$$

With $\infty$ adjoined, these operations form a commutative semiring. Tropical polynomials are therefore minima of finitely many affine-linear functions. Their hypersurfaces are usually drawn as corner loci: the points where the minimum is attained by at least two terms. This description makes the polyhedral character of tropical geometry immediate.

A scheme-theoretic approach requires a complementary language. Ordinary algebraic geometry builds vanishing loci from equations in rings and equips spaces with sheaves of rings. Tropical semirings usually lack additive inverses, so one cannot systematically rewrite an equality $p=q$ as $p-q=0$. Tropical equations are instead naturally expressed by congruences or by **bend relations**, which compare a polynomial with expressions obtained by deleting individual terms.

The purpose of this paper is to isolate and prove the foundational connector underlying that perspective. The argument applies more generally than tropical polynomials. Let $f_i:X\to A$ be an indexed family of functions into a partially ordered set. We compare two predicates at $x\in X$:

1. two distinct indices minimize the family at $x$;
2. for every index $i$, some different index $j$ has $f_j(x)\le f_i(x)$.

Assuming a minimum exists, these predicates are equivalent. The forward implication uses either one of two fixed minimizers as a replacement for any deleted term. The reverse implication applies the deletion condition to a chosen minimizer and thereby obtains a second minimizer.

To place the resulting support in a geometric framework, we define semiring-valued presheaves and their sheaf axiom, then establish arbitrary-cover gluing for the canonical presheaf of all functions. This gives a simple but complete semiring-scheme model. It is intentionally foundational: it captures the topological space, semiring-valued local sections, restriction, constants, and gluing, while leaving localization, stalk locality, and congruence spectra to subsequent development.

The main contributions are:

- an order-theoretic formulation of minima, corners, bend equations, and bend support;
- a pointwise Corner–Bend Theorem under the minimal hypothesis that a minimum exists;
- equality of the bend support and corner locus under pointwise existence of minima;
- an arbitrary-cover gluing theorem for semiring-valued function sections;
- a principal tropical scheme whose points are precisely the classical tropical hypersurface and whose structure sheaf is a sheaf;
- an exact calculation showing that the two-term polynomial $\min\{0,x\}$ selects only $x=0$.

## 2. Algebraic and order-theoretic preliminaries

### 2.1. Commutative semirings and the tropical base

A **commutative semiring** is a set $K$ equipped with commutative addition and multiplication, identities $0_K$ and $1_K$, and distributivity of multiplication over addition. Unlike a ring, a semiring does not require additive inverses.

The **min-plus tropical semiring** is

$$
\mathbb T=\mathbb R\cup\{\infty\}
$$

with

$$
a\oplus b=\min(a,b),\qquad a\odot b=a+b,
$$

extended by $\min(a,\infty)=a$ and $a+\infty=\infty$. Its additive identity is $\infty$, its multiplicative identity is $0$, and tropical addition is idempotent:

$$
a\oplus a=a.
$$

A min-plus tropical monomial in $n$ variables has the affine-linear form

$$
c+u_1x_1+\cdots+u_nx_n,
$$

and a finite tropical polynomial is the pointwise minimum of finitely many such terms. The connector theorem below uses only their order-valued term functions, so it is independent of polynomial syntax and dimension.

### 2.2. Minimal terms and corners

Let $X$ be a set, $I$ an index set, $A$ a preordered set, and

$$
f:I\to (X\to A)
$$

an indexed family. We write $f_i(x)$ for $f(i)(x)$.

**Definition 2.1 (Minimal term).** An index $i\in I$ is minimal for $f$ at $x\in X$ if

$$
\forall k\in I,\qquad f_i(x)\le f_k(x).
$$

This means that $f_i(x)$ is a least value, not merely a minimal element among incomparable values.

**Definition 2.2 (Corner).** The point $x\in X$ is a corner of $f$ if there exist distinct indices $i,j\in I$ such that both are minimal at $x$. Equivalently,

$$
\exists i,j\in I,
\quad i\ne j,
\quad (\forall k,\ f_i(x)\le f_k(x)),
\quad (\forall k,\ f_j(x)\le f_k(x)).
$$

The **corner locus** is the subset

$$
C(f)=\{x\in X:x\text{ is a corner of }f\}.
$$

For a finite family valued in a linear order, a minimum exists at every point. The distinction between “two minimal terms” and “two equal terms” is important: two nonminimal terms may tie without producing a tropical corner.

## 3. Bend equations and bend support

### 3.1. Term deletion

Fix $i\in I$. In a finite min-plus expression

$$
F(x)=\bigoplus_{k\in I}f_k(x)=\min_{k\in I}f_k(x),
$$

deleting term $i$ yields

$$
F_{\widehat{i}}(x)=\min_{k\ne i}f_k(x).
$$

If $i$ is not uniquely responsible for the minimum, deletion does not alter the value. This motivates an order-theoretic condition that does not require writing a finite minimum explicitly.

**Definition 3.1 (Bend equation).** The bend equation associated with term $i$ holds at $x$ if

$$
\exists j\in I,
\qquad j\ne i,
\qquad f_j(x)\le f_i(x).
$$

When $i$ is minimal, the inequality forces $j$ to share its least value. When $i$ is not minimal, any minimizer witnesses the condition.

**Definition 3.2 (Bend vanishing set).** The simultaneous bend support of $f$ is

$$
V_{\mathrm{bend}}(f)=
\left\{x\in X:\forall i\in I,\ \exists j\ne i,
\ f_j(x)\le f_i(x)\right\}.
$$

This support plays the role of the common zero set of all term-deletion equations. It is meaningful for arbitrary index sets and preorders.

### 3.2. The Corner–Bend Theorem

**Theorem 3.3 (Corner–Bend Theorem).** Let $A$ be a partially ordered set, let $f_i:X\to A$ be an indexed family, and fix $x\in X$. Suppose at least one term is minimal at $x$. Then the following are equivalent:

1. $x$ is a corner: two distinct terms are minimal at $x$;
2. every bend equation holds at $x$: for every $i\in I$, there is $j\ne i$ with $f_j(x)\le f_i(x)$.

**Proof sketch.** Suppose $a$ and $b$ are distinct minimizers. To verify the bend equation for an arbitrary $i$, split into two cases. If $i=a$, choose $j=b$; minimality of $b$ gives $f_b(x)\le f_a(x)$. If $i\ne a$, choose $j=a$; minimality of $a$ gives $f_a(x)\le f_i(x)$. Thus every bend equation holds.

Conversely, choose a minimal index $i$, possible by hypothesis. Apply the bend equation for $i$ to obtain $j\ne i$ and $f_j(x)\le f_i(x)$. Since $i$ is minimal, $f_i(x)\le f_j(x)$. For any $k$, transitivity gives

$$
f_j(x)\le f_i(x)\le f_k(x).
$$

Thus $j$ is also minimal, and $i$ and $j$ are distinct minimizers. This proves the equivalence. $\square$

The proof reveals why the existence hypothesis is necessary. If $I$ has no least-valued term at $x$, it may happen that every term has a strictly smaller competitor, so all bend equations hold without any corner. For example, take $I=\mathbb Z$, a one-point space $X=\{x\}$, and $f_i(x)=i$. Every $i$ has the smaller competitor $i-1$, but there is no minimum. Finite tropical polynomials avoid this pathology.

**Corollary 3.4 (Equality of supports).** Let $A$ be partially ordered and assume that for every $x\in X$, at least one term is minimal. Then

$$
V_{\mathrm{bend}}(f)=C(f).
$$

**Proof sketch.** Apply Theorem 3.3 independently at each point $x$. Membership in the left side is exactly condition 2, while membership in the right side is condition 1. $\square$

**Corollary 3.5 (Finite tropical polynomial case).** For a tropical polynomial with a nonempty finite set of terms valued in a linearly ordered tropical semiring, the simultaneous bend support is exactly its classical corner locus.

**Proof sketch.** A nonempty finite family in a linear order has a least member at every point. Corollary 3.4 therefore applies. $\square$

## 4. Semiring-valued presheaves and sheaves

### 4.1. Presheaf data

Let $X$ be a topological space. A **presheaf of commutative semirings** $\mathcal O$ assigns:

- to every open set $U\subseteq X$, a commutative semiring $\mathcal O(U)$ of sections;
- to every inclusion $V\subseteq U$, a semiring homomorphism

$$
\rho_{U,V}:\mathcal O(U)\to\mathcal O(V),
$$

called restriction.

These maps satisfy identity and composition laws:

$$
\rho_{U,U}=\operatorname{id}_{\mathcal O(U)},
$$

and, whenever $W\subseteq V\subseteq U$,

$$
\rho_{U,W}=\rho_{V,W}\circ\rho_{U,V}.
$$

The algebraic operations on sections are therefore compatible with passing to smaller regions.

### 4.2. Arbitrary-cover sheaf axiom

A presheaf is a **sheaf** if compatible local sections glue uniquely. Explicitly, let $(V_i)_{i\in J}$ be any indexed open cover of $U$:

$$
U=\bigcup_{i\in J}V_i.
$$

Suppose $s_i\in\mathcal O(V_i)$ and the sections agree on every overlap:

$$
\rho_{V_i,V_i\cap V_j}(s_i)
=
\rho_{V_j,V_i\cap V_j}(s_j)
\qquad\text{for all }i,j\in J.
$$

The sheaf axiom asserts that there exists a unique $s\in\mathcal O(U)$ with

$$
\rho_{U,V_i}(s)=s_i
\qquad\text{for every }i\in J.
$$

No finiteness assumption on the cover is imposed.

### 4.3. The canonical function sheaf

Let $K$ be a commutative semiring. For each open set $U\subseteq X$, define

$$
\mathcal F_K(U)=K^U=\{s:U\to K\}.
$$

Addition, multiplication, zero, and one are pointwise:

$$
(s+t)(x)=s(x)+t(x),\qquad
(st)(x)=s(x)t(x),
$$

$$
0(x)=0_K,
\qquad
1(x)=1_K.
$$

For $V\subseteq U$, define restriction by ordinary function restriction,

$$
\rho_{U,V}(s)=s|_V.
$$

These maps preserve all semiring operations and satisfy the presheaf laws.

**Theorem 4.1 (Function-Sheaf Gluing Theorem).** For every commutative semiring $K$ and topological space $X$, the presheaf $\mathcal F_K$ of all $K$-valued functions is a sheaf. More precisely, compatible sections over an arbitrary indexed cover have a unique global gluing.

**Proof sketch.** Let $U=\bigcup_iV_i$ and let $s_i:V_i\to K$ agree on pairwise overlaps. For each $x\in U$, choose an index $i(x)$ such that $x\in V_{i(x)}$ and set

$$
s(x)=s_{i(x)}(x).
$$

If another covering index $j$ also contains $x$, then $x\in V_{i(x)}\cap V_j$, and compatibility gives

$$
s_{i(x)}(x)=s_j(x).
$$

Thus the resulting value is independent of the choice in the only sense needed: the restriction of $s$ to each $V_j$ equals $s_j$. This proves existence.

For uniqueness, suppose $u:U\to K$ has the same restrictions. Given $x\in U$, choose $i$ with $x\in V_i$. Then

$$
u(x)=s_i(x)=s(x).
$$

Hence $u=s$ pointwise. $\square$

The proof uses no topology beyond the notion of a cover and no algebra beyond the pointwise codomain. It therefore applies uniformly to tropical, Boolean, arithmetic, and other commutative semirings.

## 5. Semiring schemes and principal tropical schemes

### 5.1. A foundational semiring-scheme model

**Definition 5.1 (Semiring scheme over a base).** Let $K$ be a commutative semiring. A semiring scheme over $K$ consists of:

1. a topological space $Y$;
2. a sheaf $\mathcal O_Y$ of commutative semirings on $Y$;
3. a semiring homomorphism

$$
\eta:K\to\mathcal O_Y(Y)
$$

from base scalars to global sections.

The canonical example on any topological space $Y$ uses $\mathcal O_Y(U)=K^U$ and sends $k\in K$ to the constant global function $y\mapsto k$. Theorem 4.1 supplies the sheaf property.

This definition captures the semiring analogue of the space-and-structure-sheaf layer of scheme theory. It does not assert that $Y$ is locally a spectrum, nor that stalks are local semirings. Those refinements require a developed theory of semiring congruence spectra and localization.

**Definition 5.2 (Tropical scheme).** A tropical scheme is a semiring scheme over the min-plus tropical semiring $\mathbb T$.

### 5.2. Principal construction from a term family

Let $X$ be topological, let $A$ be preordered, and let $f_i:X\to A$ be an indexed term family. Give the subset

$$
Y=V_{\mathrm{bend}}(f)\subseteq X
$$

the subspace topology.

**Definition 5.3 (Principal tropical scheme of a term family).** The principal scheme associated with $f$ has point space $Y$, structure sheaf

$$
\mathcal O_Y(U)=\{s:U\to\mathbb T\},
$$

and scalar map sending $c\in\mathbb T$ to the constant function with value $c$.

The same construction works over any commutative semiring $K$ if one wants $K$-valued sections. For tropical geometry, $K=\mathbb T$ is the natural base.

**Theorem 5.4 (Principal Tropical Scheme Theorem).** Suppose $A$ is partially ordered and the family $f$ has a minimal term at every $x\in X$. Then:

1. the underlying point set of the principal tropical scheme is exactly the corner locus $C(f)$;
2. its structure presheaf is a sheaf of commutative semirings satisfying existence and uniqueness of gluing for arbitrary indexed covers;
3. tropical scalars define global constant sections by a semiring homomorphism.

**Proof sketch.** By definition, the point set is $V_{\mathrm{bend}}(f)$. Corollary 3.4 identifies it with $C(f)$. The structure sheaf is the canonical function sheaf, so Theorem 4.1 proves the arbitrary-cover gluing property. Pointwise operations make constant functions compatible with addition, multiplication, zero, and one, yielding the required semiring homomorphism. $\square$

The theorem separates two logically independent ingredients. The Corner–Bend Theorem identifies the correct support. The Function-Sheaf Gluing Theorem supplies local-to-global geometry on that support.

## 6. Algorithms and computational interpretation

Assume a finite family of $m$ real-valued terms is evaluated at a point $x$. Let

$$
v_i=f_i(x),\qquad i=1,\dots,m.
$$

A direct corner test computes the least value

$$
v_{\min}=\min_i v_i
$$

and counts how many indices achieve it. The point is a corner exactly when this multiplicity is at least two. This takes $O(m)$ time and $O(1)$ auxiliary space if the values are streamed.

A literal all-bends test asks, for each $i$, whether there is $j\ne i$ with $v_j\le v_i$. A naive nested loop costs $O(m^2)$. The connector theorem provides an optimized interpretation: once a minimum is known to exist, all bends hold exactly when the minimum has multiplicity at least two. Thus the complete bend system can also be tested in $O(m)$ time.

For visualization over a grid of $N$ sample points, evaluating all $m$ affine terms costs $O(Nm)$. Each point can be labeled by its set of minimizers. Points with at least two minimizers approximate the tropical hypersurface. Numerical implementations should use a tolerance $\varepsilon$ and declare $v_i$ minimal when

$$
|v_i-v_{\min}|\le\varepsilon,
$$

because floating-point evaluations of theoretically equal affine forms may differ slightly.

The sheaf-gluing algorithm is equally direct. Given compatible partial maps $s_i:V_i\to K$, traverse each local key-value pair and insert it into a global map. If a key was previously inserted, check equality with the existing value. A conflict witnesses failure of compatibility; otherwise the resulting union is the unique gluing. If the local maps contain $M$ total key-value occurrences, expected running time with hash maps is $O(M)$ and storage is $O(|U|)$.

## 7. Examples

### 7.1. The two-term crossing

Let $X=\mathbb Z$ and define

$$
f_0(x)=0,
\qquad
f_1(x)=x.
$$

The associated tropical polynomial is $F(x)=\min\{0,x\}$. The bend equation for term $0$ requires the only other term to satisfy

$$
x\le0.
$$

The bend equation for term $1$ requires

$$
0\le x.
$$

Therefore

$$
V_{\mathrm{bend}}(f)=\{x\in\mathbb Z:x\le0\text{ and }0\le x\}=\{0\}.
$$

At $x=0$, both terms attain the minimum. If $x<0$, the term $x$ is uniquely minimal; if $x>0$, the constant term is uniquely minimal. Hence the corner locus is also $\{0\}$, exactly as predicted.

### 7.2. The standard tropical line

Consider

$$
F(x,y)=\min\{0,x,y\}
$$

on $\mathbb R^2$. A corner occurs when at least two of the three values share the minimum. There are three cases:

$$
0=x\le y,
$$

$$
0=y\le x,
$$

or

$$
x=y\le0.
$$

Thus the corner locus is the union of three rays meeting at the origin. The three bend equations require, respectively, that one of $x,y$ be at most $0$, one of $0,y$ be at most $x$, and one of $0,x$ be at most $y$. Their simultaneous solution is exactly the same three-rayed set.

### 7.3. Gluing local tropical data

Let $U=\{a,b,c\}$, covered by $V_1=\{a,b\}$ and $V_2=\{b,c\}$. Suppose local sections into a tropical semiring are

$$
s_1(a)=2,\quad s_1(b)=-1,
$$

and

$$
s_2(b)=-1,\quad s_2(c)=4.
$$

They agree on $V_1\cap V_2=\{b\}$. Their unique gluing is

$$
s(a)=2,
\qquad s(b)=-1,
\qquad s(c)=4.
$$

If instead $s_2(b)=3$, no global function could restrict to both local sections. The overlap condition is therefore precisely the obstruction to gluing in this model.

## 8. Applications and conceptual consequences

The corner–bend equivalence converts a visual condition into a deletion-equation condition. This has several consequences.

First, it supplies an equation-based description without subtraction. Tropical semirings are not rings, but term deletion detects whether a minimum is multiply attained. This is the appropriate replacement for a classical zero equation at the level of supports.

Second, it clarifies the role of finite polynomial syntax. The logical theorem requires only pointwise existence of a least term. Finiteness is one sufficient mechanism, not part of the proof itself. The result therefore applies to infinite families whenever minima are known to exist.

Third, it supports local-to-global constructions. Once the bend support is treated as a topological space with a sheaf, local semiring-valued observations can be restricted, compared, and glued. This architecture is relevant whenever tropical objects are assembled from charts or polyhedral pieces.

Fourth, the result suggests efficient algorithms. A quadratic collection of pairwise replacement tests collapses to a linear minimum-multiplicity test. The theorem explains why the optimization is correct rather than merely heuristic.

Finally, the framework identifies exactly what remains before reaching a richer scheme theory. All-functions sections satisfy gluing, but they do not encode tropical regularity. Congruence spectra, localizations, and stalk conditions are needed to distinguish regular functions and to construct affine tropical schemes intrinsically.

## 9. Limitations and future work

The present construction is foundational rather than exhaustive. Its structure sheaf contains all semiring-valued functions, whereas geometric applications generally seek locally representable or localized polynomial functions. The point space is defined directly as a bend support rather than as a spectrum of prime congruences. No local-semiring condition on stalks is imposed. Polynomial terms are represented extensionally as functions, leaving syntax, coefficients, and monomial combinatorics implicit.

These limitations indicate a concrete program:

1. Develop spectra of prime semiring congruences, basic open subsets, localizations, stalks, and locally semiringed spaces.
2. Generate congruences from all term-deletion relations and compare their functor-of-points support with the bend vanishing set.
3. Connect finite term families to a multivariate tropical polynomial syntax, including evaluation, multiplication, and the hypersurface union law.
4. Glue affine congruence spectra along localization isomorphisms and compare the resulting construction with general scheme gluing.
5. Define local idempotent semirings and prove locality of stalks for localized structure sheaves.
6. Construct valued-field tropicalization as a morphism from classical affine schemes to tropical semiring schemes, with compatibility under products and principal hypersurfaces.
7. Equip corner loci with rational polyhedral complexes and prove that bend support recovers their underlying topological spaces.

## 10. Conclusion

A tropical hypersurface has two natural faces. Polyhedrally, it is the locus where a minimum is achieved by at least two terms. Algebraically, it is the common support of all bend equations obtained by deleting one term at a time. Under the exact and minimal assumption that a least term exists, these descriptions coincide.

Equipping the resulting support with semiring-valued functions adds a second foundational result: compatible local sections glue uniquely over arbitrary covers. The principal tropical scheme therefore combines the correct classical point set with a complete local-to-global structure. This establishes a concise bridge from tropical corner geometry to a Grothendieck-style language of spaces, sections, restrictions, constants, and gluing—entirely within the algebra of semirings.