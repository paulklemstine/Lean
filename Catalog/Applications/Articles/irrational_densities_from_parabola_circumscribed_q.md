# The Parabola That Refuses to Repeat

## A shape, a tiling, and a number that never settles down

Take a sheet of paper and draw the simplest curved line in mathematics: a
parabola, the gentle U-shape traced by the equation $y = x^2$. It is the path
of a thrown ball, the cross-section of a satellite dish, the silhouette of a
suspension cable under a uniform load. Now draw a four-sided figure — a
quadrilateral — whose every side just grazes that curve, touching it but never
crossing. Geometers say such a quadrilateral is *circumscribed* about the
parabola.

It looks like an ordinary picture. But hidden inside it is an instruction
manual for building a pattern that **can never repeat itself** — a tiling of
the plane that goes on forever without any periodic rhythm, and whose very
"texture" is governed by a number that no fraction can ever capture. This is
the surprising thread that ties together three ideas that seem to live in
different worlds: the geometry of circles touching a parabola, the arithmetic
of irrational numbers, and the physics of *aperiodic* matter — the strange
crystals that won quite literally a Nobel Prize.

This article tells the story of how a parabola forces irrationality, and why
that matters.

## Part 1: Four points and a circle

Start with the curve $y = x^2$ and pick four points on it. Because every point
on the parabola is completely determined by its horizontal coordinate, we can
name our four points by just four numbers — their *abscissae* (x-coordinates),
say $a$, $b$, $c$, and $d$. The points themselves are
$(a, a^2)$, $(b, b^2)$, $(c, c^2)$, and $(d, d^2)$.

Here is a natural question. **When do these four points lie on a single
circle?** Three points always do (any triangle has a circumscribed circle),
but a fourth point is a genuine constraint — it must "agree" with the circle
the first three define.

The answer is astonishingly clean, and it is the first proved cornerstone of
this work:

> **Theorem (Concyclic Criterion).** Four distinct points on the parabola
> $y = x^2$, with x-coordinates $a, b, c, d$, lie on a common circle **if and
> only if**
> $$a + b + c + d = 0.$$

No lengths, no angles, no determinants to memorize — just *add the four
horizontal coordinates and check whether they cancel*. If they sum to zero,
the four points are **concyclic**; if not, no circle can thread all four.

Why is something so geometric controlled by something so arithmetic? The proof
is a small miracle of algebra. A circle in the plane has an equation of the
form
$$x^2 + y^2 + Dx + Ey + F = 0,$$
for some numbers $D, E, F$. To find where a circle meets the parabola, we
substitute the parabola's defining relation $y = x^2$ into the circle's
equation. Replacing $y$ by $x^2$ (and $y^2$ by $x^4$) gives
$$x^4 + (1 + E)\,x^2 + D\,x + F = 0.$$
This is a degree-four polynomial in $x$, and its four roots are exactly the
x-coordinates of the intersection points — our $a, b, c, d$. Now comes the
punchline. A quartic written as $x^4 + p_3 x^3 + p_2 x^2 + p_1 x + p_0$ has,
by the classical relations of François Viète, the sum of its roots equal to
$-p_3$. But look at the quartic we produced: **there is no $x^3$ term at all.**
Its coefficient is zero. Therefore the sum of the roots must vanish:
$$a + b + c + d = 0.$$
And the logic runs both ways. If four distinct numbers sum to zero, the
polynomial $(x-a)(x-b)(x-c)(x-d)$ automatically has no cubic term, so it has
the shape $x^4 + p x^2 + q x + r$ — exactly the shape a circle carves out of
the parabola. Reading off $E = p - 1$, $D = q$, $F = r$ reconstructs the
circle. The geometry and the arithmetic are two faces of the same equation.

This "vanishing cubic coefficient" is the seed of everything that follows. It
says the parabola has a built-in *additive* law: the act of being concyclic is
the act of summing to zero.

