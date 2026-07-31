# Where Tropical Curves Bend: Equations, Schemes, and the Art of Gluing

## A different climate for algebra

Ordinary algebra asks us to add and multiply numbers. Tropical algebra changes the weather. In the **min-plus tropical system**, the operation called addition is minimum,

$$
a\oplus b=\min(a,b),
$$

while the operation called multiplication is ordinary addition,

$$
a\odot b=a+b.
$$

The symbol $\infty$ serves as the additive identity because $\min(a,\infty)=a$, and $0$ serves as the multiplicative identity because $a+0=a$. These rules form a commutative semiring: they retain enough of familiar algebra to support polynomials, evaluation, and geometry, but they do not provide additive inverses.

This small alteration turns curved algebraic varieties into angular, polyhedral objects. A tropical polynomial is the minimum of finitely many affine-linear expressions. In one variable, for example,

$$
F(x)=\min\{0,x\}
$$

has two linear pieces meeting at $x=0$. In two variables,

$$
F(x,y)=\min\{0,x,y\}
$$

produces three planar regions meeting along a three-rayed tropical line. The geometry lives where the winning expression changes—where the minimum is attained by at least two terms.

That intuitive description is wonderfully visual. Yet modern algebraic geometry demands another kind of description: one built from equations, spaces, and functions that can be restricted and glued. The central result developed here is that these two languages agree. The visible creases of a tropical polynomial are exactly the points selected by a natural family of algebraic **bend equations**. Moreover, the functions carried by the resulting space obey a full gluing principle, providing the basic architecture of a tropical scheme.

## Corners as ties

Let $X$ be a set of points, let $I$ be a set indexing terms, and let

$$
f_i:X\to A \qquad (i\in I)
$$

be functions valued in a partially ordered set $A$. Think of $f_i(x)$ as the value of the $i$th tropical monomial at $x$. A term $i$ is **minimal at $x$** if

$$
f_i(x)\le f_k(x)\quad\text{for every }k\in I.
$$

The point $x$ is a **corner** if two distinct terms are both minimal there. Thus there must be $i\ne j$ such that

$$
f_i(x)\le f_k(x)\quad\text{and}\quad f_j(x)\le f_k(x)
$$

for every $k\in I$. For finite tropical polynomials over the real numbers with $\infty$ allowed, a minimum always exists, so this definition captures the familiar corner locus.

Imagine lowering a horizontal ceiling onto a collection of heights $f_i(x)$. Usually one term touches first. At a corner, two or more touch simultaneously. The corner locus records all such ties.

Why should a tie be an equation? In ordinary algebra, a hypersurface is often described by setting one polynomial equal to zero. Tropical algebra has no subtraction, so the expression “left side minus right side” is unavailable. Bend equations replace subtraction with deletion.

## Delete one term and ask what changes

Fix a term $i$. Its **bend equation** holds at $x$ when some different term $j$ is no larger:

$$
\exists j\ne i\quad f_j(x)\le f_i(x).
$$

For a min-plus polynomial, this says that deleting term $i$ does not raise the polynomial’s value whenever $i$ is a winner: another term can take its place. Requiring this condition for every $i$ creates the **bend vanishing set**,

$$
V_{\mathrm{bend}}(f)=
\left\{x\in X:\text{for every }i\in I,
\text{ some }j\ne i\text{ satisfies }f_j(x)\le f_i(x)\right\}.
$$

At first, this looks stronger than merely asking for two minimizers. It tests every term, including terms far above the minimum. The surprise is that, once a minimum exists, the extra tests cost nothing.

### The Corner–Bend Theorem

**Theorem.** Suppose at least one term is minimal at $x$. Then $x$ is a corner if and only if every bend equation holds at $x$.

The proof is short enough to see in a picture. If terms $a$ and $b$ share the minimum, then deletion can never leave a unique unsupported winner. When testing term $a$, choose $b$; for every other tested term, choose $a$. Since $a$ is minimal, it lies no higher than the tested term.

Conversely, choose a minimal term $i$. The bend equation for $i$ supplies a different term $j$ with $f_j(x)\le f_i(x)$. Minimality of $i$ also gives $f_i(x)\le f_j(x)$. Hence $i$ and $j$ have the same minimum value. The order’s antisymmetry ensures this is a genuine tie in value, and both terms are minimal.

The set-level consequence is immediate:

$$
V_{\mathrm{bend}}(f)=\{x\in X:x\text{ is a corner of }f\},
$$

provided a minimum exists at every point. This is the connector between polyhedral geometry and an equation-based theory.

## A crossing under the microscope

Consider again

$$
F(x)=\min\{0,x\},\qquad x\in\mathbb Z.
$$

There are two terms, $f_0(x)=0$ and $f_1(x)=x$. The bend equation for the constant term asks for

