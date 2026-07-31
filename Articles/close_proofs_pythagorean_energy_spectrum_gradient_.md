# When Right Triangles Become Factor Certificates

## A landscape built from two equations

A right triangle and a factorization seem to belong to different mathematical worlds. The first is geometric: three whole-number side lengths $a$, $b$, and $c$ form a right triangle when

$$
a^2+b^2=c^2.
$$

The second is arithmetic: two integers encode a target integer $N$ when

$$
ab=N.
$$

Yet the two conditions can be fused into a single numerical landscape. On this landscape, every integer triple $(a,b,c)$ receives an “energy” measuring how far it is from satisfying both equations at once:

$$
E(a,b,c;N)=\bigl(a^2+b^2-c^2\bigr)^2+(ab-N)^2.
$$

This simple formula is the central character of our story. Its first term penalizes failure to be a Pythagorean triple. Its second penalizes failure of the two legs to multiply to the chosen target. Squaring is crucial: errors of either sign count equally, and the two penalties can never cancel each other.

The resulting idea is appealingly physical. Imagine every integer triple as a point in a rugged terrain. A point sits at sea level precisely when it describes both a right triangle and a multiplication certificate for $N$. Everywhere else rises above sea level according to the combined squared error. Factoring a number is thereby connected to finding a zero-energy point with a leg strictly between $1$ and $N$.

This is not a claim that every composite number possesses such a triangle, nor that a universally successful descent algorithm has already been obtained. It is something more exact and foundational: a complete description of the energy’s algebraic geometry, its zeros, its minima, and the factor certificates those zeros contain.

## Why the energy can never be negative

The first structural fact is immediate but indispensable.

**Nonnegativity Theorem.** For all integers $a,b,c,N$,

$$
E(a,b,c;N)\ge 0.
$$

Each summand is the square of an integer, hence nonnegative. This means that zero is not merely a convenient value; it is the absolute floor of the entire landscape. No hidden valley lies below it.

The formula also respects the geometric interchangeability of the two legs.

**Leg-Symmetry Theorem.** For all integers $a,b,c,N$,

$$
E(b,a,c;N)=E(a,b,c;N).
$$

Indeed, $a^2+b^2$ is unchanged when the legs are swapped, and $ba=ab$. The landscape therefore does not privilege one orientation of a right triangle over the other.

## Zero energy means exact success

Because the energy is a sum of squares, its zero set has a particularly clean interpretation.

**Zero-Energy Characterization.** For integers $a,b,c,N$,

$$
E(a,b,c;N)=0
$$

if and only if both

$$
a^2+b^2=c^2
$$

and

$$
ab=N
$$

hold.

To see why, suppose the energy is zero. Both squared residuals are nonnegative, so their sum can vanish only if each one vanishes. Conversely, if both equations are exact, both residuals are zero and so is their sum.

This equivalence turns a numerical score into a certificate checker. A zero is not merely suggestive evidence of nearby structure. It simultaneously certifies a right triangle and an exact product.

There is a global consequence.

**Certificate-Minimum Theorem.** If integers $a,b,c$ satisfy $a^2+b^2=c^2$ and $ab=N$, then $E(a,b,c;N)=0$, and this value is a global minimum among all integer triples.

The proof needs no calculus. The certificate has energy zero by direct substitution, while every competing triple has nonnegative energy. Thus every valid Pythagorean factor certificate reaches the lowest possible level.

## Extracting a proper divisor

A zero-energy point becomes a nontrivial factor certificate once one of its legs lies in the proper range.

**Factor-Extraction Theorem.** Suppose

$$
E(a,b,c;N)=0,
$$

with

$$
1<a<N.
$$

Then $a$ divides $N$, and it is a nontrivial divisor: $1<a<N$.

The zero-energy characterization gives $ab=N$. Therefore $N$ is an integer multiple of $a$, with multiplier $b$. The inequalities rule out the two trivial endpoints.

The smallest famous right triangle offers a concrete example. Since

$$
3^2+4^2=5^2
$$

and

$$
3\cdot4=12,
$$

we obtain

$$
E(3,4,5;12)=0.
$$

Because $1<3<12$, the first leg certifies the nontrivial divisibility statement $3\mid12$. The same point, viewed after swapping the legs, also exposes $4\mid12$. Geometry has packaged two factors into one right triangle.

## A perfectly curved spectrum

The most revealing behavior appears when the triple $(a,b,c)$ is fixed and the target $N$ varies. Then the geometric residual $a^2+b^2-c^2$ stays constant, while the arithmetic residual $ab-N$ moves along a parabola.

For any integer displacement $h$, the exact symmetric second difference is

$$
E(a,b,c;N+h)+E(a,b,c;N-h)-2E(a,b,c;N)=2h^2.
$$

