# Projective Completion from Planar Ternary Coordinates: Incidence, Enumeration, and the Algebraic Obstruction of Nonassociativity

**Aristotle**  
**July 26, 2026**

## Abstract

We isolate the minimal unique-solvability assumptions needed to construct a projective incidence structure from coordinates. A planar ternary coordinate system consists of a set $A$ and an operation $T:A^3\to A$ satisfying three axioms: unique solution for the intercept in $T(x,m,b)=y$; unique slope-intercept pair through two affine points with distinct first coordinates; and unique affine intersection for two ordinary lines of distinct slopes. From these data we construct affine points, ideal points, ordinary lines, vertical lines, and a line at infinity. We prove that every two distinct points determine a unique line and every two distinct lines meet in a unique point. If $A$ has cardinality $q$, both the point set and the line set have cardinality $q^2+q+1$. No associativity or distributivity hypothesis is used. We also characterize associativity of an arbitrary binary multiplication by its left nucleus: the nucleus is the entire carrier exactly when multiplication is associative, and it is proper exactly when an explicit nonassociative triple exists. The results give the incidence-theoretic foundation for coordinatizing nonclassical projective planes while sharply separating what follows from solvability alone from the additional work required to establish failure of Desargues' theorem, construct Hall planes, classify planes, or compute collineation groups.

## 1. Introduction

Projective geometry completes affine geometry by adjoining a point for every direction and a line containing all such points. Over a field $F$, an affine line of finite slope has the equation

$$
y=xm+b,
$$

vertical lines have equations $x=a$, and parallel lines meet at the ideal point corresponding to their direction. The standard construction may appear to depend on the full algebra of $F$. In fact, its fundamental incidence properties use much less.

The crucial operations in the coordinate proof are solution operations. One must solve uniquely for an intercept through an affine point at a prescribed slope; solve uniquely for slope and intercept through two points whose first coordinates differ; and solve uniquely for the intersection of two lines whose slopes differ. These requirements can be stated for a single ternary operation $T(x,m,b)$, without splitting $T$ into multiplication and addition. They require neither associativity nor distributivity.

This paper gives a self-contained development of that observation. Section 2 defines planar ternary coordinates. Section 3 defines their projective completion. Sections 4 and 5 prove the unique joining-line and unique-intersection theorems by exhaustive geometric cases. Section 6 obtains the projective incidence theorem. Section 7 counts the points and lines in the finite case. Section 8 studies the left nucleus of a binary multiplication and shows that properness of the nucleus is exactly the existence of an associativity defect. Sections 9 and 10 present computational algorithms and examples. Sections 11 and 12 discuss applications and the exact mathematical boundary of the results.

A motivating theme is non-Desarguesian geometry, but precision is important. The statement that non-Desarguesian planes exist at every prime-power order is false: the projective plane of order $2$, for example, is unique and Desarguesian. The theorems established here do not make that claim. They prove the general incidence mechanism through which a suitable nonassociative coordinate system can generate a projective plane. To conclude that a particular plane is non-Desarguesian requires a concrete coordinate algebra and a separate theorem connecting Desargues configurations to the relevant algebraic laws.

## 2. Planar ternary coordinate systems

### Definition 2.1 (Planar ternary coordinate system)

Let $A$ be a set. A **planar ternary coordinate system** on $A$ is an operation

$$
T:A\times A\times A\to A,
$$

subject to the following three conditions.

1. **Unique intercept.** For every $x,m,y\in A$, there exists exactly one $b\in A$ such that
   $$
   T(x,m,b)=y.
   $$

2. **Unique ordinary line through separated abscissas.** For all $x_1,x_2\in A$ with $x_1\ne x_2$ and all $y_1,y_2\in A$, there exists exactly one pair $(m,b)\in A^2$ such that
   $$
   T(x_1,m,b)=y_1,
   \qquad
   T(x_2,m,b)=y_2.
   $$

3. **Unique affine intersection at distinct slopes.** For all $m_1,m_2\in A$ with $m_1\ne m_2$ and all $b_1,b_2\in A$, there exists exactly one pair $(x,y)\in A^2$ such that
   $$
   y=T(x,m_1,b_1),
   \qquad
   y=T(x,m_2,b_2).
   $$

The variables are named to suggest their geometric roles: $x$ and $y$ are affine coordinates, $m$ is a slope, and $b$ is an intercept.

### Example 2.2 (Field coordinates)

Let $F$ be a field and define $T(x,m,b)=xm+b$. The unique-intercept condition follows by subtraction. If $x_1\ne x_2$, the equations through $(x_1,y_1)$ and $(x_2,y_2)$ have the unique solution

