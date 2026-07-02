# Arithmetic on a Curved Page: A Journey into the Hyperbolic Plane

## When the number line bends

Every schoolchild meets the number line: a perfectly straight, infinite ruler on which the integers march off to the horizon, evenly spaced, forever. It is such a familiar picture that we rarely ask whether it is the *only* picture. What would arithmetic look like if the page it was written on were curved — if the ruler itself bent away from us, so that "equal steps" no longer looked equal to an outside eye?

This is not idle fantasy. The geometry of curved spaces is the natural language of relativity, of networks that grow exponentially, of the deep symmetries that tie together number theory and the shape of space. And there is one curved space, above all others, where numbers feel most at home: the **hyperbolic plane**, and its most beautiful portrait, the **Poincaré disk**.

In the Poincaré disk, the entire infinite hyperbolic plane is squeezed inside a single round window. Distances stretch as you approach the rim: a creature living inside would need infinitely many steps to reach the edge, which is why the boundary circle is called the *circle at infinity*. Straight lines — the shortest paths, or *geodesics* — are not straight at all to our Euclidean eyes. They are arcs of circles that meet the boundary at right angles. It is a world that looks distorted from outside and perfectly uniform from within.

This article is about building the scaffolding for arithmetic on that curved page. We will meet a magic lens that turns a half-plane into a disk, a hidden group of symmetries that organizes the integers into orbits, a notion of "the point exactly halfway between two numbers" that behaves almost — but not quite — like ordinary averaging, and a mysterious quantity that stays perfectly fixed while everything around it moves. Each of these is a small, exact theorem, and together they sketch what it means to do number theory where primes might one day become geometric objects.

## The magic lens: the Cayley transform

The upper half-plane and the unit disk are two of the most popular canvases for hyperbolic geometry. The upper half-plane is simply all complex numbers $z = x + iy$ with positive imaginary part $y > 0$ — the region above the real axis. The unit disk is the set of complex numbers $w$ with $|w| < 1$ — the inside of a circle of radius one.

These two regions look nothing alike. One is unbounded, stretching up forever; the other is a tidy bounded circle. Yet from the standpoint of hyperbolic geometry they are *identical*, and the dictionary that translates between them is a single elegant formula, the **Cayley transform**:

$$C(z) = \frac{z - i}{z + i}.$$

Feed it any point in the upper half-plane, and out comes a point strictly inside the unit disk. This is the first exact fact we can state cleanly.

> **Theorem (the lens sends the half-plane into the disk).** If $z$ has positive imaginary part, then $|C(z)| < 1$.

The proof is a short computation that any reader can follow. Writing $z = x + iy$, the numerator $z - i$ and denominator $z + i$ differ only in whether we subtract or add $i$ to the imaginary part. The distance from $z$ to the point $i$ is always smaller than the distance from $z$ to the point $-i$ whenever $z$ sits *above* the real axis — because $i$ is above the axis and $-i$ is below it, and $z$ is on the same side as $i$. Since $|C(z)|$ is exactly the ratio of these two distances, it must be less than one. Geometry becomes algebra becomes a one-line inequality.

The lens also has a perfect inverse, which sends the disk back to the half-plane:

$$C^{-1}(w) = \frac{i\,(1 + w)}{1 - w}.$$

And these two really do undo each other. Apply the lens and then its inverse, and you return exactly where you started; apply them in the other order, and again nothing changes.

> **Theorem (the lens is reversible).** For every $z \neq -i$ we have $C^{-1}(C(z)) = z$, and for every $w \neq 1$ we have $C(C^{-1}(w)) = w$.

The two forbidden points — $z = -i$ and $w = 1$ — are exactly the places where a denominator would vanish, the single pole each map must avoid. Everywhere else, the correspondence is flawless. This is why mathematicians move freely between the two models, proving a fact in whichever one makes it easiest and carrying the conclusion across the lens.

## Hidden symmetries: the group $\Gamma(2)$

Arithmetic needs more than a stage; it needs *symmetries* — rigid motions of the space that respect its structure. On the hyperbolic plane these are the Möbius transformations coming from $2 \times 2$ integer matrices with determinant one, the group $\mathrm{SL}(2,\mathbb{Z})$. This "modular group" is the beating heart of classical number theory, and its subgroups tessellate the hyperbolic plane into infinitely many congruent tiles, like an Escher print come to life.

One especially clean subgroup is the **principal congruence subgroup of level two**, written $\Gamma(2)$. It consists of the integer matrices that reduce to the identity matrix modulo $2$ — the ones that look like the identity when you only keep track of whether each entry is even or odd. Two matrices generate a great deal of this group, and it is satisfying to confirm by hand that they belong to it:

