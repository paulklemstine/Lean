# When Tropical Stereography Becomes the Identity

## A familiar projection in an unfamiliar arithmetic

Stereographic projection is one of geometry’s great acts of translation. Place a sphere above a plane, choose a pole on the sphere, and draw a line from that pole through every other point. Each line meets the plane once. The construction turns a curved world into a flat one while preserving a remarkable amount of local geometric structure. It appears in cartography, complex analysis, optics, and the geometry of the Riemann sphere.

What happens if the arithmetic underneath geometry is changed?

Tropical geometry asks exactly that kind of question. In its max-plus convention, ordinary addition is replaced by maximum, while ordinary multiplication is replaced by addition. Thus the tropical sum and product are

$$
a\oplus b=\max(a,b),\qquad a\odot b=a+b.
$$

A tropical polynomial is therefore not a smooth curve of powers and coefficients. It is the maximum of finitely many affine functions. Its graph is piecewise linear, with corners where competing affine terms exchange dominance. This deceptively simple change transforms algebraic geometry into a world of polyhedral shapes, optimization, shortest paths, scheduling, and combinatorics.

The natural hope is that stereographic projection also has a tropical analogue: a pole-based map from a tropical projective line to a tropical affine line, perhaps behaving like a tropical Möbius transformation. In one dimension, that proposal can be written explicitly—and the result is both simpler and more instructive than its formula suggests.

## The tropical projective line has two meanings

Before writing the map, one must settle a topological ambiguity. A finite tropical projective point is a pair of real coordinates $(x_0,x_1)$, where adding the same real number to both coordinates changes nothing:

$$
(x_0,x_1)\sim(x_0+\lambda,x_1+\lambda).
$$

The difference

$$
x=x_1-x_0
$$

is unchanged by this simultaneous translation, and every real value occurs. Consequently, the finite tropical projective line is naturally represented by the ordinary real line. The normalized coordinate $x$ is not merely convenient; it completely describes the equivalence class.

There is also a compactified convention in which infinite tropical coordinates are admitted. That version acquires endpoint behavior and is topologically an extended real line, not an ordinary real line. The distinction matters. The finite line is noncompact, whereas the compactified line is compact. Any proposed “stereographic homeomorphism” must respect which object is being used.

## A quadratic-looking pole formula

For the finite line, consider the pole-inspired max-plus rational expression

$$
S(x)=\max(2x,x)-\max(x,0).
$$

The numerator has a term of tropical degree two, represented by $2x$, and a term of degree one, represented by $x$. The denominator has degree at most one. On its face, $S$ looks like a tropical rational map of quadratic-over-linear type—the expected analogue of a degree-two pole construction.

But tropical formulas often hide cancellation. To see what this one does, examine the two possible signs of $x$.

If $x\leq 0$, then $2x\leq x$ and $x\leq 0$. Hence

$$
\max(2x,x)=x,\qquad \max(x,0)=0,
$$

so $S(x)=x$.

If $x\geq 0$, then $2x\geq x$ and $x\geq 0$. Hence

$$
\max(2x,x)=2x,\qquad \max(x,0)=x,
$$

and again $S(x)=x$.

This proves the central identity:

> **Identity Theorem.** For every real normalized coordinate $x$, the tropical pole expression satisfies $S(x)=x$.

At the apparent corner $x=0$, both branches agree. The expression has not merely become continuous or invertible. It has collapsed exactly to the identity map.

## A homeomorphism hiding in plain sight

Because $S(x)=x$ everywhere, the finite tropical stereographic map is automatically a homeomorphism from the finite tropical projective line to the real tropical affine line. Its inverse is itself, and both directions are continuous.

> **Finite Homeomorphism Theorem.** In the normalized coordinate $x=x_1-x_0$, the map $S(x)=\max(2x,x)-\max(x,0)$ is a homeomorphism from the finite tropical projective line onto $\mathbb{R}$.

This is a clean positive answer to the homeomorphism question. Yet it also alters the geometric interpretation. Classical stereographic projection depends visibly on its pole. The tropical map appears to remember a pole in its syntax, but normalization may erase that information.

To test this, move the pole to an arbitrary finite position $p$ and define

$$
S_p(x)=\max(2x,x+p)-\max(x,p).
$$

A single distributive identity reveals what happens:

$$
\max(2x,x+p)=x+\max(x,p).
$$

Subtracting the denominator gives

$$
S_p(x)=x+\max(x,p)-\max(x,p)=x.
$$

Thus every finite pole produces exactly the same normalized map.

> **Pole-Independence Theorem.** For every pair of real pole positions $p$ and $q$, one has $S_p(x)=S_q(x)=x$ for every real $x$.

