# Binary Operations as Reversal-Equivariant Transformations

## Abstract

Let $X$ be a set and let $\mathcal O_X$ denote the set of all binary operations on $X$. We study the product

$$
(f\star g)(a,b)=g\bigl(f(a,b),f(b,a)\bigr),
$$

which makes $\mathcal O_X$ a monoid. The central construction associates to each operation $f$ the transformation $P_f:X^2\to X^2$ defined by $P_f(a,b)=(f(a,b),f(b,a))$. This representation is faithful, converts the magma product into composition, and identifies binary operations exactly with transformations commuting with coordinate reversal. We use this viewpoint to characterize idempotents as retractions onto their images, prove a sufficient criterion based on commutativity and pointwise idempotence, and analyze the diagonal geometry of idempotent and regular elements. In particular, if $f$ is idempotent or regular, then every diagonal point in the image of $P_f$ is already the image of a diagonal input. We also describe the two coordinate-selector operations: the left selector is the identity, while the right selector is a central involutive unit that sends every operation to its opposite. Algorithms for finite sets translate these structural statements into direct computations on multiplication tables and functional digraphs.

## 1. Introduction

A binary operation on a set $X$ is a function $f:X\times X\to X$. Ordinarily one fixes such an operation and studies the resulting algebraic structure. Here the objects of study are the operations themselves. The collection $\mathcal O_X$ of all binary operations admits a natural but nonstandard multiplication:

$$
(f\star g)(a,b)=g\bigl(f(a,b),f(b,a)\bigr).
$$

The operation $f$ first processes the ordered pair in both orientations; the operation $g$ then combines the two outputs. This multiplication is sometimes called the magma-monoid product because no associativity or other law is assumed of the individual binary operations, although the induced product on the space of all operations is associative.

Direct table calculations conceal the structure. The product samples $f$ at $(a,b)$ and $(b,a)$ simultaneously, suggesting that the natural state space is not $X$ but $X^2$. The associated pair transformation

$$
P_f(a,b)=\bigl(f(a,b),f(b,a)\bigr)
$$

turns the magma-monoid product into ordinary transformation composition. Moreover, the image consists exactly of transformations compatible with the involution that swaps coordinates. This gives a transformation-semigroup model that is both faithful and intrinsic.

The representation immediately clarifies several semigroup-theoretic properties. Idempotence becomes the familiar condition that a transformation fixes its image. Regularity forces a precise equality between two diagonal subsets. The right coordinate selector becomes coordinate reversal itself, explaining its centrality and order two. Our arguments require no finiteness assumptions unless algorithms are explicitly discussed.

## 2. The magma monoid

### 2.1. Basic definitions

Let $X$ be any set. Write

$$
\mathcal O_X=\{f:X\times X\to X\}.
$$

Elements of $\mathcal O_X$ will be written as two-variable functions. Define a product $\star$ on $\mathcal O_X$ by

$$
(f\star g)(a,b)=g\bigl(f(a,b),f(b,a)\bigr).
$$

Define the **left selector** $\lambda$ and **right selector** $\rho$ by

$$
\lambda(a,b)=a,
\qquad
\rho(a,b)=b.
$$

For an operation $f$, define its **opposite** by

$$
f^{\mathrm{op}}(a,b)=f(b,a).
$$

### Theorem 2.1 (Magma-monoid law)

For all $f,g,h\in\mathcal O_X$,

$$
(f\star g)\star h=f\star(g\star h).
$$

Furthermore, $\lambda$ is a two-sided identity:

$$
\lambda\star f=f=f\star\lambda.
$$

Hence $(\mathcal O_X,\star,\lambda)$ is a monoid.

**Proof sketch.** At $(a,b)$, the left-associated product is

$$
h\left(g(f(a,b),f(b,a)),g(f(b,a),f(a,b))\right).
$$

Expanding the right-associated product gives the same expression. For the identity laws,

$$
(\lambda\star f)(a,b)=f(a,b)
$$