$$
m=(y_2-y_1)(x_2-x_1)^{-1},
\qquad
b=y_1-x_1m.
$$

If $m_1\ne m_2$, the intersection equations have the unique solution

$$
x=(b_2-b_1)(m_1-m_2)^{-1},
\qquad
y=xm_1+b_1.
$$

Thus ordinary affine coordinates are a special case.

### Remark 2.3 (The missing algebra is intentional)

Definition 2.1 contains no constants $0$ or $1$, no addition, no multiplication, and no normalization equations such as $T(0,m,b)=b$. This minimality is useful: it identifies exactly the hypotheses consumed by the incidence arguments. More structured notions, including ternary rings and quasifields in standard normalized presentations, may imply these axioms, but the completion theorem needs only the axioms themselves.

## 3. The projective completion

We now define points, lines, and incidence.

### Definition 3.1 (Points)

The point set $\mathcal P$ is the disjoint union of three classes:

1. affine points $P(x,y)$ for $(x,y)\in A^2$;
2. ideal points $I(m)$ for $m\in A$;
3. one vertical ideal point $I(\infty)$.

Symbolically,

$$
\mathcal P=A^2\sqcup A\sqcup\{I(\infty)\}.
$$

### Definition 3.2 (Lines)

The line set $\mathcal L$ is likewise the disjoint union of three classes:

1. ordinary lines $L(m,b)$ for $(m,b)\in A^2$;
2. vertical lines $V(a)$ for $a\in A$;
3. one line at infinity $L(\infty)$.

Thus

$$
\mathcal L=A^2\sqcup A\sqcup\{L(\infty)\}.
$$

### Definition 3.3 (Incidence)

Incidence is determined by the following rules.

- $P(x,y)$ lies on $L(m,b)$ exactly when $y=T(x,m,b)$.
- $P(x,y)$ lies on $V(a)$ exactly when $x=a$.
- No affine point lies on $L(\infty)$.
- $I(m)$ lies on $L(n,b)$ exactly when $m=n$.
- No finite-slope ideal point lies on a vertical line.
- Every $I(m)$ lies on $L(\infty)$.
- $I(\infty)$ lies on no ordinary line.
- $I(\infty)$ lies on every vertical line and on $L(\infty)$.

These rules capture the idea that ordinary lines with a common slope meet at one ideal point, all vertical lines meet at a distinct ideal point, and all ideal points lie on one horizon.

## 4. Unique lines through pairs of points

### Theorem 4.1 (Unique Joining-Line Theorem)

In the completion of a planar ternary coordinate system, every two distinct points are incident with exactly one common line.

### Proof sketch

Let the distinct points be $P$ and $Q$. We exhaust the possible point types.

**Case 1: two affine points.** Write $P=P(x_1,y_1)$ and $Q=P(x_2,y_2)$. If $x_1=x_2$, both points lie on $V(x_1)$. They cannot lie together on an ordinary line: the unique-intercept axiom, applied at the common $x$ and slope, would force $y_1=y_2$, contradicting distinctness. No affine point lies at infinity, and a second vertical line cannot contain either point. Hence $V(x_1)$ is unique.

If $x_1\ne x_2$, the second axiom supplies a unique pair $(m,b)$ satisfying

$$
T(x_1,m,b)=y_1,
\qquad
T(x_2,m,b)=y_2.
$$

Thus $L(m,b)$ contains both points. A vertical line cannot contain both because their first coordinates differ, and the line at infinity contains neither. Uniqueness of $(m,b)$ gives uniqueness of the ordinary line.

**Case 2: one affine point and one finite-slope ideal point.** Let the points be $P(x,y)$ and $I(m)$. Any ordinary line through $I(m)$ must have slope $m$. By the unique-intercept axiom, there is exactly one $b$ such that $T(x,m,b)=y$. Therefore $L(m,b)$ is the unique common line. Vertical lines contain no $I(m)$, and the line at infinity contains no affine point.

**Case 3: one affine point and the vertical ideal point.** The unique common line through $P(x,y)$ and $I(\infty)$ is $V(x)$. Ordinary lines do not contain $I(\infty)$, and the line at infinity does not contain affine points.

**Case 4: two ideal points.** Two distinct finite-slope ideal points cannot share an ordinary line because an ordinary line has only the ideal point matching its single slope. Neither lies on a vertical line. Hence their unique common line is $L(\infty)$. The same conclusion holds for $I(m)$ and $I(\infty)$: the former is on no vertical line and the latter is on no ordinary line, while both lie on $L(\infty)$.

