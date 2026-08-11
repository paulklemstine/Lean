# The Loneliest Point in a Crystal

## How far can you get from every atom at once?

Stand inside a crystal. Around you, in every direction, atoms sit at the nodes of a perfectly
regular grid, repeating forever. Now play a game: walk to the point that is as far as possible
from the *nearest* atom. Not far from one atom — far from **all** of them, simultaneously.

That point has a name. Crystallographers call it a **deep hole**, and it is where an impurity
atom likes to lodge, where a defect nucleates, where an interstitial ion parks itself in a
battery electrode. Its distance from the lattice is called the **covering radius**: the smallest
$R$ such that balls of radius $R$ centred at every atom cover the whole of space, leaving no
gaps.

The deep hole is the shy twin of a much more famous quantity. If you ask instead for the
*shortest* distance between two atoms, you get the **packing radius** — the number that governs
how densely spheres can be stacked, that decides whether oranges at the greengrocer or error-
correcting codes in a modem are efficient. Packing is about the closest pair. Covering is about
the loneliest point. Packing is a minimum; covering is a maximum of a minimum, and that extra
layer of quantification is why covering has always been the harder of the two.

This article is about a complete answer to the covering question in the first genuinely
two-dimensional case: an *exact formula*, a *sharp inequality*, and a surprising discovery that
one very coarse piece of data about a two-dimensional crystal already determines the crystal
completely.

---

## The arithmetic of a crystal

A two-dimensional lattice is what you get by taking two vectors $v$ and $w$ in the plane that do
not point along the same line and forming all integer combinations $pv + qw$. To do arithmetic
with it, forget the picture and keep only the *energy* — the squared length. Write

$$Q(x,y) = a x^2 + b x y + c y^2$$

for the squared length of the vector $x v + y w$; here $a = |v|^2$, $c = |w|^2$ and
$b = 2 \langle v, w\rangle$. Every planar lattice is described by such a **binary quadratic
form**, and the form is *positive definite*: $Q(x,y) > 0$ unless $x = y = 0$.

Two numbers now summarise the packing/covering dichotomy.

- The **minimum** $\lambda_1$ is the least value of $Q(p,q)$ over integer pairs $(p,q) \neq
  (0,0)$: the squared length of a shortest nonzero lattice vector. This is the packing datum.
- The **covering radius squared** $\mu$ is defined by a maximin: for every point $t$ of the plane
  let $\mu(t) = \min_{m \in \mathbb{Z}^2} Q(t - m)$ be its squared distance to the nearest
  lattice point — the **gap** at $t$ — and set $\mu = \max_t \mu(t)$. The maximisers are the deep
  holes.

The same form can be written in many bases; changing basis by an invertible integer matrix
shuffles $(a,b,c)$ without changing the lattice. Gauss's reduction theory says one can always
arrange

$$0 \le b \le a \le c,$$

and in that **reduced** shape the first coefficient is no longer just a coefficient: $a$ *is*
$\lambda_1$. The shortest vector has become the first basis vector. Two examples to keep in
mind: the square lattice $\mathbb{Z}^2$ with $Q = x^2 + y^2$, i.e. $(a,b,c) = (1,0,1)$; and the
hexagonal (honeycomb) lattice with $Q = x^2 + xy + y^2$, i.e. $(1,1,1)$ — the arrangement of a
stack of pennies, of graphene's carbon atoms, of bubbles in a raft.

---

## Halfway houses: the four coset minima

Before the deep hole, consider its cheap approximation. Instead of maximising over *all* points,
maximise only over the **half-points** $v/2$ where $v$ is a lattice vector. There are only four
of them up to lattice translation, because halving is undone by the four classes of $v$ modulo
$2$: $(0,0)$, $(1,0)$, $(0,1)$, $(1,1)$ — a $2 \times 2$ menu of parities.

Each class $v$ has a **coset minimum**: the smallest energy of a lattice vector congruent to $v$
modulo $2$. Collect four times these minima into a multiset and you get what we call the
**covering weight enumerator**

