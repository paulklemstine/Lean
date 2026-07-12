# The Fourth Dimension, Assembled From a Single Square

Mathematicians have long treated the fourth dimension as a place of wonder and
menace — the home of shapes that cannot exist in our world, of rotations with no
axis, of spheres that fit inside one another in impossible ways. What is less
often said is how *simple* the machinery behind these marvels can be. This article
tells the story of a small algebraic identity — the kind of thing you could scribble
on a napkin — and shows how it quietly powers four of the most beautiful objects in
four-dimensional geometry.

## One identity to rule them all

Start with the humblest possible statement. For any two numbers $a$ and $b$,

$$(a+b)^2 = 4ab + (a-b)^2.$$

You can check it in a second: expand both sides and watch them collapse into the
same thing, $a^2 + 2ab + b^2$. It looks like the sort of formula you memorize for a
test and forget forever. But rewrite it slightly and it starts to whisper. It says
that a **product** ($4ab$) and a **squared difference** ($(a-b)^2$) always add up to
a fixed **squared sum** ($(a+b)^2$). Products, differences, and sums of squares are
exactly the ingredients from which four-dimensional geometry is built. Once you see
this, the identity stops being a triviality and becomes a master key.

Below we turn that key in four different locks.

## Lock one: rotating through the fourth dimension

In three dimensions, every rotation has an axis — a line of points that stay put
while everything spins around them. Stand on the Earth's pole and the world turns
beneath you while you hold still. This is not an accident; it is a theorem about odd
numbers. Any rotation of an odd-dimensional space must fix at least one direction.

Four is even, and here something new becomes possible: a rotation with **no fixed
direction at all**, a motion in which *every* point moves. Concretely, take the map

$$J(x_1,x_2,x_3,x_4) = (-x_2,\, x_1,\, -x_4,\, x_3).$$

It performs a quarter-turn in the $(x_1,x_2)$-plane and a simultaneous quarter-turn
in the $(x_3,x_4)$-plane. Three facts make it special.

First, applying it twice sends every vector to its negative:

$$J(J(x)) = (-x_1,-x_2,-x_3,-x_4) = -x.$$

In the language of algebra, $J^2 = -I$. This is exactly the property of the
imaginary unit $i$, whose square is $-1$; $J$ is a geometric incarnation of $i$
acting on four real dimensions. Structures like this — squaring to minus the
identity — are called **complex structures**, and they are the bridge between real
four-dimensional space and the complex plane doubled up on itself.

Second, $J$ preserves length. The squared distance of a point from the origin,
$x_1^2 + x_2^2 + x_3^2 + x_4^2$, is unchanged after applying $J$, because reordering
and negating coordinates just shuffles the squares around. So $J$ is a rigid motion:
it never stretches or shrinks.

Third — and this is the payoff — $J$ has no fixed point except the origin. Suppose
$J(x) = x$. Comparing coordinates forces $-x_2 = x_1$ and $x_1 = x_2$, which together
give $x_1 = x_2 = 0$; the same reasoning kills $x_3$ and $x_4$. The only solution is
the origin. Restricted to the sphere of all points at distance one, $J$ therefore
moves **everything**. It is the honest "rotation through the fourth dimension," a
motion with no still center — the sort of thing that is simply impossible one
dimension down.

## Lock two: the sphere that fibers into circles

Now comes one of the crown jewels of twentieth-century geometry: the **Hopf map**.
Picture the three-dimensional sphere — not the familiar surface of a ball, but its
four-dimensional analogue, the set of points at distance one in $\mathbb{R}^4$. The
Hopf map takes this three-sphere and projects it down onto an ordinary
two-dimensional sphere, the surface of a ball you could hold in your hand.

The magic is in the *fibers*. Every single point of the ordinary sphere is the
shadow of an entire **circle** sitting in the three-sphere, and any two of these
circles are linked like adjacent rings in a chain — you cannot pull them apart
without breaking one. The three-sphere is woven entirely out of interlocking
circles, one for each point of a two-sphere.

To write the map down, identify $\mathbb{R}^4$ with pairs of complex numbers
$(z,w)$. The Hopf map is

$$H(z,w) = \bigl(2 z \overline{w},\ |z|^2 - |w|^2\bigr),$$

landing in the product of the complex plane with the real line — a
three-dimensional target. Two facts pin down its structure.

The circles come from a symmetry. If $\lambda$ is any complex number of absolute
value one, then multiplying **both** coordinates by $\lambda$ leaves the Hopf image
completely unchanged:

$$H(\lambda z, \lambda w) = H(z,w).$$

The reason is a clean cancellation: in the first coordinate the factor $\lambda$ from
$z$ meets the factor $\overline{\lambda}$ from $\overline{w}$, and $\lambda\overline{\lambda}
= |\lambda|^2 = 1$ wipes them both out; in the second coordinate $|\lambda z|^2 =
|\lambda|^2|z|^2 = |z|^2$. The orbit of a point $(z,w)$ under all these unit-modulus
multiplications is precisely a circle — and it is exactly one Hopf fiber. This
circle action is nothing but our map $J$ in disguise, since multiplication by
$\lambda = i$ *is* the quarter-turn $J$.

And where does the image live? A short computation shows

$$|2z\overline{w}|^2 + \bigl(|z|^2 - |w|^2\bigr)^2 = \bigl(|z|^2 + |w|^2\bigr)^2.$$