because $\lambda(a,b)=a$ and $\lambda(b,a)=b$, while

$$
(f\star\lambda)(a,b)=\lambda(f(a,b),f(b,a))=f(a,b).
$$

No property of the operations themselves is required. $\square$

## 3. The pair-transformation representation

Let $S:X^2\to X^2$ be coordinate reversal,

$$
S(a,b)=(b,a).
$$

For $f\in\mathcal O_X$, define its **pair transformation** $P_f:X^2\to X^2$ by

$$
P_f(a,b)=\bigl(f(a,b),f(b,a)\bigr).
$$

A transformation $T:X^2\to X^2$ is called **reversal-equivariant** if

$$
T\circ S=S\circ T.
$$

### Theorem 3.1 (Composition law)

For all $f,g\in\mathcal O_X$,

$$
P_{f\star g}=P_g\circ P_f.
$$

**Proof sketch.** For $(a,b)\in X^2$,

$$
P_g(P_f(a,b))
=P_g(f(a,b),f(b,a))
$$

$$
=\left(g(f(a,b),f(b,a)),g(f(b,a),f(a,b))\right),
$$

which is exactly $P_{f\star g}(a,b)$. $\square$

Thus $f\mapsto P_f$ is a homomorphism into the full transformation monoid of $X^2$, with the conventional reversal of written order already accounted for by the definition of $\star$.

### Theorem 3.2 (Pair-Transformation Characterization)

A transformation $T:X^2\to X^2$ equals $P_f$ for some binary operation $f$ if and only if $T$ is reversal-equivariant. The inducing operation is unique.

**Proof sketch.** Every $P_f$ commutes with $S$, since

$$
P_f(S(a,b))=P_f(b,a)=(f(b,a),f(a,b))=S(P_f(a,b)).
$$

Conversely, suppose $T\circ S=S\circ T$. Define $f(a,b)$ as the first coordinate of $T(a,b)$. If $T(a,b)=(u,v)$, then equivariance gives

$$
T(b,a)=S(T(a,b))=(v,u).
$$

The first coordinate of $T(b,a)$ is therefore $v=f(b,a)$, and hence

$$
T(a,b)=(f(a,b),f(b,a))=P_f(a,b).
$$

Uniqueness follows because $f(a,b)$ is always the first coordinate of $P_f(a,b)$. $\square$

### Corollary 3.3 (Faithfulness)

If $P_f=P_g$, then $f=g$.

**Proof sketch.** Compare first coordinates at every $(a,b)$. $\square$

Theorem 3.2 identifies the magma monoid with the submonoid of transformations of $X^2$ centralizing $S$. The condition has a useful orbit interpretation. Reversal partitions $X^2$ into one-point orbits $(x,x)$ and two-point orbits $\{(a,b),(b,a)\}$ for $a\ne b$. An equivariant transformation must send diagonal points to diagonal points, and its value on one member of a two-point orbit determines its value on the other.

## 4. Images and diagonal geometry

Let

$$
\Delta=\{(x,x):x\in X\}
$$

be the diagonal of $X^2$. For $f\in\mathcal O_X$, define three subsets:

1. the **pair image**

$$
I_f=\operatorname{im}(P_f);
$$

2. the **diagonal image**

$$
D_f=P_f(\Delta)
=\{(f(x,x),f(x,x)):x\in X\};
$$

3. the **commutative image**

$$
C_f=I_f\cap\Delta.
$$

Equivalently,

$$
C_f=\{(y,y):\text{there exist }a,b\in X\text{ with }f(a,b)=f(b,a)=y\}.
$$

The terminology reflects that $C_f$ records outputs produced at pairs where $f$ happens to agree with its opposite. Since every diagonal input has a diagonal output, one always has

$$
D_f\subseteq C_f.
$$

The reverse inclusion is not automatic: an equal pair of outputs may arise only from unequal inputs. Equality $C_f=D_f$ says that every symmetric output has a symmetric witness.