$$
x\le 0,
$$

because the other term must lie no higher. The bend equation for the variable term asks for

$$
0\le x.
$$

Both equations hold exactly when $x=0$. This is also exactly where the two terms tie. The example is tiny, but it displays the entire mechanism: all deletion equations intersect at the visible crossing.

For the tropical line $\min\{0,x,y\}$, the same rule selects points where at least two among $0$, $x$, and $y$ share the minimum. The result is three rays: $x=0\le y$, $y=0\le x$, and $x=y\le0$. A condition expressed by comparisons among terms recovers a polyhedral graph.

## From a set of bends to a scheme

A geometric object is more than its points. One also wants to know which functions live on each region and how local descriptions combine. This is the role of a sheaf.

Let $K$ be any commutative semiring and $Y$ a topological space. Assign to every open region $U\subseteq Y$ the commutative semiring

$$
\mathcal O(U)=\{s:U\to K\},
$$

with addition and multiplication performed pointwise. Whenever $V\subseteq U$, restriction simply forgets values outside $V$:

$$
\rho_{U,V}(s)=s|_V.
$$

Restrictions do nothing when $V=U$, and restricting from $U$ to $V$ and then to $W$ gives the same result as restricting directly from $U$ to $W$. This data is a semiring-valued presheaf.

The essential step is the gluing axiom. Suppose a region $U$ is covered by regions $V_i$, and on each $V_i$ we have a function $s_i:V_i\to K$. Assume the local functions agree wherever their domains overlap:

$$
s_i|_{V_i\cap V_j}=s_j|_{V_i\cap V_j}
\quad\text{for all }i,j.
$$

Then there is one and only one function $s:U\to K$ whose restriction to every $V_i$ is $s_i$.

**Function-Sheaf Gluing Theorem.** The assignment $U\mapsto\mathcal O(U)$ of all $K$-valued functions satisfies existence and uniqueness of gluing for every indexed cover.

To construct $s$, take a point $x\in U$, choose any covering region $V_i$ containing it, and set $s(x)=s_i(x)$. Agreement on overlaps makes the choice irrelevant. Uniqueness is pointwise: any other glued function must have the prescribed value on a covering region containing $x$.

This theorem matters because local calculations are useful only when compatible answers assemble into a global object. It is the mathematical principle behind patching coordinate charts on a manifold, combining local sensor measurements, and merging locally consistent data tables. Tropical geometry inherits the same local-to-global discipline.

## The principal tropical scheme

A **semiring scheme over $K$**, in this foundational sense, consists of a topological space, a sheaf of commutative semirings on it, and a homomorphism from $K$ to the global sections that sends each scalar to its constant function. Replacing rings by semirings is crucial: tropical addition is idempotent, since $a\oplus a=a$, and subtraction is generally impossible.

A **tropical scheme** is a semiring scheme over the min-plus tropical semiring. Given a family of polynomial terms $f_i$, its principal tropical scheme takes the bend vanishing set as its point space and equips that space with the function sheaf. Constants act as constant functions.

The Corner–Bend Theorem now becomes a geometric statement.

**Principal Tropical Scheme Theorem.** If the family of terms has a minimum at every point, then the underlying points of its principal tropical scheme are exactly the corner locus of the associated tropical polynomial. Its structure sheaf satisfies the gluing axiom for arbitrary covers.

Thus nothing is lost when one moves from the drawn tropical hypersurface to the scheme-like description. The same points are selected, but they now carry local semiring-valued functions and a rigorous mechanism for assembling them.

## Why the bridge matters

Tropical geometry appears in optimization, phylogenetics, scheduling, discrete-event systems, and the study of degenerations in algebraic geometry. In all these settings, minima or maxima compete, and qualitative behavior changes at ties. A corner locus is therefore a phase-change diagram: it marks where two explanations, routes, timings, or monomials become equally competitive.

The bend-equation viewpoint adds algebraic portability. Equations can be transported, combined, and organized through congruences even when subtraction is unavailable. The sheaf viewpoint adds locality. A complicated tropical space can be studied region by region, with overlap conditions ensuring that the pieces describe one global object.

This foundation is deliberately spare. The function sheaf uses all semiring-valued functions rather than a more selective class of locally regular functions, and the principal construction starts from term families rather than a full polynomial syntax. Yet the core architecture is already visible: an ordered, piecewise-linear corner condition; a deletion-based algebraic vanishing condition; and a local-to-global sheaf.

The result is a clean meeting point between two traditions. Tropical geometry contributes polyhedral bends and combinatorial visibility. Scheme theory contributes spaces equipped with functions, equations without dependence on coordinates, and gluing. At every point where two tropical terms tie, these perspectives describe the same event—one as a corner we can draw, the other as a family of equations we can build with.