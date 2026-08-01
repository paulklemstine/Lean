# When the Minimum Must Tie: Bergman Fans and Tropical Linear Spaces

## A geometry built from competition

Ordinary geometry is governed by addition and multiplication. Tropical geometry changes the rules: addition is replaced by taking a minimum, while multiplication becomes ordinary addition. Under this arithmetic, smooth curves turn into polyhedral complexes, algebraic equations become competitions among affine functions, and the most interesting points are precisely those where the winner is not unique.

That last idea—the minimum must tie—is the organizing principle of the Bergman fan of a matroid.

A matroid is an abstract model of dependence. Its ground set $E$ may consist of vectors, edges of a graph, columns of a matrix, or elements of any system in which some collections depend on one another. The minimal dependent sets are called **circuits**. In a graph, the circuits of its graphic matroid are exactly the edge sets of simple cycles. In a vector configuration, they record minimal linear dependencies.

Now assign a real weight $w_e$ to every element $e\in E$. For each circuit $C$, inspect the numbers $\{w_e:e\in C\}$. The weight vector passes the tropical dependence test on $C$ when the smallest number occurs at least twice. Equivalently, there must be distinct $e,f\in C$ such that

$$
w_e=w_f\leq w_x\qquad\text{for every }x\in C.
$$

The **Bergman fan** $B(M)$ is the set of all weight vectors that pass this test simultaneously on every circuit of the matroid $M$.

Why demand a tie? A unique lightest element of a circuit singles out one member of a minimal dependency. Tropical linear dependence forbids that asymmetry. A circuit may have several heavier elements, but its floor cannot be occupied by just one coordinate.

## Two descriptions, one space

There is an algebraic way to package the same test. Associate to every circuit $C$ the coefficient-free tropical polynomial

$$
p_C(w)=\min_{e\in C} w_e.
$$

Its tropical zero set, or corner locus, consists of those $w$ where the displayed minimum is attained at least twice. The **circuit ideal**, at the level relevant here, is the family of all circuit supports. Its tropical linear space is the intersection of the corner loci of all the $p_C$.

This yields the central identification.

**Bergman Fan–Tropical Linear Space Theorem.** For every matroid $M$,

$$
B(M)=\{w:\text{the minimum of }w\text{ on every circuit of }M
\text{ occurs at least twice}\},
$$

and this set is exactly the tropical linear space cut out by the circuit ideal of $M$.

The proof is direct but conceptually decisive. Membership on the left means passing the repeated-minimum condition for each circuit. Membership in the tropical zero set of the circuit ideal means passing exactly the same condition for each circuit generator. The quantifiers and tests coincide circuit by circuit.

This equality is a bridge between two languages. Matroid theory says “minimal dependence.” Tropical algebra says “a minimum with multiple winners.” The Bergman fan is where those descriptions meet.

## A small example

Consider the rank-two uniform matroid on $E=\{1,2,3\}$. Its only circuit is $C=\{1,2,3\}$. Thus

$$
B(M)=\{(w_1,w_2,w_3)\in\mathbb R^3:
\min(w_1,w_2,w_3)\text{ occurs at least twice}\}.
$$

The vector $(0,0,2)$ belongs to the fan, as do $(0,3,0)$ and $(4,1,1)$. The vector $(0,1,2)$ does not: its unique minimum occurs at the first coordinate. Geometrically, the fan is the union of three two-dimensional regions meeting along the diagonal line $w_1=w_2=w_3$. After identifying points that differ by a common translation, this becomes the familiar tropical line with three rays.

The example also reveals an important warning. Bergman fans are called fans, but they are not generally convex in the ordinary sense. Both $(0,0,2)$ and $(0,2,0)$ pass the test, while their midpoint $(0,1,1)$ fails because its minimum is unique. Their structure is tropical and polyhedral, not simply that of one ordinary convex cone.

## The symmetries that every circuit can see

Suppose $w$ passes every circuit test. Add the same number $c$ to every coordinate. Comparisons do not change:

$$
w_e\leq w_x\quad\Longleftrightarrow\quad w_e+c\leq w_x+c,
$$

and equal minima remain equal. Therefore

$$
w\in B(M)\quad\Longleftrightarrow\quad w+c\mathbf 1\in B(M),
$$

where $\mathbf 1$ is the all-ones vector.

There is a second symmetry. If $a\geq0$, multiplying every coordinate by $a$ preserves order and equality, so

$$
w\in B(M)\quad\Longrightarrow\quad aw\in B(M).
$$

At $a=0$, every coordinate becomes equal, which certainly creates repeated minima on every circuit with at least two elements.

Call a set of weights a **tropical linear cone** when it is invariant under common-coordinate translation and closed under nonnegative ordinary dilation. The two observations prove the following.