This is a rigidity phenomenon. The family is not a moving collection of distinct transformations; after tropical projective normalization, it is a single transformation written in many ways. Pole position has become gauge-like data: visible before cancellation, invisible afterward.

## The danger of reading degree from a formula

The expression $S(x)$ certainly has a quadratic-over-linear presentation. More generally, call a function $f:\mathbb{R}\to\mathbb{R}$ quadratic-presentable in this pole-shaped sense if there are real constants $a,b,c,d$ such that

$$
f(x)=\max(2x+a,x+b)-\max(x+c,d)
$$

for all $x$. Taking $a=b=c=d=0$ gives the displayed formula for $S$.

Now call $f$ linearly presentable if it is a translation in normalized tropical coordinates: there is a real constant $c$ such that

$$
f(x)=x+c
$$

for every $x$. Since $S(x)=x$, it has a linear presentation with $c=0$.

> **Degree-Collapse Theorem.** The tropical stereographic map admits the proposed quadratic-over-linear presentation, but it also admits a linear presentation. Therefore its minimal presentation degree is not exactly two under these definitions.

This distinction between displayed degree and intrinsic degree is familiar across mathematics. A rational function may be written with high-degree numerator and denominator that share a common factor. A complicated computer expression may simplify to a constant. In tropical arithmetic, common max-plus structure can likewise cancel across a difference of maxima.

For applications, the warning is practical. Tropical models are used in optimization, neural-network geometry, discrete-event systems, and phylogenetics. Their formulas often encode maxima of competing linear regimes. Counting terms or inspecting the largest slope before cancellation can overstate complexity. A meaningful degree theory should be invariant under identities that leave the function unchanged.

## Why compactification changes the answer

The finite result cannot simply be transferred to the compactified tropical projective line while keeping the real line as target. The obstruction is topological and decisive.

A homeomorphism preserves compactness. The compactified tropical projective line is compact, while $\mathbb{R}$ is not compact. Therefore no homeomorphism can exist between them.

> **Compactness Obstruction.** There is no homeomorphism from the compactified tropical projective line to the ordinary real line.

This does not say that compactified tropical stereography is impossible. It says that the codomain must also be compactified—an extended real line is the natural candidate. The lesson mirrors classical geometry: adding a point at infinity changes the global topology, and global topology constrains every possible coordinate map.

The positive finite theorem and the negative compactified theorem are not contradictory. They answer different questions. With finite coordinates, the quotient is $\mathbb{R}$ and the pole expression is the identity homeomorphism. With endpoints admitted, the source is compact and cannot be homeomorphic to $\mathbb{R}$.

## A tiny numerical window

The cancellation can be seen immediately in sample values:

$$
S(-3)=-3,\quad S(-1)=-1,\quad S(0)=0,\quad S(2)=2,\quad S(5)=5.
$$

For negative inputs, the first maximum selects $x$ and the second selects $0$. For positive inputs, the first selects $2x$ and the second selects $x$. The selected terms change at the origin, but their difference keeps slope one on both sides.

The pole family has a similar visual signature. For fixed $p$, both the numerator $\max(2x,x+p)$ and denominator $\max(x,p)$ bend at $x=p$. Their bends coincide and cancel exactly. Plotting the two components separately shows rich piecewise-linear structure; plotting their difference shows only a straight diagonal.

That contrast captures the entire story. Tropical geometry is often drawn as a geometry of corners, but differences of tropical polynomials can conceal those corners. Geometry lives not only in the pieces but also in how they cancel.

## What survives of stereography?

The one-dimensional construction succeeds as a homeomorphism and fails as a nontrivial pole-dependent transformation. That combination is more informative than either outcome alone.

It establishes a baseline for higher dimensions: define a finite tropical projective space as real coordinate vectors modulo simultaneous translation, choose a normalization, and ask whether analogous pole formulas again reduce to affine maps. It suggests that compactified models should be paired with compactified targets. It also motivates an intrinsic notion of tropical rational degree, defined only after common tropical structure has been cancelled.

Most intriguingly, it asks what additional structure is needed to preserve the pole. Marked ends, metric-graph lengths, harmonic data, or other decorations may retain information that bare projectivization discards. In classical conformal geometry, the pole determines a coordinate chart. In this tropical model, the normalized coordinate overwhelms the pole completely.

The final picture is therefore crisp. A quadratic-looking tropical stereographic expression is exactly the identity. Every finite pole yields the same map. The finite projective line is homeomorphic to the real line through that map, but the compactified line is not. And the degree visible in a formula need not be the degree of the function it represents.

Sometimes changing arithmetic creates exotic new geometry. Sometimes it strips a celebrated construction to its skeleton. Here, tropicalization turns stereographic projection into the simplest map possible—and in doing so exposes the roles of normalization, cancellation, and topology with unusual clarity.