This identity is the discrete counterpart of constant positive curvature. Expanding the two product residuals gives $(ab-N-h)^2$ and $(ab-N+h)^2$; their linear terms cancel, leaving exactly $2h^2$. The Pythagorean penalty appears equally in all three energies and cancels as well.

Several conclusions fall out at once.

**Strict-Convexity Theorem.** If $h\ne0$, then

$$
2E(a,b,c;N)<E(a,b,c;N-h)+E(a,b,c;N+h).
$$

Since $h\ne0$ implies $h^2>0$, the exact second difference is positive. The energy at the midpoint is strictly below the average total of the two symmetric neighbors. This is strict convexity stated directly on the integers, without pretending that the target must vary continuously.

For a unit step, the curvature is constant:

$$
E(a,b,c;N+1)+E(a,b,c;N-1)-2E(a,b,c;N)=2.
$$

Every fixed triple therefore has the same target-direction curvature, regardless of its size or shape. The triangle contributes a vertical offset; its leg product determines the horizontal center.

## The unique best target for a fixed triple

Fix any integer triple, whether Pythagorean or not. Which target makes it look most favorable? The answer is exact.

**Unique-Target Theorem.** For fixed integers $a,b,c$, the energy over integer targets has its unique minimum at $N=ab$. More precisely, for every integer $N$,

$$
E(a,b,c;ab)\le E(a,b,c;N),
$$

and equality holds if and only if $N=ab$.

At $N=ab$, the factorization penalty vanishes. For any other integer target, $(ab-N)^2$ is strictly positive, while the geometric penalty remains unchanged. Thus every triple carries its own preferred target—the product of its legs—and no other target ties it.

This theorem separates two roles in the energy. Changing $N$ asks which integer the legs naturally encode. Changing $(a,b,c)$ asks whether one can find a triple that both encodes the desired target and satisfies the right-triangle equation. Along the target axis the terrain is completely understood: it is a strict parabola. Across triples, the landscape inherits the rich arithmetic structure of Pythagorean triples.

## A tree of triangles

Primitive positive Pythagorean triples—those with positive entries and no common factor—can be organized in the Berggren tree. Starting from $(3,4,5)$, three integer linear transformations generate children, and every primitive positive Pythagorean triple appears exactly once in this branching structure. This makes the tree a natural search space for targets that are products of the legs of primitive triples.

The energy supplies a score for every vertex. Given $N$, one can evaluate how closely each triangle’s leg product approaches $N$; because every tree vertex is already Pythagorean, the first residual vanishes there, leaving

$$
E(a,b,c;N)=(ab-N)^2.
$$

On this restricted tree, energy is simply squared product error. A zero-energy vertex gives an exact product representation and, under the proper inequalities, a factor.

It is tempting to treat this score like a compass: compare a vertex with its parent and children, then move toward the least energy. But the established convexity concerns variation in $N$ for a fixed triple, not variation from vertex to vertex in the tree. Those are different directions through the landscape. A parabola in the target coordinate does not by itself guarantee that greedy motion through the tree avoids local traps.

That distinction is scientifically productive. The exact theorems provide a secure platform, while sharper search claims become concrete conjectures. Among them are the possibility that representable targets occur at logarithmic tree depth, that deterministic local descent always reaches a certificate for such targets, that the relevant subtree has no positive-energy local minima, and that the number of moves admits a polynomial bound in the bit length of $N$.

## What the bridge achieves

The energy construction does not erase the difficulty of integer factorization. Instead, it creates a precise bridge among three viewpoints:

1. **Geometry:** the equation $a^2+b^2=c^2$ describes integer right triangles.
2. **Arithmetic:** the equation $ab=N$ encodes a factorization.
3. **Optimization:** a sum of squared residuals turns simultaneous satisfaction into global energy minimization.

The bridge is exact at zero energy. There are no false positives: every zero obeys both equations. There are no missed certificates of the chosen form: every Pythagorean factor certificate has zero energy. The target spectrum has an exact second-difference law, strict discrete convexity, and a unique minimizer at the leg product.

These facts make the formula more than an analogy borrowed from physics. It is a rigorous certificate landscape. The landscape tells us exactly what success looks like, why success is globally optimal, how a proper factor is read from it, and how sharply each fixed triple selects its natural target.

The humble triangle $(3,4,5)$ already demonstrates the full mechanism for $12$. Beyond it stretches an infinite tree of primitive right triangles, each carrying the product of its legs and each defining a parabola over possible targets. Exploring how those parabolas interact with the tree may reveal when local motion can find global arithmetic structure. The terrain is now mapped along one crucial axis; the next challenge is learning how to navigate the forest.