$$T = \begin{pmatrix} 1 & 2 \\ 0 & 1 \end{pmatrix}, \qquad S = \begin{pmatrix} 1 & 0 \\ 2 & 1 \end{pmatrix}.$$

> **Theorem (the generators live in the group).** Both $T$ and $S$ belong to $\Gamma(2)$.

Each has determinant $1 \cdot 1 - 2 \cdot 0 = 1$, so they are genuine symmetries; and reducing modulo $2$, the off-diagonal $2$'s vanish and both become the identity, so they lie in the level-two congruence subgroup. $T$ is a *translation* — it slides the plane sideways by two units — and $S$ is its transpose, a translation seen through a mirror. Repeatedly applying these two motions and their inverses moves any starting tile onto infinitely many copies of itself.

This group action lets us define what it means for two integer vectors to be "the same number" from the hyperbolic point of view. Take two column vectors $v, w$ of integers. We declare them **related** if some symmetry $g$ in $\Gamma(2)$ carries one to the other: $g \cdot v = w$. This is the hyperbolic analogue of saying two points are equivalent because a rigid motion maps between them.

> **Theorem (orbits behave).** This relation is an equivalence relation: every vector is related to itself; if $v$ is related to $w$ then $w$ is related to $v$; and if $v$ is related to $w$ and $w$ to $u$, then $v$ is related to $u$.

The three properties mirror three facts about the group. Reflexivity uses the identity matrix, which fixes everything. Symmetry uses inverses: if $g$ carries $v$ to $w$, then $g^{-1}$ carries $w$ back to $v$, and inverses of $\Gamma(2)$ elements stay in $\Gamma(2)$. Transitivity uses composition: if $g_1$ takes $v$ to $w$ and $g_2$ takes $w$ to $u$, then the product $g_2 g_1$ takes $v$ straight to $u$, and products stay in the group. Because these motions form a group, their orbits neatly partition the integer lattice into disjoint families — the "hyperbolic integers" grouped by symmetry.

## Grains of sand that never crowd: discreteness

For any of this to deserve the name *number theory*, the points must be **discrete** — spread out, never piling up. On the ordinary number line this is obvious: integers are a unit apart. In the plane, we need a guarantee that no bounded region can trap infinitely many lattice points. That guarantee is exact.

> **Theorem (finiteness in every ball).** Fix any center $c = (c_1, c_2)$ and any radius $R$. The set of integer points $(m, n)$ satisfying $(m - c_1)^2 + (n - c_2)^2 < R^2$ is finite.

The reasoning is delightfully down-to-earth. If a point lies inside the ball, then each of its coordinates is trapped in an interval of finite length — roughly from $c_1 - R$ to $c_1 + R$ in the first coordinate, and similarly in the second. An interval of finite length contains only finitely many integers, so there are finitely many choices for the first coordinate and finitely many for the second, hence finitely many points overall. The lattice is grainy, not soupy: zoom into any finite window and you find a finite, countable scattering of points. This discreteness is precisely what lets us imagine "counting primes in a disk" — the very question that motivates a hyperbolic prime number theorem.

## Meeting in the middle: the hyperbolic midpoint

Now to arithmetic proper. What does it mean to *average* two numbers on a curved page? On the imaginary axis of the upper half-plane — the vertical line of points $i\,s$ with $s > 0$ — hyperbolic distance has a beautifully simple form. The hyperbolic distance between $i\,a$ and $i\,b$ is

$$d(a, b) = \bigl|\log(a / b)\bigr|.$$

Distances are measured *logarithmically*: to a hyperbolic creature, the gap between heights $1$ and $2$ feels the same as the gap between $10$ and $20$, because both are a factor of two. This single change — replacing subtraction by ratio — transforms the entire flavor of the geometry.

And it immediately tells us what the midpoint should be. The point exactly halfway between $i\,s$ and $i\,t$ is not their ordinary average $(s+t)/2$; it is their **geometric mean**:

$$m(s, t) = \sqrt{s\,t}.$$

This is exactly right, and we can prove it stays equally far from both ends.

> **Theorem (the midpoint is equidistant).** For positive $s$ and $t$, the hyperbolic distance from $s$ to $\sqrt{s t}$ equals the hyperbolic distance from $\sqrt{s t}$ to $t$.

Indeed both distances equal $\tfrac{1}{2}\bigl|\log(s/t)\bigr|$, because $\log(s / \sqrt{st}) = \tfrac12\log(s/t)$ and $\log(\sqrt{st}/t) = \tfrac12\log(s/t)$. The geometric mean splits the logarithmic gap perfectly in half.

