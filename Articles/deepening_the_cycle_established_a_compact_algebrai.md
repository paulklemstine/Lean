# The Fourth Dimension, Hiding in a Single Identity

## A puzzle you already know

Take any two numbers, add them, and square the result. Now do something that
looks like a detour: multiply the two numbers together, quadruple that, and add
the square of their *difference*. You get the same answer. In symbols,

$$(a+b)^2 = 4ab + (a-b)^2.$$

This is the kind of identity that shows up in a middle-school algebra class and
then, apparently, never again. It is true, it is easy, and it seems to say
almost nothing. Yet if you follow it patiently, this one line turns out to be a
skeleton key. It unlocks the geometry of the fourth dimension: the way circles
can be woven through a three-dimensional sphere without ever crossing, the way a
flat doughnut can live inside a curved four-dimensional world, and the algebra
behind the rotations that engineers and computer-graphics programmers use every
day. This is the story of how far one humble identity can be pushed.

## From one identity to a family

The first clue that $(a+b)^2 = 4ab + (a-b)^2$ is more than a curiosity is that it
has bigger siblings. The identity is really a statement about *sums of squares*,
and sums of squares have a magical property: multiply two of them together, and
you get another one.

The two-square version is ancient, known to Brahmagupta in seventh-century India
and to Fibonacci in medieval Europe:

$$(a^2+b^2)(c^2+d^2) = (ac-bd)^2 + (ad+bc)^2.$$

Try it with $a^2+b^2 = 5$ (from $1^2+2^2$) and $c^2+d^2 = 5$ again: the product
$25$ reappears as $(1\cdot1-2\cdot2)^2 + (1\cdot2+2\cdot1)^2 = (-3)^2+4^2 = 9+16$.
The reason this works is not luck. If you think of $a^2+b^2$ as the squared
length of a complex number $a+bi$, the identity is just the statement that
lengths multiply: $|z_1 z_2| = |z_1|\,|z_2|$. The algebra of two squares *is* the
algebra of the plane.

The astonishing fact is that the same trick works with *four* squares. Euler
discovered that

$$(a_1^2+a_2^2+a_3^2+a_4^2)(b_1^2+b_2^2+b_3^2+b_4^2)$$

is again a sum of four squares, through a formula that looks intimidating but is
verified by a single expansion. This four-square identity is the multiplicativity
of length for *quaternions* — four-dimensional numbers invented by William Rowan
Hamilton in 1843, so momentous to him that he carved the defining rule into a
Dublin bridge. Between the two lives the three-variable **Lagrange identity**,

$$(a_1^2+a_2^2+a_3^2)(b_1^2+b_2^2+b_3^2) - (a_1b_1+a_2b_2+a_3b_3)^2$$
$$= (a_1b_2-a_2b_1)^2 + (a_1b_3-a_3b_1)^2 + (a_2b_3-a_3b_2)^2,$$

whose right-hand side is a sum of squares and therefore never negative. Reading
that fact backwards gives the celebrated **Cauchy–Schwarz inequality** in three
dimensions: the dot product of two vectors can never exceed the product of their
lengths. A famous inequality, hiding inside a bare algebraic identity.

So the single sum-of-squares idea grows into a ladder: two squares for the plane,
four squares for four-dimensional space, and the three-variable identity linking
them. Each rung is the arithmetic of a number system — real, complex,
quaternionic — where length behaves multiplicatively. These are the **composition
algebras**, and they are the true subject of our story.

## Weaving circles through a sphere

Now for the geometry. Picture the ordinary sphere — the surface of a ball — but
one dimension up: the **three-sphere**, the set of points in four-dimensional
space at distance one from the origin. It is a closed, curved, three-dimensional
world. In 1931 Heinz Hopf discovered something about it that still feels like a
magic trick: you can fill the entire three-sphere with circles, one through every
point, so that no two circles ever touch, and yet *every pair of circles is
linked*, like every ring in an infinite chain-mail.

The bookkeeping device that makes this precise is the **Hopf map**. Think of a
point of the three-sphere as a pair of complex numbers $(z, w)$ with
$|z|^2 + |w|^2 = 1$. The Hopf map sends it to

$$(z, w) \longmapsto \big(2z\bar{w},\; |z|^2 - |w|^2\big),$$

a point living in three-dimensional space (one complex number, worth two real
coordinates, plus one real number). And here the opening identity returns, doing
real work: the output always lands exactly on an ordinary sphere, because

$$\big|2z\bar w\big|^2 + \big(|z|^2-|w|^2\big)^2 = \big(|z|^2+|w|^2\big)^2$$

is nothing but $(a+b)^2 = 4ab + (a-b)^2$ with $a=|z|^2$ and $b=|w|^2$. The
three-sphere maps *onto* an ordinary two-sphere.

The interesting question is: which points get mapped to the *same* place? Those
points form the fibres — the circles of Hopf's chain-mail. There are two things
to prove, and they have completely different personalities.

The **easy direction** is a symmetry. If you rotate both coordinates by the same
unit-length complex number $\lambda$ (so $|\lambda|=1$), sending $(z,w)$ to
$(\lambda z, \lambda w)$, the Hopf image does not change at all. The phase
$\lambda$ washes out. So the whole circle of rotations $\{(\lambda z, \lambda w) :
|\lambda|=1\}$ sits inside a single fibre. That is why the fibres are circles.