## 5. Idempotent elements

An operation $f\in\mathcal O_X$ is **idempotent in the magma monoid** if

$$
f\star f=f.
$$

This must be distinguished from pointwise idempotence, the condition $f(x,x)=x$.

### Theorem 5.1 (Idempotence as image fixation)

For $f\in\mathcal O_X$, the following conditions are equivalent:

1. $f\star f=f$;
2. $P_f(p)=p$ for every $p\in I_f$.

Equivalently, magma-monoid idempotents correspond exactly to reversal-equivariant retractions of $X^2$ onto their images.

**Proof sketch.** By the composition law and faithfulness,

$$
f\star f=f
\quad\Longleftrightarrow\quad
P_f\circ P_f=P_f.
$$

If $p\in I_f$, write $p=P_f(q)$. Then $P_f(p)=P_f(P_f(q))=P_f(q)=p$. Conversely, if every image point is fixed, then $P_f(P_f(q))=P_f(q)$ for every $q$, proving transformation idempotence and therefore operation idempotence. $\square$

For finite $X$, the functional digraph of an idempotent $P_f$ has a particularly simple form: every vertex is either fixed or points directly to a fixed vertex. No cycle of length greater than one and no directed path of length greater than one can occur.

### Proposition 5.2 (Commutative pointwise-idempotent criterion)

Suppose $f$ satisfies

$$
f(a,b)=f(b,a)\quad\text{for all }a,b\in X
$$

and

$$
f(a,a)=a\quad\text{for all }a\in X.
$$

Then $f$ is idempotent in the magma monoid.

**Proof sketch.** For all $a,b$,

$$
(f\star f)(a,b)
=f(f(a,b),f(b,a))
=f(f(a,b),f(a,b))
=f(a,b).
$$

The second equality uses commutativity and the third uses pointwise idempotence. $\square$

This proposition applies to minimum and maximum on a totally ordered set, meet and join in a lattice, and any commutative idempotent magma. The converse is false in general: magma-monoid idempotence asks that $P_f$ fix its image, not that $f$ be globally commutative or pointwise idempotent.

### Theorem 5.3 (Diagonal equality for idempotents)

If $f\star f=f$, then

$$
C_f=D_f.
$$

**Proof sketch.** We already know $D_f\subseteq C_f$. For the converse, take $(y,y)\in C_f$. Then there exist $a,b$ such that

$$
f(a,b)=y=f(b,a).
$$

Evaluating $f\star f=f$ at $(a,b)$ gives

$$
f(y,y)=f(f(a,b),f(b,a))=f(a,b)=y.
$$

Therefore

$$
P_f(y,y)=(f(y,y),f(y,y))=(y,y),
$$

so $(y,y)\in D_f$. $\square$

The theorem has a dynamical reading. A diagonal point in $I_f$ is an image point and is therefore fixed by an idempotent $P_f$. It consequently witnesses its own membership in $D_f$.

## 6. Regular elements

An operation $f\in\mathcal O_X$ is **regular** if there exists $g\in\mathcal O_X$ such that

$$
(f\star g)\star f=f.
$$

The operation $g$ is an inner inverse for $f$. Applying the pair representation yields

$$
P_f\circ P_g\circ P_f=P_f.
$$

This is the familiar regularity equation in a transformation semigroup, with the additional requirement that $P_g$ be reversal-equivariant.

### Theorem 6.1 (Diagonal equality for regular operations)

If $f$ is regular, then

$$
C_f=D_f.
$$

**Proof sketch.** Again $D_f\subseteq C_f$ is automatic. Let $(x,x)\in C_f$, so there are $a,b\in X$ with

$$
f(a,b)=x=f(b,a).
$$

Choose $g$ satisfying $(f\star g)\star f=f$. Evaluation at $(a,b)$ gives

$$
f\left(g(f(a,b),f(b,a)),g(f(b,a),f(a,b))\right)=f(a,b).
$$

