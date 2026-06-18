# The Secret Arithmetic of a Spinning Circle

## How one rational fraction turns geometry into algebra

Picture a point sliding around the rim of a circle. As it travels it sweeps out
angles, and angles are the natural language of rotation: turn by thirty degrees,
then by sixty, and you have turned by ninety. Addition of angles is the
arithmetic of spinning. It is clean, it is familiar, and it hides a beautiful
secret. If you refuse to talk about angles at all — if you insist on describing
every point by a single ordinary number on a straight line — that same act of
"rotate a little more" becomes one of the most elegant formulas in all of
mathematics:

$$ t \oplus s = \frac{t + s}{1 - t\,s}. $$

This article is the story of that fraction. It is the story of how a circle can
be flattened onto a line without tearing, how rotation survives the flattening
as a single rational operation, how that operation is secretly a multiplication
of matrices, and how — buried inside the same formula — lives the famous
3-4-5 right triangle that every schoolchild meets. None of this requires
anything beyond high-school algebra to *state*, yet it ties together
trigonometry, group theory, linear algebra, and a pinch of number theory into
one compact knot.

## Flattening a circle onto a line

Start with the unit circle: all points $(x, y)$ at distance one from the
origin, so $x^2 + y^2 = 1$. There is a wonderfully concrete way to give every
such point a single real-number "address." Stand at the very top of the circle,
the north pole $(0, -1)$ in our chosen orientation, and shine a flashlight from
there. Every ray of light, as it leaves the pole, eventually crosses a
horizontal line laid across the page. Conversely, every spot on that line, when
you draw the line back to the pole, pierces the circle exactly once. This
correspondence is called **stereographic projection**, and it is the same trick
cartographers use to draw the round Earth on a flat map.

Run the projection backwards — from the flat line up onto the round circle — and
you get an explicit formula. Give it the real number $t$, and it hands you back
the point

$$ \text{invStereo}(t) = \left( \frac{2t}{1+t^2},\ \frac{1-t^2}{1+t^2} \right). $$

You can check, with nothing more than careful algebra, that this point always
lands exactly on the circle:

$$ \left(\frac{2t}{1+t^2}\right)^2 + \left(\frac{1-t^2}{1+t^2}\right)^2 = 1. $$

This is our first theorem, and it is the bedrock everything else rests on. The
single coordinate $t$ has a beautiful geometric meaning: it is the tangent of
*half* the angle from the center. When $t = 0$ you sit at the bottom point
$(0, 1)$; as $t$ grows toward infinity you climb toward the pole you never quite
reach; negative $t$ sends you around the other side. One straight line of real
numbers, wrapped seamlessly onto a circle, with a single point — the pole
itself — left over. Remember that leftover point; it will return as the one
flaw in an otherwise perfect picture.

## Rotation, reborn as a fraction

Here is the question that drives the whole story. Suppose you have a point on the
circle with address $t$, and you rotate it by some angle. The rotated point has
a new address. **What is the new address in terms of the old one?**

In raw $(x, y)$ coordinates, rotation is a clumsy thing: it mixes both
coordinates together with sines and cosines, and the formula is opaque. But in
the stereographic address $t$, something miraculous happens. If rotating by the
chosen angle corresponds to the address $s$, then the rotated point's address is
simply

$$ t \oplus s = \frac{t + s}{1 - t\,s}. $$

That is the whole law. Rotation — the fundamental symmetry of the circle, the
engine behind every gear, orbit, and oscillation — becomes a single rational
fraction. Anyone who has met the tangent addition formula from trigonometry,

$$ \tan(A + B) = \frac{\tan A + \tan B}{1 - \tan A \tan B}, $$

will recognize an old friend. That is exactly what $\oplus$ is: because $t$ is
the tangent of a half-angle, combining two rotations means adding their
half-angles, and the tangent of a sum obeys precisely this rule.

The central theorem of this work makes the connection airtight. It proves that
the point you get by feeding the combined address $t \oplus s$ into the
projection is *identical* to the point you get by rotating $\text{invStereo}(t)$
through the angle attached to $s$. Written out in coordinates, with
$(x_1, y_1) = \text{invStereo}(t)$ and $(x_2, y_2) = \text{invStereo}(s)$, the
rotated point is

$$ \big(\, x_1 y_2 + y_1 x_2,\ \ y_1 y_2 - x_1 x_2 \,\big), $$

which any reader will recognize as the sine and cosine angle-addition formulas
in disguise. The fraction $\oplus$ and the trigonometric addition laws are two
faces of one coin.

## The one algebraic miracle

Why does any of this work? Strip away the geometry and a single algebraic
identity does all the heavy lifting:

$$ (1 - t\,s)^2 + (t + s)^2 = (1 + t^2)(1 + s^2). $$

Try it. Expand the left side: $1 - 2ts + t^2 s^2 + t^2 + 2ts + s^2$. The cross
terms $-2ts$ and $+2ts$ annihilate, and what survives is
$1 + t^2 + s^2 + t^2 s^2$, which factors perfectly into $(1+t^2)(1+s^2)$. This
tidy cancellation is the reason the "half-angle substitution" — a workhorse of
calculus that turns frightening trigonometric integrals into routine rational
ones — works at all. It is the reason the circle can be parametrized by rational
functions. It is the seed of every result in this article.

## Rotation is matrix multiplication

Mathematicians love to find the *same* structure wearing different costumes.
The addition law has a third costume: honest matrix multiplication. To each
address $t$ attach the little $2 \times 2$ array

$$ R(t) = \begin{pmatrix} y & -x \\ x & y \end{pmatrix}, \qquad (x, y) = \text{invStereo}(t). $$

This is a genuine rotation matrix — its columns are the point on the circle and
its quarter-turn. The theorem then states, cleanly,