These cases cover every pair of distinct points and prove existence and uniqueness. $\square$

## 5. Unique intersections of pairs of lines

### Theorem 5.1 (Unique Intersection Theorem)

In the completion of a planar ternary coordinate system, every two distinct lines are incident with exactly one common point.

### Proof sketch

Let the distinct lines be $L$ and $K$.

**Case 1: ordinary lines with distinct slopes.** Suppose

$$
L=L(m_1,b_1),\qquad K=L(m_2,b_2),\qquad m_1\ne m_2.
$$

The third solvability axiom gives a unique $(x,y)$ such that

$$
y=T(x,m_1,b_1)=T(x,m_2,b_2).
$$

Thus $P(x,y)$ is their unique affine intersection. No finite ideal point can lie on both, since that would force $m_1=m_2$, and $I(\infty)$ lies on neither.

**Case 2: distinct ordinary lines with equal slope.** Let $L=L(m,b)$ and $K=L(m,c)$ with $b\ne c$. Both contain $I(m)$. They have no common affine point: if $P(x,y)$ lay on both, then

$$
T(x,m,b)=y=T(x,m,c),
$$

and the unique-intercept axiom would imply $b=c$. The only ideal point on either ordinary line is $I(m)$, so it is the unique intersection.

**Case 3: an ordinary and a vertical line.** The lines $L(m,b)$ and $V(a)$ meet at

$$
P\bigl(a,T(a,m,b)\bigr).
$$

Any common affine point must have first coordinate $a$, and its second coordinate is then forced to be $T(a,m,b)$. Their ideal points differ: $L(m,b)$ contains $I(m)$ whereas $V(a)$ contains $I(\infty)$. Therefore the displayed point is unique.

**Case 4: two distinct vertical lines.** The lines $V(a)$ and $V(c)$ with $a\ne c$ share $I(\infty)$. No affine point can have first coordinate both $a$ and $c$, and finite-slope ideal points lie on no vertical line. Hence the intersection is unique.

**Case 5: a line and the line at infinity.** The ordinary line $L(m,b)$ meets $L(\infty)$ exactly at $I(m)$. A vertical line $V(a)$ meets $L(\infty)$ exactly at $I(\infty)$. These conclusions follow directly from the incidence rules.

Every pair of distinct lines belongs to one of these cases. $\square$

## 6. The completion theorem

### Definition 6.1 (Projective unique incidence)

An incidence structure $(\mathcal P,\mathcal L,\mathrel{\mathrm I})$ has **projective unique incidence** if:

1. every two distinct points lie on exactly one common line; and
2. every two distinct lines meet in exactly one common point.

### Theorem 6.2 (Projective Completion Theorem)

Every planar ternary coordinate system has a canonical completion with projective unique incidence.

### Proof sketch

Construct $\mathcal P$, $\mathcal L$, and incidence according to Definitions 3.1–3.3. The first clause of projective unique incidence is Theorem 4.1, and the second is Theorem 5.1. No additional algebraic laws are required. $\square$

### Remark 6.3 (Nondegeneracy)

Some definitions of “projective plane” supplement the two unique-incidence axioms with a nondegeneracy axiom, commonly the existence of four points no three of which are collinear. Theorem 6.2 states precisely the two properties established uniformly by the three solvability assumptions. For coordinate sets of appropriate size, nondegeneracy can be added by an explicit configuration. The distinction matters for very small or degenerate carriers.

## 7. Finite enumeration

Assume henceforth that $A$ is finite and write $q=|A|$.

### Theorem 7.1 (Point Count)

The projective completion contains exactly $q^2+q+1$ points.

### Proof sketch

The three point classes are disjoint. There are $q^2$ affine pairs, $q$ finite-slope ideal points, and one vertical ideal point. Addition gives

$$
|\mathcal P|=q^2+q+1.
$$

$\square$

### Theorem 7.2 (Line Count)

The projective completion contains exactly $q^2+q+1$ lines.

### Proof sketch

There are $q^2$ ordinary slope-intercept pairs, $q$ vertical lines, and one line at infinity. Since these classes are disjoint,

$$
|\mathcal L|=q^2+q+1.
$$

$\square$

### Corollary 7.3 (Point-line cardinality balance)

Every finite completion constructed above has equally many points and lines.

This equality comes from the parallel disjoint-union descriptions; it does not require an appeal to incidence-matrix rank or a duality theorem.

## 8. The left nucleus and nonassociativity

We now consider an arbitrary set $Q$ equipped with a binary operation $*:Q\times Q\to Q$. No closure issue arises because the operation is defined on all pairs.