The **hard direction** — the deep result of this work — is the converse, a
statement of *rigidity*. Suppose two points $(z,w)$ and $(z',w')$, both on the
three-sphere, happen to land on the same spot under the Hopf map. Must they be
related by such a rotation? The answer is yes, and the proof is a small gem. The
missing rotation is not found by trial; it is written down explicitly as

$$\lambda = \bar z\,z' + \bar w\,w',$$

which is exactly the **Hermitian inner product** of the two unit vectors — the
four-dimensional generalization of "the angle between them." One checks, by two
short algebraic computations, that this $\lambda$ genuinely carries $(z,w)$ to
$(z',w')$, and then that $|\lambda|^2 = 1$, using the fact that length is
multiplicative — our composition-algebra magic once more. Combining the two
directions gives a clean and complete description:

> **The fibres of the Hopf map are exactly the great circles.** Two points of the
> unit three-sphere have the same Hopf image if and only if one is obtained from
> the other by multiplying both coordinates by a single unit complex number.

This is the sharp form of Hopf's picture. The extra unit number $\lambda$ is a
"phase" with no geometric meaning of its own, and the Hopf map is precisely the
act of forgetting it. Modern physics calls exactly this structure a *gauge
symmetry*; the two-sphere at the bottom is the space of genuinely distinct
states, and the circle above each point is the redundancy. The same mathematical
object appears in the quantum mechanics of a single spin and in the theory of
magnetic monopoles.

## Rotating through the fourth dimension

There is a second face of four-dimensional geometry that the identity illuminates:
motion. In the plane, multiplying by the imaginary unit $i$ rotates everything a
quarter turn. What does that quarter turn become in higher dimensions?

Bundle $n$ complex numbers into a single vector, which is the same as a
$2n$-dimensional real space, and multiply *every* coordinate by $i$. Call this
operation $J$. Three facts, true in every dimension at once, capture what "the
rotation through the fourth dimension" really means:

- **It squares to a reflection through the origin.** Doing $J$ twice negates
  everything: $J^2 = -\mathrm{Id}$, because $i^2 = -1$. This is the defining
  property of a *complex structure*.
- **It preserves length.** Multiplying by $i$ never changes the size of a complex
  number, so $J$ leaves the total squared length untouched. It is a rigid motion,
  a genuine rotation.
- **It has no axis.** An ordinary rotation of three-dimensional space always
  pins down an axis — a line it leaves fixed. The operation $J$ has none: on the
  unit sphere, $J$ moves *every single point*. The proof is a one-line
  observation, that $J$ could only fix a nonzero vector if $i = 1$, which it is
  not.

That last property is what makes $J$ feel four-dimensional. A rotation of a plane
inside three-dimensional space always leaves the perpendicular axis alone; there
is nowhere to hide from a rotation only when you have a fourth dimension to rotate
*into*. The operation $J$ is the purest algebraic embodiment of that freedom.

## Balanced doughnuts and the shape of rotations

Finally, the identity governs an optimization problem with a pleasing answer.
Inside the three-sphere lives a family of flat doughnut surfaces — **Clifford
tori** — described by two radii whose squares sum to one, say $a + b = 1$. The
area of such a torus is controlled by the product $4ab$, and our founding identity
says $4ab = 1 - (a-b)^2$. Since the subtracted term is a square and hence never
negative, the product is largest — and the doughnut fattest — exactly when the two
radii are equal, $a = b = \tfrac12$. Balance is best.

This is not a coincidence of two dimensions; it is the arithmetic–geometric mean
inequality wearing a geometric costume. Push to three radii with $a+b+c=1$, and
the product $abc$ can never exceed $\tfrac{1}{27}$, with equality precisely at the
perfectly balanced $a=b=c=\tfrac13$. The balanced torus is the roundest, roomiest
one, in every dimension.

And the rotations themselves? Quaternions supply them. If $q$ is any nonzero
quaternion, the operation $x \mapsto q\,x\,q^{-1}$ — "conjugation by $q$" —
preserves the length of every quaternion $x$. That single fact, whose proof is
again the multiplicativity of length, is the engine behind the rotation groups
$SO(3)$ and $SO(4)$. It is the reason spacecraft, robot arms, and video-game
cameras track their orientation with quaternions rather than clumsier machinery:
the arithmetic is exact, compact, and never drifts.

## The moral

Where does the ladder end? A theorem of Adolf Hurwitz says it stops abruptly.
Sums of squares multiply like this only in dimensions $1, 2, 4,$ and $8$ — the
real numbers, the complex numbers, the quaternions, and the eight-dimensional
octonions. There is no bilinear three-square identity, no five-square identity;
the gaps are a genuine feature of the mathematical universe, not a failure of
imagination. The fourth dimension is special because four is one of the
privileged rungs.

So the next time $(a+b)^2 = 4ab + (a-b)^2$ scrolls past in an algebra exercise,
remember what it conceals. Inside that unremarkable line are the linked circles of
the Hopf fibration, the axis-free rotations of higher space, the fattest doughnut
on the sphere, and the quaternion arithmetic steering machines through
three-dimensional motion. One identity, four dimensions, and a surprising amount
of the geometry of our world.