$$ R(t)\, R(s) = R(t \oplus s). $$

Multiply the two matrices the ordinary way, and the entries reorganize
themselves (by exactly the same algebraic miracle) into the matrix of the
combined rotation. Moreover each such matrix has determinant exactly one:

$$ \det R(t) = x^2 + y^2 = 1, $$

which is just our first theorem in a new guise. In the language of group theory,
every $R(t)$ lives in $SO(2)$, the group of rotations of the plane, and our
fraction $\oplus$ is the shadow these matrices cast back onto the line. The same
phenomenon, over the whole numbers instead of the reals, is how Gaussian
integers multiply and how their norms behave — a quiet bridge from this circle
to the heart of number theory.

## An almost-perfect group — and its single flaw

When an operation is associative, commutative, and has a neutral element, we
call its world a *group* — the central object of modern algebra, the
mathematics of symmetry itself. Our fraction nearly qualifies:

- **Identity:** $t \oplus 0 = t$. Adding the address of "no rotation" changes
  nothing.
- **Commutativity:** $t \oplus s = s \oplus t$. The order of two rotations of a
  circle does not matter.
- **Associativity:** $(t \oplus s) \oplus u = t \oplus (s \oplus u)$. Grouping
  three rotations any way you like gives the same result.

That last property is the deepest, and proving it revealed a small surprise.
One might expect to need every denominator in sight to be nonzero. In fact, once
you clear only the two *inner* denominators, the associativity statement becomes
a pure polynomial identity — true by raw algebra, with the outer conditions
falling away as unnecessary. This is the fingerprint of what algebraists call a
*formal group law*: an addition rule so structurally clean that its essential
identities are polynomial.

So why only *almost* a group? Look back at the denominator $1 - ts$. When
$ts = 1$ the fraction blows up. Geometrically, this is the single leftover point
from our flattening — the pole the flashlight stands on, the "point at infinity"
that the straight line never reaches. Two rotations whose half-angles sum to a
quarter turn send a point precisely to that missing pole, and the line-address
of the pole does not exist. The operation is a **partial** group law: total
everywhere except at the one point where the circle and the line refuse to
agree. Patching this hole — compactifying the line into a closed loop so the
group becomes total — is one of the natural next steps this work points toward.

## Keeping things in order

Addresses on a line come with a natural order: $-1$ sits left of $0$ sits left
of $2$. Does that order mean anything on the circle? Yes — through the
**stereographic angle**

$$ \Theta(t) = 2 \arctan t. $$

This converts an address back into an honest angle, living in the open arc from
$-\pi$ to $\pi$. Two facts make it the order-theoretic backbone of the theory.
First, it is *strictly increasing*: if $t < t'$ then $\Theta(t) < \Theta(t')$.
Sliding right along the line always sweeps the angle the same direction around
the circle — no doubling back. Second, on the branch where $ts < 1$ it converts
our exotic fraction into plain addition:

$$ \Theta(t \oplus s) = \Theta(t) + \Theta(s). $$

The strange-looking $\oplus$ is, after this change of coordinates, nothing but
ordinary $+$. That is the whole point of a good coordinate system: it makes the
hard operation look easy.

There is even a shape to how $\Theta$ rises. On the right half-line — addresses
from zero onward — it is *concave*: it climbs quickly at first, then ever more
gently, flattening as it approaches its ceiling of $\pi$. Tellingly, this
concavity is only local. At $t = 0$ the curve has an inflection point: it is
convex on the left and concave on the right. A claim of global concavity would
simply be false, and recognizing exactly where a clean statement breaks is as
much a part of honest mathematics as proving the statement itself.

## The 3-4-5 triangle hiding in the circle

We end where the theory touches something tangible. Among all the coordinates of
points on the circle, single out the horizontal one,

$$ \text{cap}(t) = \frac{2t}{1+t^2}, $$

the "capacity" — how far right of center the point reaches. How large can it
get? The answer is a small gem: it never exceeds one,

$$ \frac{2t}{1+t^2} \le 1, $$

and equals one *exactly* when $t = 1$. The proof is a single rearrangement:
$1 + t^2 - 2t = (1 - t)^2 \ge 0$, which is zero only at $t = 1$. The maximum
horizontal reach happens at one precise address.

Now feed that special address back through our projection. At $t = 1$ the point
is the far-right point $(1, 0)$. But the more famous number theory lives one
notch in: at $t = 1/2$, the projection produces

$$ \text{invStereo}\!\left(\tfrac12\right) = \left( \frac{2 \cdot \tfrac12}{1 + \tfrac14},\ \frac{1 - \tfrac14}{1 + \tfrac14} \right) = \left( \frac{4}{5},\ \frac{3}{5} \right). $$

There it is: the **3-4-5 right triangle**, the oldest and most beloved example
of the Pythagorean theorem, emerging from a rational address on a circle. This
is no accident. The very rationality that the half-angle miracle guarantees is
exactly what lets the circle harvest whole-number right triangles: every
Pythagorean triple is a rational point on this circle, and every rational point
is the projection of a rational address. The bridge from a spinning circle to
ancient geometry is the same fraction we started with.

## Why it matters

It is tempting to file all this under "pretty identities." But the lesson runs
deeper. A circle is rotation made visible, and rotation is the most basic
symmetry there is — in the orbits of planets, the phases of alternating current,
the spin of a qubit, the gears of a machine. By choosing the right coordinate,
the formidable machinery of rotation collapses into a fraction a student can
write down. Trigonometry, linear algebra, group theory, and number theory turn
out to be four dialects of one sentence:

$$ t \oplus s = \frac{t + s}{1 - t\,s}. $$

Learn to read it, and a great deal of mathematics suddenly speaks with a single
voice.