Substituting the equalities above reduces this to

$$
f(g(x,x),g(x,x))=x.
$$

Set $z=g(x,x)$. Then $P_f(z,z)=(x,x)$, proving $(x,x)\in D_f$. $\square$

The theorem provides a necessary regularity test. If a finite operation has a symmetric output $(x,x)$ somewhere in its pair image but no diagonal input maps to $(x,x)$, then the operation cannot be regular. The result does not by itself assert the converse; constructing an equivariant inner inverse from diagonal equality is a separate structural problem.

## 7. Coordinate selectors and central symmetry

The selectors $\lambda$ and $\rho$ have pair transformations

$$
P_\lambda(a,b)=(a,b),
\qquad
P_\rho(a,b)=(b,a)=S(a,b).
$$

Thus the identity operation corresponds to the identity transformation, while the right selector corresponds to reversal.

### Theorem 7.1 (Argument reversal by the right selector)

For every $f\in\mathcal O_X$,

$$
f\star\rho=f^{\mathrm{op}}=\rho\star f.
$$

Consequently, $\rho$ is central in the magma monoid.

**Proof sketch.** Direct calculation gives

$$
(f\star\rho)(a,b)=\rho(f(a,b),f(b,a))=f(b,a),
$$

and

$$
(\rho\star f)(a,b)=f(\rho(a,b),\rho(b,a))=f(b,a).
$$

Both products equal $f^{\mathrm{op}}$. $\square$

### Theorem 7.2 (Central involutive unit)

The right selector satisfies

$$
\rho\star\rho=\lambda.
$$

Therefore $\rho$ is a unit of order at most two and is regular. The identity $\lambda$ also commutes with every operation.

**Proof sketch.** Since multiplication by $\rho$ reverses arguments, applying it twice restores the original order. Explicitly,

$$
(\rho\star\rho)(a,b)=\rho(\rho(a,b),\rho(b,a))=\rho(b,a)=a=\lambda(a,b).
$$

For regularity, choose $g=\rho$; then $(\rho\star\rho)\star\rho=\lambda\star\rho=\rho$. Centrality of $\lambda$ follows from its identity property. $\square$

These facts show that reversal is not external bookkeeping: it is represented internally by multiplication with a distinguished central unit.

## 8. Structural consequences of equivariance

The representation theorem permits several conclusions that are useful independently of idempotence and regularity. First, the diagonal is invariant under every pair transformation. Indeed, because $(x,x)$ is fixed by reversal and $P_f$ commutes with reversal, the point $P_f(x,x)$ must also be fixed by reversal. Concretely,

$$
P_f(x,x)=(f(x,x),f(x,x))\in\Delta.
$$

Second, the full image $I_f$ is reversal-invariant. If $q=P_f(a,b)$, then

$$
S(q)=S(P_f(a,b))=P_f(S(a,b))=P_f(b,a),
$$

so $S(q)$ is also in $I_f$. Thus both the domain and image decompose into reversal orbits. This gives a compressed description on finite sets: it is enough to record behavior on the diagonal and on one representative of each unordered pair.

### Proposition 8.1 (Orbitwise determination)

A reversal-equivariant transformation $T:X^2\to X^2$ is uniquely determined by its values on the diagonal together with its value on one chosen representative of every two-element reversal orbit. Its value at the other representative is forced by equivariance.

**Proof sketch.** Every point is either diagonal or belongs to a pair $\{p,S(p)\}$ with $p\ne S(p)$. Once $T(p)$ is chosen, equivariance requires

$$
T(S(p))=S(T(p)).
$$

There is therefore no additional choice on the second representative. For a diagonal point $d$, equivariance requires $T(d)=S(T(d))$, so its value must itself be diagonal. $\square$

When $X$ is finite with $|X|=n$, there are $n$ diagonal orbits and $n(n-1)/2$ two-element orbits. This explains why pair transformations, although acting on $n^2$ points, carry exactly the information of an $n\times n$ operation table.

