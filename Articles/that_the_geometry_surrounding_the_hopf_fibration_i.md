# The Fourth Dimension, Braided by Algebra

Take a sphere. Not the two-dimensional surface of a beach ball, but the
three-dimensional sphere $S^3$ — the set of all points at unit distance from the
origin in four-dimensional space. It is hard to picture, but it is the most
important geometric object you have never seen, and it hides one of the most
beautiful facts in mathematics: it can be combed. Every strand is a perfect
circle, no two strands ever cross, and yet the whole tangle wraps up neatly into
an ordinary two-dimensional sphere. This is the **Hopf fibration**, discovered by
Heinz Hopf in 1931, and it is the reason topologists first understood that the
"holes" of higher-dimensional spaces can be far stranger than the holes of a
donut.

What makes the Hopf fibration tick? For decades the honest answer was: *number
systems*. Not the plain real numbers of the number line, but their exotic
higher-dimensional cousins — the complex numbers in dimension two, the
quaternions in dimension four, the octonions in dimension eight. These are the
only four **composition algebras**: number systems where you can add, subtract,
multiply, divide, *and* where the length of a product is the product of the
lengths. That last property, multiplicativity of length, is the secret engine of
the Hopf story. This article assembles five precise results that show, step by
step, exactly how a single algebraic gadget — the inner product of two unit
vectors — organizes the entire geometry.

## Combing the three-sphere with a single number

Picture $S^3$ as living inside $\mathbb{C}^2$, the space of pairs of complex
numbers $(z, w)$ with $|z|^2 + |w|^2 = 1$. The Hopf map sends such a pair to a
point of the ordinary sphere $S^2$, and the *fibre* over each point of $S^2$ is a
circle. Two points $a = (z, w)$ and $b = (z', w')$ sit on the **same circle**
exactly when one is a complex multiple of the other: $b = \mu\, a$ for some
complex number $\mu$ of absolute value one — a pure phase, a rotation.

Here is the first result, and it is almost magical in its economy. Form the
single complex number
$$\lambda = \overline{z}\,z' + \overline{w}\,w',$$
the **Hermitian inner product** of the two unit vectors. This one number knows
everything about whether $a$ and $b$ share a fibre. Concretely, an exact identity
holds for *any* two unit vectors:
$$\lVert z' - \lambda z\rVert^2 + \lVert w' - \lambda w\rVert^2 = 1 - |\lambda|^2.$$
The left-hand side measures how far $b$ is from the "shadow" of $a$ scaled by
$\lambda$; the right-hand side is a pure number built from $\lambda$ alone. Two
consequences fall out immediately. First, because the left side can never be
negative, $|\lambda| \le 1$ always — this is the Cauchy–Schwarz inequality,
recovered for free. Second, and this is the punchline, **if $|\lambda| = 1$ then
the left side is zero**, which forces $z' = \lambda z$ and $w' = \lambda w$. In
other words:

> **Fibre reconstruction.** If the inner-product witness of two unit vectors has
> absolute value one, the second vector is exactly $\lambda$ times the first.
> They lie on a common Hopf circle, and $\lambda$ is the precise phase that
> carries one to the other.

So a single complex number both *detects* the fibre and *reconstructs* it. The
whole circular fibre structure of the four-dimensional sphere is encoded in one
algebraic expression. This is the complex base case of a conjectural ladder that
should climb through the quaternions to the octonions — each rung built from the
same skeleton of bilinear identities.

## Rotating through the fourth dimension

If you want to spin a sphere, you need a rule that moves every point yet leaves
none fixed. On an ordinary globe this is impossible: any rotation pins down two
poles. On the two-sphere you cannot comb the hair flat without a cowlick — the
"hairy ball theorem." But odd-dimensional spheres are different, and the
composition algebras tell us exactly why.

Regard $\mathbb{C}^n$ as $2n$ real dimensions and consider the map that simply
multiplies every coordinate by $i$:
$$J(v) = i\,v.$$
This is "rotation through the fourth dimension" in its purest form. Three facts
make it remarkable, and all three are elementary once stated correctly:

- **It is a complex structure:** applying it twice gives $J(J(v)) = i^2 v = -v$,
  so $J^2 = -1$. It behaves like a square root of minus one, promoted from a
  number to a geometric operation.
- **It is an isometry:** since $|i\,v_k| = |v_k|$ for each coordinate, $J$
  preserves the Euclidean length. It maps the unit sphere $S^{2n-1}$ to itself.
- **It is fixed-point free:** if $J(v) = v$ then $i\,v_k = v_k$ for every
  coordinate, i.e. $(i - 1)v_k = 0$; but $i - 1 \ne 0$, so every $v_k = 0$. No
  point of the sphere is left fixed.

That last argument distills the whole phenomenon into one scalar fact:
$i - 1 \neq 0$. The existence of a fixed-point-free rotation of $S^{2n-1}$ — the
reason odd-dimensional spheres can be "combed" — reduces to the observation that
$i$ is genuinely different from $1$. It is conjectured that this is essentially
the *only* algebraic complex structure available: every fixed-point-free isometry
of order dividing four is, after a change of coordinates, multiplication by $i$.

## Why the ladder stops at four (before leaping to eight)