### Definition 8.1 (Left nucleus)

The **left nucleus** of $*$ is

$$
N_\ell(*)=\left\{a\in Q:\ a*(b*c)=(a*b)*c\text{ for every }b,c\in Q\right\}.
$$

It records exactly those elements that associate whenever they occupy the leftmost position.

### Theorem 8.2 (Left-Nucleus Characterization of Associativity)

The equality $N_\ell(*)=Q$ holds if and only if $*$ is associative on all triples; that is,

$$
N_\ell(*)=Q
\quad\Longleftrightarrow\quad
\forall a,b,c\in Q,\ a*(b*c)=(a*b)*c.
$$

### Proof sketch

If $N_\ell(*)=Q$, then every $a\in Q$ belongs to the left nucleus. The defining property of membership gives associativity for that $a$ and arbitrary $b,c$. Since $a$ was arbitrary, associativity is universal.

Conversely, assume universal associativity. For any $a$, the equality $a*(b*c)=(a*b)*c$ holds for every $b,c$, so $a\in N_\ell(*)$. Thus every element lies in the nucleus. $\square$

### Theorem 8.3 (Proper-Nucleus Witness Theorem)

The left nucleus is a proper subset of $Q$ if and only if there exist $a,b,c\in Q$ for which associativity fails:

$$
N_\ell(*)\ne Q
\quad\Longleftrightarrow\quad
\exists a,b,c\in Q,\ a*(b*c)\ne(a*b)*c.
$$

### Proof sketch

Negate both sides of Theorem 8.2. The negation of universal equality over triples is the existence of a triple witnessing inequality. Equivalently, if the nucleus is proper, choose $a\notin N_\ell(*)$; by the definition of nonmembership there are $b,c$ witnessing failure. Conversely, any failing triple shows that its leftmost entry is absent from the nucleus. $\square$

### Geometric interpretation

When a coordinate system is presented as $T(x,m,b)=x*m+b$, a proper left nucleus proves that the multiplication is not associative. This is a concrete algebraic obstruction to treating the coordinates as a field with that multiplication. However, Theorem 8.3 alone does not prove failure of Desargues' theorem in the associated incidence plane. Such a conclusion requires hypotheses ensuring that the geometric configuration translates to associativity of the chosen coordinate multiplication. That bridge is an additional theorem, sensitive to the coordinatization framework.

## 9. Algorithms

The finite setting permits direct construction and auditing.

### Algorithm 9.1 (Projective completion enumeration)

**Input:** a finite set $A$ of size $q$ and a table for $T(x,m,b)$.

**Output:** complete lists of $q^2+q+1$ points, $q^2+q+1$ lines, and the incidence relation.

1. List all affine points $(x,y)$, all ideal points $I(m)$, and $I(\infty)$.
2. List all ordinary lines $L(m,b)$, all vertical lines $V(a)$, and $L(\infty)$.
3. For each point-line pair, apply Definition 3.3.

There are $N=q^2+q+1$ points and lines, so explicit incidence-matrix construction takes $O(N^2)=O(q^4)$ evaluations and $O(N^2)$ space if the full matrix is stored.

### Algorithm 9.2 (Unique-incidence audit)

For every unordered pair of distinct points, count common incident lines and require the count to be one. Then, for every unordered pair of distinct lines, count common incident points and require the count to be one. A naive matrix-based implementation takes $O(N^3)=O(q^6)$ time: there are $O(N^2)$ pairs and $N$ possible common objects. Structure-aware formulas reduce the work substantially, but the naive audit is transparent and suitable for small examples.

### Algorithm 9.3 (Left-nucleus computation)

For each $a\in Q$, inspect every ordered pair $(b,c)\in Q^2$. Include $a$ in $N_\ell(*)$ exactly when all equalities

$$
a*(b*c)=(a*b)*c
$$

hold. This takes $O(|Q|^3)$ operation-table lookups and $O(|Q|)$ output space. The first inequality encountered supplies a nonassociativity witness.

## 10. Numerical example over a finite field

Let $A=\mathbb Z/q\mathbb Z$ for a prime $q$, and define

$$
T(x,m,b)=xm+b\pmod q.
$$

Field arithmetic gives all three unique-solvability laws. For $q=3$, the completion has

$$
3^2+3+1=13
$$

points and $13$ lines. Consider the affine points $P(0,1)$ and $P(2,2)$. The slope is

$$
m=(2-1)(2-0)^{-1}=1\cdot2=2\pmod3,
$$

and the intercept is $b=1$. Their joining line is therefore

$$
y=2x+1\pmod3.
$$