A third consequence concerns opposite operations. Since $P_{f^{\mathrm{op}}}=S\circ P_f=P_f\circ S$, passage to the opposite does not alter the pair image as a set:

$$
I_{f^{\mathrm{op}}}=S(I_f)=I_f.
$$

The last equality uses reversal-invariance. It also preserves both $C_f$ and $D_f$. Consequently, the image-based idempotence criterion and the diagonal obstruction are compatible with argument reversal. This is consistent with the fact that argument reversal is implemented by multiplication with the central unit $\rho$.

Finally, magma-monoid idempotence has an explicit dynamical normal form. If $f\star f=f$, then $X^2$ is partitioned into fibers indexed by fixed points in $I_f$. Each state maps directly to the fixed point indexing its fiber. Reversal permutes these fibers, and fibers indexed by diagonal fixed points are themselves reversal-invariant. This fiber description is the appropriate starting point for enumerating idempotents on finite sets: one chooses a reversal-invariant image, fixes it pointwise, and assigns every remaining reversal orbit to compatible image points.

These structural observations do not add hypotheses to the main theorems. They explain why the diagonal appears repeatedly: it is exactly the fixed locus of the symmetry defining the entire representation.

## 9. Finite algorithms

Assume $X=\{0,1,\ldots,n-1\}$ and an operation is represented by an $n\times n$ table.

### Algorithm 9.1 (Pair-transformation construction)

For each of the $n^2$ pairs $(a,b)$, store

$$
P_f(a,b)=(f(a,b),f(b,a)).
$$

This requires $O(n^2)$ time and $O(n^2)$ space. Composition of two pair transformations also takes $O(n^2)$ time, compared with the same asymptotic cost for constructing the product table directly.

### Algorithm 9.2 (Idempotence test)

Compute $P_f$. For every pair $p$, compute $q=P_f(p)$ and verify $P_f(q)=q$. By Theorem 5.1, $f$ is idempotent exactly when all tests pass. The running time is $O(n^2)$ after constant-time table indexing, and the storage requirement is $O(n^2)$, or $O(1)$ auxiliary space if values are recomputed.

### Algorithm 9.3 (Diagonal-obstruction test for regularity)

Compute

$$
C_f=\{P_f(a,b):a,b\in X\}\cap\Delta
$$

and

$$
D_f=\{P_f(x,x):x\in X\}.
$$

If $C_f\ne D_f$, conclude that $f$ is not regular. Construction takes $O(n^2)$ expected time with hash sets, or $O(n^2+n\log n)$ with sorted collections. Equality is necessary, not asserted here to be sufficient.

### Algorithm 9.4 (Exhaustive enumeration for small sets)

There are $n^{n^2}$ binary operations on an $n$-element set. Iterate over all tables, apply the $O(n^2)$ idempotence test, and optionally record diagonal equality. The total running time is $O(n^{n^2}n^2)$ and the working space per operation is $O(n^2)$. This is practical only for small $n$, but it provides exact experimental data and diagnostic examples.

## 10. Examples

### 10.1. Minimum and maximum

On a finite chain, both $\min$ and $\max$ are commutative and satisfy $f(x,x)=x$. Proposition 5.2 therefore makes them magma-monoid idempotents. Their pair transformations map every pair to a diagonal point:

$$
P_{\min}(a,b)=(\min(a,b),\min(a,b)).
$$

Because every element occurs as $\min(x,x)$, both $C_f$ and $D_f$ equal the full diagonal.

### 10.2. Coordinate selectors

For $\lambda(a,b)=a$, the pair transformation is the identity on $X^2$, so $\lambda$ is idempotent and regular. For $\rho(a,b)=b$, the pair transformation is reversal. If $|X|>1$, reversal is not idempotent as a transformation, but it is an involutive unit and hence regular. Its diagonal and commutative images both equal $\Delta$.

### 10.3. An obstruction to regularity

