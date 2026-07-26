# Non-Desarguesian Worlds: Building Projective Geometry from Solvable Equations

*By Aristotle — July 26, 2026*

Stand beside a railway track and watch the rails narrow toward the horizon. In Euclidean geometry they remain parallel forever, but perspective painting invites us to imagine that they meet at a point infinitely far away. Projective geometry makes that invitation precise. It adds ideal points, one for each direction, and gathers all those ideal points onto a single line at infinity.

The familiar version of this construction begins with ordinary coordinates and straight lines of the form $y=mx+b$. Yet the essential ingredient is not multiplication, addition, or even the associativity law $(ab)c=a(bc)$. What the geometry really needs is the ability to solve three families of incidence equations uniquely. Once that observation is isolated, a much wider landscape appears: projective planes can be built from ternary operations that need not arise from a field at all.

This article develops that construction from beginning to end. Its main conclusion is exact and deliberately limited: every set equipped with the three unique-solvability laws below has a canonical projective completion in which two distinct points determine exactly one line and two distinct lines meet in exactly one point. If the coordinate set has $q$ elements, the completion has precisely $q^2+q+1$ points and the same number of lines. A separate algebraic criterion identifies nonassociativity through the properness of the left nucleus.

These results explain the mechanism by which nonclassical coordinate algebras can support projective incidence. They do not assert that a non-Desarguesian plane exists at every prime-power order; that broader claim is false, already because the plane of order $2$ is uniquely the classical one. Nor do the results determine a collineation group or construct a particular Hall plane. Their strength lies elsewhere: they expose the minimal engine of projective coordinatization.

## Replacing the line equation

Let $A$ be a nonempty coordinate set, and suppose we have a ternary operation

$$
T:A\times A\times A\longrightarrow A.
$$

Think of $T(x,m,b)$ as the height of the line with slope $m$ and intercept $b$ above the horizontal coordinate $x$. In the classical case, $T(x,m,b)=xm+b$. We assume only three laws.

**Unique intercept law.** For every $x,m,y\in A$, there is exactly one $b\in A$ such that

$$
T(x,m,b)=y.
$$

**Unique line through separated abscissas.** If $x_1\ne x_2$, then for every $y_1,y_2\in A$ there is exactly one pair $(m,b)\in A^2$ satisfying

$$
T(x_1,m,b)=y_1,
\qquad
T(x_2,m,b)=y_2.
$$

**Unique intersection of distinct slopes.** If $m_1\ne m_2$, then for every $b_1,b_2\in A$ there is exactly one pair $(x,y)\in A^2$ satisfying

$$
y=T(x,m_1,b_1),
\qquad
y=T(x,m_2,b_2).
$$

A set with such an operation is called a planar ternary coordinate system. Notice what is absent: there is no declared addition, no declared multiplication, no distributive law, and no associativity assumption. The axioms speak only the language geometry actually uses—drawing a line through points, selecting an intercept, and crossing two lines.

## Three kinds of points, three kinds of lines

The affine points are the expected pairs $(x,y)\in A^2$. To complete the plane, add one ideal point $I_m$ for every slope $m\in A$, plus one special ideal point $I_\infty$ for the vertical direction. Thus the point set consists of

$$
A^2\;\sqcup\;A\;\sqcup\;\{I_\infty\}.
$$

Lines also come in three kinds. An ordinary line $L_{m,b}$ has equation $y=T(x,m,b)$. A vertical line $V_a$ consists of affine points whose first coordinate is $a$. Finally, there is a line at infinity $L_\infty$. The line set is therefore another copy of

$$
A^2\;\sqcup\;A\;\sqcup\;\{L_\infty\}.
$$

Incidence is defined as perspective suggests. An affine point $(x,y)$ lies on $L_{m,b}$ exactly when $y=T(x,m,b)$, and it lies on $V_a$ exactly when $x=a$. The ideal point $I_m$ lies on every ordinary line of slope $m$ and on $L_\infty$. The vertical ideal point $I_\infty$ lies on every vertical line and on $L_\infty$. No affine point lies on the line at infinity.

## Why every pair of points has one joining line

Take two distinct points. The proof breaks naturally into visual cases.

If both are affine, say $(x_1,y_1)$ and $(x_2,y_2)$, then equal first coordinates force the unique joining line to be the vertical line $V_{x_1}$. If $x_1\ne x_2$, the second solvability law produces a unique slope and intercept, hence a unique ordinary line.

If one point is affine and the other is $I_m$, the line must have slope $m$. The unique intercept law chooses the one intercept that makes it pass through the affine point. If the ideal point is $I_\infty$, the joining line is the unique vertical line through the affine point.

Finally, two distinct ideal points lie together only on $L_\infty$. This includes the pairing of a finite-slope ideal point with $I_\infty$.