The complex numbers give length-multiplicative multiplication in dimension two;
the quaternions do it in dimension four. Both facts can be written as pure
algebraic identities. The **two-square identity** of Brahmagupta and Fibonacci,
$$(a_1^2 + a_2^2)(b_1^2 + b_2^2) = (a_1 b_1 - a_2 b_2)^2 + (a_1 b_2 + a_2 b_1)^2,$$
says the product of two sums of two squares is again a sum of two squares — this
*is* the statement that complex multiplication multiplies lengths. One dimension
of number system up, **Euler's four-square identity**,
$$
(a_1^2 + a_2^2 + a_3^2 + a_4^2)(b_1^2 + b_2^2 + b_3^2 + b_4^2)
= c_1^2 + c_2^2 + c_3^2 + c_4^2,
$$
with the four $c$'s built bilinearly from the $a$'s and $b$'s exactly as
quaternion multiplication prescribes, does the same in dimension four.

A natural question: is there a three-square identity? A five-, six-, or
seven-square one? The astonishing classical answer is **no** — such bilinear
identities exist only in dimensions $1, 2, 4$, and $8$. Here is the clean reason
for the odd cases. A length-multiplicative bilinear product on $\mathbb{R}^d$
would make $\mathbb{R}^d$ a composition algebra, and multiplication by an
imaginary unit would then be a linear map $J$ with $J^2 = -1$ — a complex
structure, just like the "rotation through the fourth dimension" above. But now
take determinants:
$$(\det J)^2 = \det(J^2) = \det(-I) = (-1)^d.$$
When $d$ is odd this reads $(\det J)^2 = -1$, which no real number can satisfy.
So **no odd dimension greater than one admits a composition identity** — in
particular there is no three-square, five-square, or seven-square identity. It is
the same $J^2 = -1$ obstruction as before, promoted one dimension: multiplication
by $i$ *exists* in even dimension, and is *forbidden* in odd dimension, by a
single determinant.

## The roundest doughnut on the sphere

Composition algebras also govern a crisp geometric optimization. Sitting inside
the odd sphere $S^{2m-1} \subset \mathbb{C}^m$ are **flat tori**: products of $m$
circles of radii $r_1, \dots, r_m$, constrained so that
$r_1^2 + \dots + r_m^2 = 1$. Each such torus is a smooth, flat, $m$-dimensional
surface, and it has a volume proportional to the product of the radii,
$r_1 r_2 \cdots r_m$. Which choice of radii gives the *biggest* torus?

Intuition says balance them, and intuition is exactly right. The arithmetic–
geometric mean inequality gives, for any nonnegative numbers summing to one,
$$\prod_{i=1}^m r_i^2 \le \left(\tfrac{1}{m}\right)^m,$$
with equality **if and only if** every $r_i^2 = 1/m$. Taking square roots turns
this into a clean statement about volume:
$$\prod_{i=1}^m r_i \le m^{-m/2},$$
and the maximum is attained by, and only by, the **balanced torus** with all
radii equal to $1/\sqrt{m}$. The "roundest doughnut" on every odd sphere is the
perfectly symmetric one, and its volume shrinks like $m^{-m/2}$ as the dimension
grows. What is striking is that a single inequality settles the problem in *every*
dimension at once — no case analysis, no dimension-by-dimension miracle.

## Rigid twists and the double cover

The final piece returns to the quaternions and to the most classical of all
symmetries: rotation. Given a nonzero quaternion $q$, form the **conjugation map**
$$x \mapsto q\,x\,q^{-1}.$$
This twist has a rigidity property that is the workhorse behind the theory of
rotations. It **preserves the norm of every quaternion $x$** — and, crucially, it
does so for *every* nonzero $q$, not merely for the unit-length ones. The reason
is the multiplicativity of the quaternionic norm: the $q$ and the $q^{-1}$
contribute reciprocal factors that exactly cancel. The same map is
multiplicative, $q(xy)q^{-1} = (qxq^{-1})(qyq^{-1})$, so it is an *automorphism*
of the quaternions, and it fixes the real axis, $q\,c\,q^{-1} = c$ for real $c$.

Because norm-preservation holds for *all* nonzero $q$, the action does not really
depend on the length of $q$ — scaling $q$ changes nothing. The map factors
through the projective unit group, and this is precisely the mechanism producing
the celebrated **double covers** $S^3 \to SO(3)$ and $S^3 \times S^3 \to SO(4)$:
each rotation of three- or four-dimensional space comes from a unit quaternion,
and exactly two quaternions, $q$ and $-q$, give the same rotation. The unit
sphere $S^3$ is, quite literally, a two-to-one shadow of the group of spatial
rotations — a fact indispensable to everything from robotics and computer
graphics to the spin of the electron.

## One idea, five windows

Step back and the unity is unmistakable. A fibre of the Hopf map is reconstructed
by an inner product; a sphere is combed by multiplication by $i$; the ladder of
sum-of-squares identities lives and dies by whether $J^2 = -1$ has a solution;
the fattest torus is the balanced one; and rotations are the shadows of unit
quaternions. In every case the load-bearing fact is the **multiplicativity of a
norm** — the defining property of the composition algebras $\mathbb{R}$,
$\mathbb{C}$, $\mathbb{H}$, $\mathbb{O}$. The fourth dimension, so
counterintuitive to the eye, turns out to be a playground with very few, very
sharp rules. Learn the algebra of length, and the geometry falls into your hands.