$$W(Q) = \{\, 4\,\mu(v/2) \;:\; v \in L/2L \,\}.$$

For the square lattice the answer is the familiar Hamming weight enumerator of two bits:
$\{0,1,1,2\}$. What happens for a general lattice, with the cross term $b$ switched on?

> **Theorem (the four coset minima).** For a reduced form $Q = ax^2 + bxy + cy^2$ with
> $|b| \le a \le c$, the covering weight enumerator is
> $$W(Q) = \{\,0,\; a,\; c,\; a + c - |b|\,\},$$
> the four entries being realised by the classes $(0,0)$, $(1,0)$, $(0,1)$, $(1,1)$ in that
> order; and every half-point gap of the lattice is one of these four numbers divided by four.

The proof is three integer inequalities, one per nonzero class, all descending from a single
observation valid in the reduced range: since $|b| \le a$, the cross term can never overwhelm the
diagonal, and
$$a x^2 + bxy + cy^2 \;\ge\; a\big(x^2 - |xy|\big) + c y^2 .$$
For the class "$x$ odd, $y$ even", say, one has $|x| \ge 1$ and either $y = 0$ (then $Q \ge a$
directly) or $|y| \ge 2$, in which case the slack in $c \ge a$ more than pays for the cross term.
The class $(1,1)$ is the interesting one: among the four sign patterns of an odd pair, the
smallest value of $a \pm b + c$ is $a + c - |b|$, and that is exactly the top entry.

So the enumerator runs from the packing invariant to a covering-flavoured invariant: its smallest
nonzero entry is $\lambda_1 = a$, and its largest is $a + c - |b|$.

### A coarse invariant that hides nothing

Here is the surprise. The enumerator is an extremely lossy-looking summary — four numbers, in no
particular order, obtained by *minimising* over four cosets. One expects such a gadget to
conflate different lattices. In two dimensions it never does.

> **Theorem (completeness in rank two).** Two reduced binary forms with the same covering weight
> enumerator have the same $(a, |b|, c)$, hence describe the same lattice up to the coordinate
> flip $y \mapsto -y$. In rank two the covering weight enumerator is a **complete** isometry
> invariant.

The recovery uses only three order-theoretic facts and no case analysis. The least nonzero entry
gives $a$. The greatest entry gives $M = a + c - |b|$ (it really is the greatest, because
$|b| \le a \le c$ forces $a \le c \le a + c - |b|$). And the sum of all four entries is
$S = 2a + 2c - |b|$. Then $c = S - M - a$ and $|b| = a + c - M$. Notice that the argument never
needs the entries to be distinct — which matters, because there is one lattice where they are
not.

That lattice is the hexagonal one: $W(x^2+xy+y^2) = \{0,1,1,1\}$. All three nonzero classes have
the same coset minimum. In the honeycomb, every parity class contains a shortest vector. This
degeneracy is not a curiosity; it is the obstruction that made the next theorem hard.

---

## Every planar crystal is strictly worse at covering than a line

There is a soft, universal inequality relating the two radii: a deep hole is at least as far from
the lattice as the midpoint of a shortest vector, so
$$\mu \;\ge\; \frac{\lambda_1}{4}.$$
In dimension one this is an equality: on the lattice $\mathbb{Z}$, the loneliest point is exactly
the midpoint between two consecutive integers. Is it ever an equality in higher dimension? For
lattices with a rectangular basis one sees quickly that it is not. But "quickly" hides a genuine
difficulty: to prove strictness one must *exhibit* a point that is provably far from **every**
lattice point, not merely from the nearby ones.

> **Theorem (strictness in the plane).** For every positive-definite binary form,
> $\mu > \lambda_1/4$. Dimension one is the only case of equality.

