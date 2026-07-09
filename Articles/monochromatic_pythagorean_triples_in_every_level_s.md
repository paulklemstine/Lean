# Every Color Hides a Right Triangle

## A puzzle about painting the numbers

Imagine you have an unlimited box of crayons and you decide to color
every positive whole number. You color $1$, then $2$, then $3$, and so on
forever. You are free to choose whatever colors you like — but you agree
to follow a single rule that mathematicians find irresistibly natural:
the color of a *product* is determined by the colors of its *factors*.
More precisely, if you know the color of $m$ and the color of $n$, then
the color of $m \times n$ is fixed by a "color arithmetic." Coloring
schemes that obey this rule are called **completely multiplicative
colorings**, and they are everywhere in number theory in disguise.

Now recall the most famous equation in all of mathematics, the one every
schoolchild meets: the Pythagorean relation
$$x^2 + y^2 = z^2.$$
Its whole-number solutions — like $(3, 4, 5)$, $(5, 12, 13)$, or
$(8, 15, 17)$ — are the **Pythagorean triples**, the side lengths of
right triangles with integer sides. They have fascinated people since
antiquity.

Here is the question that ties the crayons to the triangles. Fix a
color, say *turquoise*. Must there always exist a Pythagorean triple
$(x, y, z)$ whose three members $x$, $y$, and $z$ are **all turquoise**?
And if turquoise works, what about every other color you used?

This article is about a clean and, at first glance, surprising answer:
for these multiplicative colorings, the situation is **all or nothing**.
The moment a single right triangle turns out to be monochromatic — all
three sides the same color, *any* color — then *every* color you ever
used must decorate a monochromatic triangle of its own. There are no
"lonely" colors that miss out.

## Why this is not obvious

At first the general problem looks strictly harder than a special case.
There is one color that is unavoidably special: the color of the number
$1$. Because $1 \times 1 = 1$, the color arithmetic forces $1$ to be the
"neutral" color — call it *white*. White behaves like the number $1$ in
ordinary multiplication: combining anything with white leaves the other
color unchanged.

It is tempting to hope that once you understand the white triangles, you
could "divide out" a color to reach all the others. But that hope fails.
If $f(n)$ denotes the color of $n$, then the shifted assignment
$n \mapsto f(n)/\omega$ (trying to recenter around a target color
$\omega$) is *no longer* a valid multiplicative coloring — it breaks the
very rule that makes the problem tractable. So there is no lazy
substitution that turns a general color into the white case. Something
genuinely different is needed.

## The trick: move the triangle, not the palette

The key idea is to stop trying to modify the coloring and instead move
the *triangle*. Pythagorean triples enjoy a beautiful symmetry: they are
**scale invariant**. If $(x, y, z)$ satisfies $x^2 + y^2 = z^2$, then so
does the enlarged triple $(tx, ty, tz)$ for any positive integer $t$,
because
$$(tx)^2 + (ty)^2 = t^2(x^2+y^2) = t^2 z^2 = (tz)^2.$$
Geometrically you are just photocopying the same right triangle at a
larger scale; algebraically you have produced a brand-new Pythagorean
triple.

Now watch what scaling does to *colors*. Under a multiplicative coloring,
the color of $t \times x$ is the color of $t$ combined with the color of
$x$. So if you scale an entire monochromatic triangle of color $v$ by a
factor $t$, **all three sides shift by the same amount**: their common
color changes from $v$ to (color of $t$) combined with $v$. The triangle
stays monochromatic; only its shade slides.

This turns the problem into a scavenger hunt. Starting from a
monochromatic triangle of some color $v$, which target colors $\omega$
can we reach by choosing the scale factor $t$ cleverly? We can reach
$\omega$ exactly when there is some number $t$ whose color, combined with
$v$, gives $\omega$ — in other words, when the "color gap" from $v$ to
$\omega$ is itself the color of some number.

## Why the palette is secretly a group

To finish, we need to know which color gaps are achievable. This is where
a second, quieter assumption does the heavy lifting: the palette is
**finite**. In the motivating case the colors are the $k$-th roots of
unity — the $k$ evenly spaced points on a circle — and there are only $k$
of them. Finiteness has a magical consequence.

Consider all the colors that actually appear as $f(n)$ for some positive
$n$; call this the **image** of the coloring. Two easy facts and one
subtle fact show the image is closed under the color arithmetic in the
strongest possible sense — it forms what algebraists call a **group**:

- **White is in it.** Since $f(1)$ is white, white always appears.
- **Products stay inside.** If colors $a$ and $b$ both appear — as
  $f(m)$ and $f(n)$ — then their combination appears too, as
  $f(m \times n)$.
- **Every color has an inverse inside it.** This is the subtle part, and
  it is exactly where finiteness matters. In a finite palette, repeatedly
  combining a color $c$ with itself must eventually cycle back to white:
  there is some power $c^N = $ white. But then $c^{N-1}$ acts as the
  "undo" of $c$, and since $c^{N-1}$ is the color of a suitable power of a
  number, that inverse color also appears in the image.

Once the image is a group, color gaps are free to cross: for *any* two
colors $v$ and $\omega$ in the image, the gap from $v$ to $\omega$ is
also in the image, so a number $t$ with exactly that color exists. Scale
your monochromatic triangle by that $t$, and its color slides precisely
onto $\omega$. Done.

## The theorems, stated plainly

The reasoning above is captured by three clean statements. Throughout,
$f$ is a completely multiplicative coloring into a finite group of colors,
and a Pythagorean triple $(x,y,z)$ is *monochromatic of color $\omega$*
if $f(x) = f(y) = f(z) = \omega$.

**The Reduction.** *If even one monochromatic Pythagorean triple exists —
of any color whatsoever — then for every color $\omega$ that appears in
the coloring, there is a Pythagorean triple that is monochromatic of
color exactly $\omega$.*

**The All-or-Nothing Dichotomy.** *There exists a monochromatic
Pythagorean triple of the neutral color white if and only if there exists
a monochromatic Pythagorean triple of every color in the image.* In
particular, the "hard" white case is logically equivalent to the full,
every-color statement — they stand or fall together.

**The $(3,4,5)$ Corollary.** *If the classical triangle $(3,4,5)$ happens
to be monochromatic — that is, if $3$, $4$, and $5$ all receive the same
color — then every color in the coloring adorns a monochromatic triangle.*

## What is left, and why it is beautiful

Notice what the argument does and does not settle. It shows that the
entire many-colored problem collapses onto a single question: *does even
one monochromatic Pythagorean triple exist?* That lone existence
statement is the genuinely deep part — an analytic fact about how three
multiplicative values can be forced to coincide on a right-triangle
configuration. But everything *around* it — the bookkeeping of colors,
the passage from one color to all colors — is now completely understood
and, pleasingly, elementary.

This is the kind of result mathematicians love: it does not just answer a
question, it *reorganizes* one. It cleanly peels apart two layers that
were tangled together — a soft algebraic layer, fully settled here by the
scaling trick, and a hard analytic core, isolated so that future effort
can be aimed at exactly the statement that carries the weight.

There is also a broader moral. The scaling trick never used anything
about squares. Any homogeneous Diophantine relation invariant under
simultaneous scaling — replace $x^2 + y^2 = z^2$ with your favorite
scale-symmetric equation — obeys the same all-or-nothing law for
multiplicative colorings. Right triangles were just the most beautiful
place to see it first.

So the next time you imagine painting the integers by any multiplicative
rule, remember: you cannot quietly starve a single color of its right
triangle. Either the triangles refuse every color at once, or they
generously offer one to each. In the world of multiplicative colorings,
geometry plays no favorites.