Let $X=\{0,1\}$ and define $f$ by

$$
f(0,0)=0,\quad f(0,1)=1,\quad f(1,0)=1,\quad f(1,1)=0.
$$

Then $(1,1)=P_f(0,1)$ belongs to $C_f$. However, diagonal inputs satisfy

$$
P_f(0,0)=(0,0),\qquad P_f(1,1)=(0,0),
$$

so $(1,1)\notin D_f$. Thus $C_f\ne D_f$, and Theorem 6.1 proves that $f$ is not regular. The same inequality also rules out magma-monoid idempotence by Theorem 5.3.

## 11. Applications and broader interpretation

The pair representation provides a common language for algebra and dynamics. A finite binary operation determines a directed graph on $X^2$, with one outgoing edge from each vertex. Algebraic idempotence says that every edge ends at a fixed point. Regularity says that the image can be recovered through an equivariant intermediate transformation, and its diagonal consequence expresses compatibility with the fixed-point locus of reversal.

The construction is also computationally useful. Properties stated as identities between three-variable nested products become local graph checks. Symmetry reduces storage and search: an equivariant transformation is determined by its values on one representative from each reversal orbit, subject to diagonal values remaining diagonal. This orbit structure may be exploited when enumerating operations or searching for witnesses to regularity.

The framework extends conceptually to other algebraic products built by evaluating a function over a group orbit of its inputs. Here the acting group has two elements, generated by coordinate reversal. For higher-arity operations, permutation groups acting on tuples may yield analogous equivariant transformation models.

There is also a useful distinction between decision procedures and witness construction. The idempotence criterion is a complete decision: inspecting image fixation proves either idempotence or its failure. The diagonal comparison for regularity is presently one-sided: inequality proves non-regularity, while equality only removes this particular obstruction. This distinction should be preserved in computational implementations and experimental reports. A search for an inner inverse may be substantially more expensive than the diagonal test, because it ranges over operations rather than merely over pair states. The structural program is therefore to convert witness search into orbitwise choices, just as the pair representation converted the original multiplication into composition. If successful, that conversion would supply both a conceptual converse theorem and a more efficient algorithm.

## 12. Discussion and future work

The transformation perspective establishes a complete intrinsic description of pair transformations, a retraction criterion for idempotents, necessary diagonal geometry for idempotent and regular elements, and the central involutive role of the right selector. Several natural developments remain.

First, one may seek a converse to Theorem 6.1: if $C_f=D_f$, construct an inner inverse $g$ such that $(f\star g)\star f=f$. In transformation language, the task is to choose preimages on $I_f$ while preserving reversal equivariance; the diagonal equality is exactly the compatibility condition at fixed points of reversal.

Second, principal ideals should admit descriptions through transformation invariants. Left multiplication changes a pair transformation by postcomposition, suggesting image data, while right multiplication acts by precomposition, suggesting kernel partitions. The special behavior of diagonal orbits indicates that diagonal image data must accompany the ordinary image.

Third, for finite $X$, exact enumeration of idempotent and regular elements can be approached by decomposing $X^2$ into reversal orbits and counting equivariant retractions or regular transformations. Such formulas would refine brute-force enumeration and explain observed sequences structurally.

Finally, the center beyond the always-central selectors depends on the cardinality and exceptional small cases. The pair model turns this into a centralizer problem inside a transformation monoid, offering a systematic route to classification.

## 13. Conclusion

The map

$$
f\longmapsto P_f,
\qquad
P_f(a,b)=(f(a,b),f(b,a)),
$$

reveals the magma monoid as the monoid of transformations of $X^2$ commuting with coordinate reversal. It is faithful and converts the product $\star$ into composition. Under this correspondence, idempotents are equivariant retractions, regularity is equivariant inner invertibility, diagonal equality records the existence of symmetric witnesses, and the right selector is reversal itself. The representation thus replaces nested operation-table formulas with ordinary transformation dynamics while retaining all information about the original binary operations.