The natural candidate for a certificate is the half-point $(\tfrac12,\tfrac12)$, whose gap is
$(a - |b| + c)/4$ by the enumerator theorem. This beats $a/4$ whenever $|b| < c$. In the reduced
range, the only way to have $|b| = c$ is $a = c = |b|$ — the hexagonal form again, where all
half-point gaps collapse to $\lambda_1/4$ and *no* two-fold symmetric point can possibly serve as
a witness. There the certificate has to be a **third**-point: $(\tfrac13,\tfrac13)$, and the
proof of its gap is a congruence. If $X \equiv Y \equiv 1 \pmod 3$ then $3$ divides
$X^2 + XY + Y^2$, and positivity upgrades divisibility to $X^2 + XY + Y^2 \ge 3$; scaling by
$1/9$ turns this into the statement that $(\tfrac13,\tfrac13)$ has gap $1/3 > 1/4$.

Removing the assumption that the basis is reduced is a small piece of reduction theory worth
stating on its own, because it is what makes the theorem apply to *every* lattice rather than to
a normal form: a vector realising the minimum is necessarily **primitive** (if it were $k$ times
something, that something would be shorter), so Bézout's identity supplies a partner completing
it to a basis, and one shear of that partner brings the cross term into range.

---

## The exact answer: circumcentres

Strictness says $\mu$ is bigger than $\lambda_1/4$; the real question is *how much* bigger. Here
is the complete answer.

> **Theorem (the covering radius of a planar lattice).** Let $Q = ax^2+bxy+cy^2$ be reduced,
> $0 \le b \le a \le c$, and let $D = 4ac - b^2$ be its discriminant. Then the covering radius
> squared is exactly
> $$\mu \;=\; \frac{a\,c\,(a - b + c)}{4ac - b^2},$$
> attained at the deep hole
> $$h \;=\; \left(\frac{c(2a-b)}{D},\; \frac{a(2c-b)}{D}\right)$$
> in basis coordinates, and at no point further away.

The formula has a transparent geometric meaning. Split the fundamental parallelogram along its
short diagonal into two triangles; because the form is reduced, the triangle with vertices $0$,
$v$, $w$ is non-obtuse, and it is a *Delaunay* triangle — its circumscribed circle contains no
lattice point in its interior. Its three sides have squared lengths $a$, $c$ and $a - b + c$, and
its area is $\sqrt{D}/4$. The classical circumradius formula $R = \frac{(\text{product of
sides})}{4\,(\text{area})}$ then reads
$$R^2 = \frac{a \cdot c \cdot (a+c-b)}{16 \cdot D/16} = \frac{ac(a-b+c)}{D},$$
which is the theorem. The deep hole is a circumcentre: the point equidistant from three atoms, as
far as one can get before a fourth atom starts closing in.

Behind the proof is one algebraic identity that does all the work. Translate the form so the deep
hole sits at the origin: for all $x, y$,
$$Q(x - h_1,\, y - h_2) \;=\; Q(x,y) - a x - c y + \mu .$$
The two halves of the theorem are then the two readings of this identity.

**Lower bound (the hole really is that deep).** Put an integer point $(p,q)$ into the identity.
The gap at $h$ is at least $\mu$ precisely when
$$a\,p(p-1) + c\,q(q-1) + b\,p\,q \;\ge\; 0 \quad\text{for all integers } p, q.$$
If $p$ and $q$ have the same sign, every term is nonnegative and there is nothing to prove:
$p(p-1) \ge 0$ for integers. If they have opposite signs, the cross term is negative, but
$|b| \le a \le c$ and $|p|,|q| \ge 1$ mean the two quadratic terms dominate — this is the entire
content of reducedness. Equality holds exactly at $(0,0)$, $(1,0)$ and $(0,1)$: the three
vertices of the Delaunay triangle, all at the same distance from its circumcentre.

**Upper bound (no point is deeper).** Take any point $t$ of the plane, translate it into the unit
cell, and place it inside one of the two Delaunay triangles. Now invoke Lagrange's identity for a
triangle: if $(\ell_1,\ell_2,\ell_3)$ are the barycentric coordinates of a point with respect to
the three vertices, then the *weighted average* of its squared distances to the vertices equals a
concave quadratic expression in the coordinates — which the same translation identity shows never
exceeds $\mu$. A weighted average of three numbers with nonnegative weights summing to one cannot
have all three exceed the average, so *some* vertex of the triangle is within squared distance
$\mu$. Since barycentric coordinates are nonnegative exactly inside the triangle, this is where
splitting the cell along the *short* diagonal matters. That is the whole proof: an integrality
argument for the lower bound, a convexity argument for the upper bound — the packing/covering
dichotomy in miniature.