This midpoint operation is charming and well-behaved in almost every way. It is **commutative** — $m(s,t) = m(t,s)$, since multiplication does not care about order. It is **idempotent** — the midpoint of a point with itself is itself, $m(s,s) = s$, because $\sqrt{s \cdot s} = s$. These are exactly the laws we expect of any honest notion of "the point in between."

But there is a twist, and it is the most revealing fact of all. The hyperbolic midpoint is **not associative**.

> **Theorem (associativity fails).** There exist positive numbers $s, t, u$ with $m(m(s,t),u) \neq m(s,m(t,u))$.

A concrete witness settles it: take $s = 1$, $t = 1$, $u = 16$. Then $m(m(1,1),16) = m(1,16) = \sqrt{16} = 4$, while $m(1, m(1,16)) = m(1, 4) = \sqrt{4} = 2$. Four is not two. The order in which you take midpoints changes the answer. This failure is not a defect; it is a signpost. It tells us that "hyperbolic averaging" is genuinely a *geometric* operation, sensitive to the shape of the space, and not a disguised copy of ordinary addition. Curvature leaves a fingerprint, and here it is.

## The quantity that refuses to move: the cross-ratio

If symmetries move points around, is there anything they *cannot* change? On a curved page there is one deep invariant, known since the days of projective geometry: the **cross-ratio** of four points,

$$(z_1, z_2; z_3, z_4) = \frac{(z_1 - z_3)(z_2 - z_4)}{(z_1 - z_4)(z_2 - z_3)}.$$

The cross-ratio measures a kind of "relative configuration" of four points that survives any Möbius transformation — any map of the form $z \mapsto (az+b)/(cz+d)$ with $ad - bc \neq 0$. These are exactly the rigid motions and conformal symmetries of the hyperbolic plane, and the cross-ratio is the fossil that they all leave untouched.

> **Theorem (cross-ratio invariance).** For any Möbius transformation $\mu(z) = (az+b)/(cz+d)$ with nonzero determinant $ad - bc$, the cross-ratio of $\mu(z_1), \mu(z_2), \mu(z_3), \mu(z_4)$ equals the cross-ratio of $z_1, z_2, z_3, z_4$.

The mechanism behind the invariance is a small miracle of cancellation. When you compute a difference $\mu(z_i) - \mu(z_j)$, the two fractions combine over a common denominator, and the numerator collapses to $(ad - bc)(z_i - z_j)$ divided by the product of the two denominators $(cz_i + d)(cz_j + d)$. So *every* difference in the cross-ratio picks up the same determinant factor and a pair of denominator factors. In the ratio of four such differences, the determinant factors cancel in a block, and the denominator factors pair off and cancel one against another, leaving exactly the original cross-ratio. What looked like it should scramble the four points instead preserves their configuration perfectly.

The cross-ratio is, in a sense, the "true coordinate" of hyperbolic geometry — the thing that means the same to every observer, no matter how they slide, rotate, or reflect the curved page. It is the anchor that makes it possible to speak of hyperbolic distance and hyperbolic angle at all.

## Why this matters

Each theorem here is modest on its own — a lens, a pair of matrices, an equivalence relation, a finiteness count, a stubbornly non-associative average, an unbreakable ratio. But laid side by side they form the first floor of an audacious building: **number theory on a curved space**. The lens gives us two interchangeable stages. The group gives us symmetries and orbits, the raw material for defining "hyperbolic integers." Discreteness ensures those integers are countable and spread out, so that counting them in a disk is a meaningful question. The midpoint shows how arithmetic operations acquire a geometric personality once the page bends. And the cross-ratio provides the fixed reference against which all of it is measured.

The grand dream behind this program is spectacular: to reimagine prime numbers as *geometric objects* — vertices of a tessellation, corners where the tiles of the hyperbolic plane meet — and to ask whether the deepest questions of number theory take on a new, perhaps more tractable, shape in this curved setting. Where the ordinary primes are scattered mysteriously along a straight line, the hyperbolic primes would sit at the joints of a crystalline pattern, their distribution governed by the geometry of the tiling itself.

That dream is not yet realized, and honesty compels us to say so. But every cathedral begins with surveyed ground and a few load-bearing stones set exactly true. The results assembled here are those first true stones: small, exact, and each one carrying weight. On a curved page, arithmetic looks strange at first — averages become geometric means, distances become logarithms, straight lines become arcs. And yet, once your eyes adjust, it looks like it was always meant to be written there.