Now intersect $y=2x+1$ with $y=x+2$. Solving gives $x=1$ and $y=0$, so their unique intersection is $P(1,0)$. The two parallel lines $y=2x+1$ and $y=2x$ do not meet affinely; both meet at the ideal point $I(2)$. Vertical lines $x=0$ and $x=2$ meet at $I(\infty)$.

For $q=2$, the construction yields $7$ points and $7$ lines, the classical plane of order $2$. This example also exposes why no theorem can assert a non-Desarguesian plane at every prime-power order.

## 11. Applications and scope

### 11.1 Incidence geometry from weak algebra

The completion theorem separates geometric solvability from conventional algebraic syntax. Any quasifield, ternary ring, or tabulated operation that verifies Definition 2.1 enters the same construction. This is particularly relevant in finite geometry, where nonclassical planes are often coordinatized by algebraic systems weaker than fields.

### 11.2 Incidence matrices and finite designs

The construction yields a square incidence matrix with $q^2+q+1$ rows and columns. Rows correspond to points and columns to lines. Theorems 4.1 and 5.1 state that distinct rows have exactly one simultaneous $1$ and distinct columns have exactly one simultaneous $1$, provided the full projective-plane regularity is represented. Such matrices connect projective geometry with block designs, coding theory, and finite combinatorics. The present theorems establish the pairwise uniqueness properties; additional uniform line-size calculations depend on further cardinality arguments for the solution sets.

### 11.3 Testing candidate coordinate tables

For a proposed finite ternary table, the three axioms can be audited directly. Failure has an interpretable certificate: either an intercept equation has zero or multiple solutions, two separated affine points fail to select one slope-intercept pair, or two distinct slopes fail to select one affine intersection. Success permits the projective completion without any need to infer hidden ring laws.

### 11.4 Diagnosing algebraic defects

The left-nucleus algorithm turns nonassociativity into a finite search. A proper nucleus is accompanied by an explicit triple $(a,b,c)$. This is useful when studying candidate quasifield multiplication tables, but it is only one stage in a geometric argument. One must still prove the ternary solvability axioms and the relevant Desargues-associativity correspondence.

## 12. Boundaries, corrections, and future work

The results support a coordinatization mechanism, not a universal classification. Several tempting extensions require separate proofs.

First, non-Desarguesian projective planes do not exist at every prime-power order. Small-order uniqueness results provide immediate counterexamples to that claim. A valid existence theorem must specify the admissible orders and a concrete family.

Second, no collineation-group comparison follows from incidence completion alone. A collineation is an incidence-preserving permutation of points together with its induced action on lines. To compare a plane's collineation group with a projective linear group, one needs an explicit plane, a group action, and an isomorphism or cardinality theorem. The number $q^2+q+1$ counts points and lines, not automorphisms.

Third, nonassociativity does not by itself identify a failed Desargues configuration in this general setting. The next structural target is to enrich the coordinate system with normalization laws, derive a presentation $T(x,m,b)=x*m+b$, define the geometric Desargues configuration, and prove under suitable translation-plane hypotheses that Desargues' theorem forces associativity of the coordinate multiplication.

Fourth, a concrete Hall quasifield example requires more than a nonassociative multiplication table. All division and unique-solvability properties must be proved. Only then can its projective completion be asserted to satisfy the incidence axioms. Hall triple systems should be treated separately from Hall quasifields unless an explicit construction relates them; a shared name is not a mathematical bridge.

Promising future directions are therefore:

1. add standard normalization laws and derive affine quasifield coordinates;
2. instantiate the construction with a finite Hall quasifield and prove every solution axiom;
3. formulate Desargues configurations and establish the algebra-geometry bridge;
4. define and compute collineation groups for explicit examples;
5. construct finite incidence matrices and verify their row and column intersection properties;
6. investigate a precise relation, if any, with Hall triple systems; and
7. develop isotopy and isomorphism invariants needed for classification.

## 13. Conclusion

Three unique-solvability principles are sufficient to perform the essential projective completion of affine coordinates. They produce exactly one line through every pair of distinct points and exactly one point on every pair of distinct lines, with no associativity or distributivity assumption. For a finite coordinate set of size $q$, both sides of the incidence relation have size $q^2+q+1$.

The left nucleus supplies a complementary algebraic statement: it fills the carrier exactly when multiplication is associative, and its properness is exactly equivalent to an explicit associativity failure. Together, these results clarify how weak coordinate algebra can support strong geometric incidence while also identifying the additional work required to pass from abstract completion to genuinely non-Desarguesian examples, automorphism-group calculations, and classification.