We have therefore obtained the **Unique Joining-Line Theorem**: *in the projective completion of any planar ternary coordinate system, every two distinct points are incident with exactly one common line.*

## Why every pair of lines has one intersection

The dual-looking statement requires another case analysis.

Two ordinary lines of different slopes meet at the unique affine point supplied by the third solvability law. Two ordinary lines with the same slope but different intercepts cannot meet affinely: if they did, the unique intercept law would force their intercepts to agree. Instead, they meet at their common ideal point $I_m$.

An ordinary line and a vertical line $V_a$ meet at the explicitly determined affine point

$$
\bigl(a,T(a,m,b)\bigr).
$$

Two distinct vertical lines share $I_\infty$. An ordinary line of slope $m$ meets $L_\infty$ at $I_m$, while every vertical line meets $L_\infty$ at $I_\infty$.

This proves the **Unique Intersection Theorem**: *in the same completion, every two distinct lines are incident with exactly one common point.* Together, the two theorems give the characteristic unique-incidence axioms of a projective plane.

A standard definition of a projective plane often also includes a nondegeneracy condition, such as the existence of four points with no three collinear. The construction above establishes the two central uniqueness axioms for every coordinate set satisfying the stated laws. When $A$ has at least two elements, the usual nondegenerate configurations can be selected; the core theorem, however, is intentionally formulated around the incidence properties proved directly from solvability.

## The number $q^2+q+1$

Suppose $A$ is finite with $q$ elements. There are $q^2$ affine points, $q$ finite-slope ideal points, and one vertical ideal point. Consequently,

$$
\#\text{points}=q^2+q+1.
$$

The line count is identical: $q^2$ ordinary lines indexed by $(m,b)$, $q$ vertical lines, and one line at infinity. Hence

$$
\#\text{lines}=q^2+q+1.
$$

This equality is more than attractive arithmetic. It reflects the architectural symmetry of finite projective geometry: points and lines are assembled from parallel coordinate recipes, and the horizon closes both recipes with a final exceptional object.

For $q=2$, the count is $7$; for $q=3$, it is $13$; for $q=5$, it is $31$. In the classical field case, each line also contains $q+1$ points. That further regularity can be checked directly, but the counting theorem here requires only the disjoint descriptions of points and lines.

## Where nonassociativity enters

The ternary construction does not need a binary multiplication, but important examples are written in the suggestive form

$$
T(x,m,b)=x*m+b,
$$

where $*$ may belong to a quasifield or another division-like algebra. Such multiplication can fail to be associative. A precise diagnostic is the **left nucleus**:

$$
N_\ell(*)=\{a:\ a*(b*c)=(a*b)*c\text{ for all }b,c\}.
$$

The **Left-Nucleus Criterion** says that $N_\ell(*)$ is the whole underlying set if and only if $*$ is associative for every triple. The proof is immediate but useful. If the nucleus is everything, each possible left factor $a$ satisfies associativity with all $b,c$. Conversely, universal associativity places every $a$ in the nucleus.

Negating this equivalence yields the **Nonassociativity Witness Theorem**: *the left nucleus is a proper subset if and only if there exist $a,b,c$ such that*

$$
a*(b*c)\ne(a*b)*c.
$$

Thus a global set inequality is exactly equivalent to a concrete three-element witness. In computations, that witness can be found by scanning triples. In geometry, it signals that the coordinate multiplication is not a field multiplication. Turning that signal into a proof that Desargues' theorem fails requires an additional bridge relating a specific coordinate algebra to Desargues configurations; it is not automatic from nonassociativity alone in the general setting presented here.

## What this changes—and what it does not

The conceptual change is profound. A projective plane is often introduced as linear algebra with one extra coordinate. Here it appears instead as a machine powered by uniqueness. The equation $xm+b$ is only one implementation of that machine. Any ternary operation with the same three solving behaviors can drive it.

This viewpoint matters in finite geometry, where exotic planes are often born from weakened algebraic systems. It also suggests practical algorithms. Given a finite table for $T$, one can enumerate all points and lines, build the incidence matrix, test every pair of points for a unique joining line, and test every pair of lines for a unique intersection. Separately, a multiplication table can be searched for associativity failures and its left nucleus computed exactly.

But mathematical restraint is essential. The construction is a general coordinatization theorem, not a classification of all finite projective planes. It neither produces a non-Desarguesian example at every prime-power order nor compares a resulting automorphism group with a projective linear group. Small orders already rule out the universal existence claim. A genuine Hall-plane application would require an explicit finite quasifield, proofs of all three solvability laws for its ternary operation, and a theorem connecting its algebraic defect to a failed Desargues configuration.

The horizon, then, is both geometric and intellectual. By adding ideal points, parallel lines are made to meet. By stripping coordinates down to unique solvability, classical and nonclassical planes enter one framework. The resulting world is not geometry without rules. It is geometry revealing which rules it truly needed all along.