**Tropical Cone Theorem.** The Bergman fan of every matroid is a tropical linear cone.

This use of “cone” is deliberately specific: it asserts the two symmetries above, not closure under ordinary addition and not ordinary convexity.

A matroid is called **nested** when its cyclic flats are totally ordered by inclusion. Here a set is cyclic if each of its elements belongs to a circuit contained in the set, and a cyclic flat is both cyclic and closed under matroid closure. Since the Tropical Cone Theorem applies to every matroid, it immediately applies to nested matroids.

**Nested-Matroid Corollary.** If $M$ is nested, then $B(M)$ is invariant under common-coordinate translation and closed under nonnegative dilation.

Nestedness may support sharper geometric conclusions in further work, but the established conclusion here is exactly this tropical cone structure.

## Components hidden inside lineality

Some directions move through the fan without changing the circuit comparisons at all. Define the **Bergman lineality space** $L(M)$ to consist of weights $v$ that are constant on every circuit: whenever $e$ and $f$ lie in a common circuit $C$, one has $v_e=v_f$.

To understand this space, connect two ground elements when some circuit contains both, and then allow chains of such connections. Two elements are in the same **circuit component** if one can travel from one to the other through a finite sequence of common-circuit steps.

The local circuit condition has an exact global description.

**Component–Lineality Theorem.** A weight $v$ belongs to $L(M)$ if and only if it is constant on every circuit component.

For the forward direction, move along a chain of circuit adjacencies. At each step, circuitwise constancy says that the value cannot change; transitivity carries equality from the start of the chain to its end. Conversely, if $v$ is constant on components, then any two elements in one circuit are adjacent and hence lie in the same component, so their values agree.

Call a matroid **circuit-connected** when its ground set is nonempty and every pair of ground elements belongs to the same circuit component. The theorem immediately gives a clean topological-algebraic consequence.

**Connected-Lineality Corollary.** If $M$ is circuit-connected, every weight in $L(M)$ is constant on the ground set.

Thus connectivity is visible as the collapse of circuitwise lineality to the single common-translation direction. For a disconnected matroid, different components may carry different constants; the circuit constraints cannot compare values across components.

## A path that never leaves the fan

Fix any weight $w$. Its **translation orbit** is

$$
\mathcal O(w)=\{w+c\mathbf 1:c\in\mathbb R\}.
$$

This is an affine line in the ambient weight space. If two points on it are $w+c_1\mathbf 1$ and $w+c_2\mathbf 1$, then every convex combination is

$$
a(w+c_1\mathbf 1)+b(w+c_2\mathbf 1)
=w+(ac_1+bc_2)\mathbf 1
$$

whenever $a,b\geq0$ and $a+b=1$. Hence the orbit is convex, and therefore path connected.

Combine this with translation invariance.

**Translation-Orbit Theorem.** For every $w\in B(M)$, the entire orbit $\mathcal O(w)$ lies in $B(M)$. Moreover, $\mathcal O(w)$ is convex and path connected.

An explicit path from $w+c_1\mathbf 1$ to $w+c_2\mathbf 1$ is

$$
\gamma(t)=w+\big((1-t)c_1+tc_2\big)\mathbf 1,
\qquad 0\leq t\leq1.
$$

Every circuit sees all its coordinates shift by the same amount at every time, so every repeated minimum survives along the journey.

This is a modest but concrete link between matroid dependence and topology. Each Bergman weight comes with a guaranteed connected direction. Passing to tropical projective space amounts to quotienting out precisely this ubiquitous common-translation motion.

## Why the picture matters

Bergman fans turn discrete dependence data into geometry. For a network, circuits are cycles, so a valid weighting forbids any cycle from having a unique cheapest edge. For vector configurations, circuits are minimal linear relations, and the same condition records tropical dependence. In optimization language, every minimal dependency must have at least two co-winners at its floor.

The results above organize this geometry into four layers. First, circuit equations and the Bergman condition define exactly the same space. Second, repeated minima survive common translations and nonnegative rescaling. Third, lineality is controlled precisely by circuit components, making connectivity legible in the allowable constant directions. Fourth, every common-translation orbit inside the fan is a convex, path-connected affine line.

All four layers arise from one elementary fact: inequalities and equalities among coordinates survive when every coordinate is shifted together, and they propagate along chains of circuits. Tropical geometry often transforms algebra into combinatorics. Here it also transforms combinatorics back into topology—one tied minimum, one circuit, and one connected component at a time.

The resulting viewpoint is practical as well as conceptual. For a finite list of circuits, one can test a weight simply by scanning each circuit, finding its least value, and checking that it appears twice. The same data can be assembled into a graph whose edges join elements sharing a circuit; the connected components of that graph reveal every permissible lineality constant. What begins as a collection of local ties therefore becomes an explicit computational pipeline from dependence data to tropical geometry.