## Part 2: From a quadrilateral to a slope

Now return to our circumscribed quadrilateral — the four-sided figure whose
sides are tangent to the parabola. A tangent line to $y = x^2$ touches it at a
single point, and again that point is labeled by one number. The four tangency
points carry four x-coordinates, and the geometry of "circumscription"
imposes algebraic relations among them of exactly the Viète flavor we just
met: certain symmetric combinations of the tangency abscissae are forced to
take specific values, and certain power-sums are forced to vanish.

When you grind through those relations for an honest, non-degenerate
quadrilateral, the *ratios* that emerge — the proportions that describe how the
tangent points are spaced — are typically **quadratic irrationals**: numbers
like $\sqrt{2}$, or the golden ratio
$$\varphi = \frac{1 + \sqrt{5}}{2} \approx 1.6180339887\ldots,$$
which are roots of simple quadratic equations with whole-number coefficients
but can never be written as one whole number divided by another.

The single most famous such number, the golden ratio, satisfies
$\varphi^2 = \varphi + 1$. That it is irrational is the second proved
cornerstone:

> **Theorem (Golden Slope Irrationality).** The golden ratio
> $\varphi = \tfrac{1+\sqrt{5}}{2}$ is irrational.

The proof rests on the irrationality of $\sqrt 5$. If $\sqrt 5$ were a
fraction $p/q$ in lowest terms, then $5q^2 = p^2$, forcing $5$ to divide $p$,
then forcing $5$ to divide $q$ — contradicting "lowest terms." So $\sqrt 5$
escapes every fraction, and since the rational numbers are closed under adding
$1$ and dividing by $2$, the combination $(1+\sqrt 5)/2$ must escape them too.
A number born from a clean geometric construction turns out to be one that
arithmetic can never pin down.

Hold onto that slope $\varphi$. It is about to become the metronome for an
infinite, non-repeating pattern.

## Part 3: Striping the plane — and why it never repeats

Imagine ruling a long strip of paper into cells, and in each cell deciding
whether to lay down a **vertical** stripe or a **horizontal** stripe. We want
to do this according to a rule, and we want the rule to be *local* — the kind
of edge-matching rule that the logician Hao Wang studied in the 1960s with his
famous **Wang tiles**, little squares with colored edges that may be placed
next to each other only when adjacent colors match. Wang's astonishing
discovery was that some sets of tiles can cover the entire plane **only in
aperiodic ways**: they tile forever, but never with a repeating wallpaper
pattern.

Our parabola-derived quadrilateral hands us exactly such a rule, and the slope
$\varphi$ tells us *how often* to place each kind of stripe. The recipe is a
**Beatty sequence**. Fix a positive number $\alpha$ — our slope. March through
the whole numbers $n = 1, 2, 3, \ldots$ and at each step record the integer
$$B_\alpha(n) = \lfloor n\alpha \rfloor,$$
the *floor* of $n\alpha$ (the largest integer not exceeding it). These integers
mark where the "vertical" stripes go; everything else gets a "horizontal"
stripe. The result is a one-dimensional quasicrystal — the discrete shadow of a
line of irrational slope.

The natural quantity to measure is the **density** of vertical stripes: out of
the first $N$ cells, what fraction are vertical? After $N$ steps the count of
marked cells is $\lfloor N\alpha\rfloor$, so the density is
$$\frac{\lfloor N\alpha \rfloor}{N}.$$
What happens to this fraction as we tile more and more of the line? Here is the
third proved cornerstone:

> **Theorem (Tile Density Limit).** For every real slope $\alpha$,
> $$\lim_{N \to \infty} \frac{\lfloor N\alpha \rfloor}{N} = \alpha.$$