### What the formula tells us

Specialise, and a series of clean statements falls out.

- **Quantitative strictness.** A short computation from the formula gives
  $$\mu - \frac{\lambda_1}{4} \;=\; \frac{a(2c-b)^2}{4(4ac-b^2)} \;>\; 0,$$
  since $2c - b \ge 2c - a > 0$. The classical inequality is not just strict; the excess is an
  explicit rational function.
- **When is a half-point a deepest hole?** Exactly when $b = 0$:
  $\mu = (a-b+c)/4$ if and only if the lattice is rectangular. Every non-rectangular planar
  crystal has its loneliest point at a circumcentre that is not a half-lattice point.
- **A universal ceiling.** $\mu \le (a+c)/2$, with the square lattice's $\mu(\mathbb{Z}^2) = 1/2$
  as the model case; the deep hole of $\mathbb{Z}^2$ is the centre of a unit square, at squared
  distance $1/2$ from each of its four corners.
- **The honeycomb is the worst coverer.** The hexagonal lattice has $\mu = 1/3$ against
  $\lambda_1 = 1$.

That last item is not an accident but a theorem, and it is the sharp form of the classical
inequality:

> **Theorem (sharp packing–covering inequality in the plane).** Every planar lattice satisfies
> $$\mu \;\ge\; \frac{\lambda_1}{3},$$
> with equality **exactly** for the hexagonal form $a(x^2+xy+y^2)$.

The constant $1/4$ that holds in all dimensions is therefore never attained in the plane; the
true planar constant is $1/3$, and the extremal case is unique. Rearranged, the theorem says the
honeycomb is the planar arrangement whose deep holes are the *shallowest* relative to its
spacing — which is exactly why the honeycomb is simultaneously the densest planar packing and the
thinnest planar covering. Density and economy, usually in tension, agree in two dimensions, and
this inequality with its rigidity clause is a precise expression of that agreement.

It is pleasant that the same lattice that obstructed the strictness proof — the one lattice where
half-points tell you nothing — turns out to be the unique extremiser of the sharpened
inequality. The obstruction *was* the extremal case.

---

## Why anyone should care

**Materials.** Deep holes are interstitial sites. Where a lithium ion sits in a layered
electrode, how large a dopant an alloy can swallow without straining, where a vacancy relaxes to
— all are covering-radius questions in disguise, with the lattice replaced by the atomic
positions. The exact formula turns a numerical optimisation over a continuum of candidate
positions into an evaluation of a rational function of three integers.

**Signals and codes.** In lattice quantisation, one encodes a continuous signal by the nearest
lattice point. The worst-case distortion of such a quantiser is precisely the covering radius,
and the average distortion is governed by the same Delaunay geometry. The theorem that the
hexagonal lattice minimises $\mu/\lambda_1$ is the reason hexagonal sampling beats square
sampling in image processing at equal density.

**Numbers.** The gap function $\mu(t)$ is a diophantine object: it measures how well a point can
be approximated by lattice points, and its maximum is the "inhomogeneous minimum" of the form —
a quantity studied since Minkowski. The covering weight enumerator is a genuinely new invariant
of that family, and its completeness in rank two immediately localises where the interesting
phenomena must live: **any** pair of distinct lattices sharing all their coset minima must have
dimension at least three.

**Structure.** Finally, there is the pleasure of the shape of the answer. A maximin over a
continuum, taken over an infinite lattice, collapses to $ac(a-b+c)/(4ac-b^2)$ — a ratio in which
the numerator counts the sides of a triangle and the denominator is the determinant of the
crystal. The loneliest point in a two-dimensional crystal is not lonely at all: it is the meeting
point of three atoms' claims, sitting exactly where their circles agree.