Look closely: with $a = |z|^2$ and $b = |w|^2$, this reads $4ab + (a-b)^2 = (a+b)^2$
— our napkin identity, verbatim. It tells us the Hopf image sits on a sphere whose
radius is $|z|^2 + |w|^2$. On the unit three-sphere, where $|z|^2 + |w|^2 = 1$, the
image lands exactly on the unit two-sphere. The single most famous fibration in
geometry is, at its algebraic heart, the identity $(a+b)^2 = 4ab + (a-b)^2$.

## Lock three: the perfectly balanced torus

Inside the three-sphere lives a surface of extraordinary elegance: the **Clifford
torus**. A torus is the shape of a doughnut, and normally we think of it as bent and
curved. But sitting inside the three-sphere, this particular torus is completely
**flat** — an inhabitant of it would find, to their surprise, that the angles of
every triangle sum to exactly $180^\circ$, as if they lived on an infinite plane.

Build it from two circles. Choose radii $r_1$ and $r_2$ and sweep out the surface

$$(\theta, \varphi) \mapsto (r_1\cos\theta,\ r_1\sin\theta,\ r_2\cos\varphi,\ r_2\sin\varphi).$$

For this to lie on the unit three-sphere we need $r_1^2 + r_2^2 = 1$. Which choice
of radii is best? The area of the torus turns out to be governed by the product
$4 r_1^2 r_2^2$. Setting $a = r_1^2$ and $b = r_2^2$, so that $a + b = 1$, our
identity delivers the answer immediately:

$$4ab = 1 - (a-b)^2.$$

A squared quantity is never negative, so $4ab$ can be at most $1$, and it *reaches*
$1$ precisely when $a = b$ — that is, when $r_1^2 = r_2^2 = \tfrac12$, the balanced
"square" torus with equal radii $r_1 = r_2 = 1/\sqrt{2}$. This is the Clifford
torus. The identity does not merely suggest the answer; it proves that balance is
optimal and that balance is *unique*: if $4ab = 1$ then $(a-b)^2 = 0$, forcing
$a = b$. The most symmetric torus is the only extremal one.

## Lock four: the volume of the four-ball and the skin of the three-sphere

Every child learns that a circle of radius $r$ has area $\pi r^2$ and a ball has
volume $\tfrac{4}{3}\pi r^3$. The pattern continues upward. The
four-dimensional ball of radius $r$ has volume

$$V(r) = \frac{\pi^2}{2}\, r^4.$$

There is a beautiful relationship hiding here, the same one that connects a circle's
area to its circumference. Differentiate the volume with respect to the radius:

$$V'(r) = 2\pi^2 r^3.$$

That derivative is exactly the three-dimensional "surface measure" of the
three-sphere bounding the ball — the higher-dimensional analogue of how the
derivative of $\pi r^2$ is the circumference $2\pi r$. Growing the ball by a sliver
of radius adds a shell whose size is precisely the boundary's measure. The constants
$\pi^2/2$ for volume and $2\pi^2$ for surface are locked together by a single
derivative, a small window onto the isoperimetric harmony of four-dimensional space.

## An unexpected guest: counting the faces of a cube

The continuous story above has a discrete twin. Consider the ordinary cube and its
higher-dimensional cousins, the **hypercubes**. An $n$-dimensional cube has
$2^n$ corners, and more generally a certain number of faces of each dimension — for
the familiar $3$-cube, $8$ vertices, $12$ edges, $6$ square faces, and $1$ solid
interior. There is a classical way to package this bookkeeping into a single
**alternating sum**, and for the $n$-cube it evaluates, remarkably, to exactly one:

$$\sum_{k=0}^{n} (-1)^k \binom{n}{k}\, 2^{\,n-k} = 1.$$

This is nothing more than the binomial theorem in costume: it is the expansion of
$(2-1)^n = 1^n = 1$. From it one reads off the **Euler characteristic** of the
cube's boundary — the alternating count of vertices minus edges plus faces and so
on across the *surface* of the cube. Removing the single top-dimensional cell from
the total leaves

$$\chi = 1 - (-1)^n.$$

For even $n$ this is $0$; for odd $n$ it is $2$. And this is exactly right: the
boundary of an $n$-cube is a topological $(n-1)$-sphere, and spheres of even
dimension have Euler characteristic $2$ while odd-dimensional spheres have $0$. A
fact about the shape of space falls out of a schoolbook algebra identity.

## Why this matters

None of the four constructions — the fixed-point-free rotation, the Hopf fibration,
the Clifford torus, the volume–surface law — was invented here. Each is a landmark.
What the story reveals is that they share a spine. The continuous four are shadows
of one sum-of-squares identity, and the combinatorial companion is a shadow of the
binomial theorem. The fourth dimension, so often painted as alien, turns out to
speak a language we learned in grade school.

This vantage point is also generative. It suggests, for example, that the
fixed-point-free rotation $J$ is the *canonical* such motion in every even
dimension — a quarter-turn in each coordinate plane, always squaring to $-I$,
always moving every point of the odd sphere it acts on. It suggests that the
balanced Clifford torus is the first case of a whole family of perfectly symmetric
flat tori, one in each odd sphere, singled out by the same "no squared deviation"
principle. It suggests that the cube's Euler-characteristic identity is a rigid
topological fact, immune to the fine combinatorial details of *which* polytope you
draw. And it suggests that the volume constant $\pi^2/2$ is the extremal value in a
sharp four-dimensional isoperimetric law, the precise number that makes the ball the
undisputed champion of enclosing volume.

Big theorems are often imagined as towering and remote. Sometimes, though, if you
tilt them into the light, you find them resting on a single square.