The proof is a clean squeeze. By the very definition of the floor function,
$$N\alpha - 1 < \lfloor N\alpha \rfloor \le N\alpha.$$
Divide every term by $N$:
$$\alpha - \frac{1}{N} < \frac{\lfloor N\alpha\rfloor}{N} \le \alpha.$$
As $N$ grows, the gap $1/N$ shrinks to nothing, and the density is trapped,
pinched ever more tightly against $\alpha$ itself. The long-run texture of the
stripes *is the slope.*

Now combine the cornerstones. If the slope handed to us by the
parabola-circumscribed quadrilateral is the golden ratio $\varphi$ — an
irrational number — then the limiting stripe density is $\varphi$, and so:

> **The density of the stripes is irrational.**

This is the headline result, and it carries a physical sting. A tiling that
*repeated* with some period $p$ would have a perfectly rational density: in
every block of $p$ cells the same fixed number $k$ of vertical stripes would
appear, giving density exactly $k/p$, a fraction. An irrational density is
therefore a **certificate of aperiodicity** — an ironclad guarantee that the
pattern can *never* settle into a repeating wallpaper, no matter how far you
walk along it. The parabola, through the golden ratio, forbids repetition.

## Part 4: Why a physicist cares

For most of the twentieth century, crystallographers believed matter came in
two flavors: orderly crystals, whose atoms repeat on a periodic lattice, and
disordered glasses, with no long-range order at all. Periodicity was thought to
be the price of order. Then, in 1982, Dan Shechtman saw a diffraction pattern
with five-fold symmetry — a symmetry that *no* periodic crystal can possess. He
had discovered **quasicrystals**: solids that are exquisitely ordered yet never
repeat. The discovery was so heretical that it cost him his research group; it
later earned him the 2011 Nobel Prize in Chemistry.

The mathematics of quasicrystals is precisely the mathematics of irrational
slopes and Beatty sequences. A one-dimensional quasicrystal is a row of atoms
spaced according to a sequence like $\lfloor n\varphi \rfloor$ — exactly our
stripe pattern. Its diffraction pattern shows sharp, well-defined spots (the
signature of order) at positions that are *irrationally related* (the signature
of non-repetition). The irrational density we proved is the one-dimensional
fingerprint of that order-without-period.

So the storyline is complete and physical. A purely geometric object — a
quadrilateral hugging a parabola — encodes, through the vanishing-cubic
algebra of concyclic points, a quadratic-irrational slope. That slope drives a
Beatty striping whose density provably converges to the irrational slope
itself. And an irrational density is the mathematical hallmark of a
quasicrystal: ordered matter that nature builds, but that no periodic blueprint
could ever describe.

## Part 5: The view from here

The proved core is sharp and small — a concyclic criterion, an irrationality
fact, and a density limit — but it opens onto a wide landscape. Lift the
parabola to the paraboloid $z = x^2 + y^2$ and the "sum to zero" law for
concyclic points becomes a single linear condition for points to lie on a
common *sphere*. Replace the circle by a higher-degree curve and the lone Viète
relation blossoms into a whole tower of symmetric-function identities, with
several power-sums forced to vanish at once. Replace the golden ratio by any
quadratic irrational — any root of $x^2 + bx + c = 0$ with non-square
discriminant — and you get a whole family of aperiodic stripings, each with its
own irrational density and its own self-similar "Sturmian" rhythm.

There is even a self-referential twist. Take the golden Beatty set itself,
$\{\lfloor n\varphi\rfloor : n \ge 1\}$, lift its points onto the parabola, and
ask how many four-tuples inside it are concyclic — that is, how many quadruples
of its abscissae sum to zero. Because all the entries are non-negative, the sum
can essentially never vanish, so concyclic quadruples are vanishingly rare. The
aperiodic set built from the parabola is, in a precise sense, *almost free of
the very circles the parabola loves.*

From a single U-shaped curve, then, we extract a number that cannot be a
fraction, a tiling that cannot repeat, and a hint of the deep order that lets
crystals break the oldest rule in the book. The parabola, it turns out, has
been quietly refusing to repeat all along.
