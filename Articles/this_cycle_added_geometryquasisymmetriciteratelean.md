# The Shape That Survives Its Own Reflection

## How a single inequality, read backwards, tames the geometry of fractals under iteration

Imagine you have a photograph of a coastline. You feed it into a machine that
stretches, squeezes, bends, and warps the image — but never tears it, never
glues two distinct points together, and never collapses any region down to
nothing. Then you take the output and feed it back into the same machine. And
again. And again, a thousand times over.

Here is the question that has quietly haunted geometers for a century: **after
all that warping, is the coastline still "as crinkly" as it started?**

The crinkliness of a coastline is not a vague notion. It has a precise number
attached to it, called the **Hausdorff dimension**. A smooth curve has dimension
1. A filled-in square has dimension 2. But a coastline — jagged at every scale,
with bays inside bays inside bays — lives in between, with a dimension like 1.25.
That fractional number is the fingerprint of the shape. The work described here
proves, with complete rigor, that under a large and natural class of repeated
warpings, **that fingerprint never changes, no matter how many times you iterate
the warp.** The crinkliness is conserved.

This article tells the story of why that is true, and why the proof turns out to
hinge on one surprisingly humble idea: that the right inequality, simply *read
in the opposite direction*, gives you something you thought you didn't have.

---

## Crinkliness has a number

Let's make "crinkliness" honest. Cover your shape with tiny balls of radius
ε. Count how many you need. For a smooth line, halving ε roughly doubles the
count — the count grows like (1/ε)¹, and that exponent 1 is the dimension. For a
square, halving ε quadruples the count — growth like (1/ε)², dimension 2. For a
fractal coastline, the count grows like (1/ε)^d for some d strictly between 1 and
2. That exponent d is the **Hausdorff dimension**, written `dimH`. It is the
single most important invariant in fractal geometry, the thing that distinguishes
the Koch snowflake (dimension ≈ 1.26) from the Sierpiński triangle
(dimension ≈ 1.58) from an ordinary smooth circle (dimension exactly 1).

The Hausdorff dimension is famously *delicate*. Bend a shape a little and the
dimension can, in principle, jump. So the natural question becomes: **which
transformations leave it alone?** Which warpings are "dimension-blind"?

---

## Three rules of distortion

There is a clean three-part answer, and it is worth stating carefully because the
whole story grows out of it.

A map `f` is called **Lipschitz with constant K** on a set `s` if it never
stretches distances by more than a factor of K:

> for all points x, y in s:  distance(f(x), f(y)) ≤ K · distance(x, y).

Lipschitz maps are the "controlled stretchers." A foundational fact is that they
can never *increase* dimension:

> **Rule 1 (controlled stretching can't add crinkliness).** If `f` is Lipschitz
> on `s`, then `dimH(f(s)) ≤ dimH(s)`.

A map is **Hölder with exponent r** (a number between 0 and 1) if it can stretch,
but in a tamed, sub-linear way:

> distance(f(x), f(y)) ≤ C · distance(x, y)^r.

Hölder maps with small exponent are the "wild stretchers" — the snowflake-makers.
They *can* increase dimension, but by a controlled amount:

> **Rule 2 (wild stretching multiplies crinkliness by 1/r).** If `f` is Hölder of
> exponent r on `s`, then `dimH(f(s)) ≤ dimH(s) / r`.

Finally, a map is **antilipschitz with constant K'** if it never *squeezes* too
much — distances are recoverable from their images:

> distance(x, y) ≤ K' · distance(f(x), f(y)).

Antilipschitz maps are the "anti-collapsers." They can never *decrease* dimension:

> **Rule 3 (no collapsing means no loss of crinkliness).** If `f` is
> antilipschitz, then `dimH(s) ≤ dimH(f(s)).`

Put Rule 1 and Rule 3 together — a map that is *both* Lipschitz and antilipschitz,
called **bi-Lipschitz** — and you get the headline of classical fractal geometry:
bi-Lipschitz maps preserve Hausdorff dimension exactly. They are the
dimension-blind transformations. Stretch and squeeze all you like, as long as you
keep both factors bounded, and the fingerprint survives.

---

## The gap nobody had filled

Here is where the story turns. Rules 1 and 2 are general and flexible: they apply
to maps defined *only on the set you care about*. You can have a transformation
that does something crazy elsewhere in space, but as long as it is Lipschitz *on
your coastline*, Rule 1 fires.

Rule 3 — the anti-collapsing rule, the one that protects dimension from *below* —
was, in the standard formal libraries of mathematics, only available for maps
defined and antilipschitz **everywhere**. There was no "set-local" version. If
your map was only antilipschitz on the coastline itself, you were stuck. The
lower bound, the half of the argument that says "you can't lose crinkliness," had
a hole in it.

This matters enormously, because the most important maps in fractal geometry —
the ones that *generate* fractals — are self-maps defined on the fractal, mapping
it into itself. Iterated function systems, dynamical attractors, conjugacies
between dynamical systems: these all live on a set and act on that set. A theory
of dimension-preservation that can't talk about set-local maps is a theory that
can't talk about the very objects it was invented for.

---

## The keystone: an inequality read backwards

The central realization — the conceptual heart of this entire body of work — is
that **the missing lower bound is not new mathematics at all.** It is the
*existing* upper bound (Rule 1), applied to the inverse map.

Here is the trick in full. Suppose `f` is antilipschitz on `s`. The first thing
that buys you is that `f` is **injective** on `s`: if `f(x) = f(y)`, then the
antilipschitz inequality says distance(x,y) ≤ K' · distance(f(x),f(y)) =
K' · 0 = 0, so x = y. No two points get glued together. Because `f` is injective
on `s`, it has a genuine inverse `g` defined on the image `f(s)`, sending each
output back to the unique input it came from.

Now read the antilipschitz inequality again, but treat the *images* as your
variables. The inequality

> distance(x, y) ≤ K' · distance(f(x), f(y))

is, word for word, the statement that the inverse map `g` is **Lipschitz with
constant K'** on the image set `f(s)`. Anti-collapsing of `f` *is* controlled
stretching of `g`. The two notions are the same fact viewed from opposite ends.

And once `g` is Lipschitz, Rule 1 — which we already had — fires on `g`:

> dimH( g(f(s)) ) ≤ dimH( f(s) ).

But `g(f(s))` is just `s` again (the inverse undoes the map). So

> dimH(s) ≤ dimH(f(s)),

which is exactly the missing Rule 3, now proved *set-locally*, with no global
hypotheses on `f` whatsoever. The hole is filled. In the formal development this
is the theorem `AntilipschitzOnWith.le_dimH_image`, and it is the load-bearing
keystone of everything that follows.

The lesson is almost philosophical: anti-collapsing and controlled-stretching are
mirror images of one another, and the lower bound for one map is the upper bound
for its reflection.

---

## From one warp to a thousand

With the keystone in place, the bi-Lipschitz invariance becomes a two-line
sandwich: Rule 1 gives `dimH(f(s)) ≤ dimH(s)`, the new keystone gives the reverse
inequality, and antisymmetry pins them together to `dimH(f(s)) = dimH(s)`. This is
the theorem `dimH_image_eq`: **a set-local bi-Lipschitz map preserves Hausdorff
dimension.**

Now the iteration. This is the part that turns a static fact into a dynamical one.

The crucial structural observation is that these distortion classes are **closed
under composition**, and the constants behave exactly as you'd hope. If `f` is
Lipschitz with constant Kf and `g` is Lipschitz with constant Kg, then `g∘f` is
Lipschitz with constant Kf·Kg. The same multiplicativity holds for the
antilipschitz constants (theorem `AntilipschitzOnWith.comp`), and for Hölder maps
the *exponents* multiply: composing exponent rf with exponent rg gives exponent
rg·rf.

Feed a map into itself. Suppose `f` maps the set `s` into itself (`s` is
*invariant*) and is bi-Lipschitz on `s` with constants K and K'. Then the n-fold
iterate `f^[n] = f∘f∘···∘f` is, by composing the constants n times:

- Lipschitz with constant **Kⁿ**  (theorem `lipschitzOnWith_iterate`),
- antilipschitz with constant **K'ⁿ**  (theorem `antilipschitzOnWith_iterate`).

Both constants are finite for every finite n. So `f^[n]` is *still* bi-Lipschitz
on `s`, and our invariance theorem applies to it directly. The conclusion is the
main result of this cycle:

> **Main Theorem (`dimH_image_iterate_eq`).** If `f` maps `s` into itself and is
> set-local bi-Lipschitz on `s`, then for *every* number of iterations n,
>
> dimH( f^[n](s) ) = dimH(s).

The crinkliness of the orbit pieces is a **constant sequence**. It does not drift,
does not erode, does not amplify. Restated (`dimH_image_iterate_const`): the
function n ↦ dimH(f^[n](s)) is constant — the dimension is a genuine **fixed
point of the dynamics**. This is the precise sense in which a fractal "survives
its own reflection" a thousand times over.

---

## When the warp is wild: the shrinking corridor

What if `f` is not bi-Lipschitz but genuinely Hölder — a wild stretcher with
exponent r < 1? Then dimension is no longer conserved; it can grow. But it grows
in a perfectly controlled way. Since the exponent of `f^[n]` is **rⁿ**
(theorem `holderOnWith_iterate`), Rule 2 applied to the iterate gives:

> **Theorem (`dimH_image_iterate_le`).** dimH( f^[n](s) ) ≤ dimH(s) / rⁿ.

Because r < 1, the quantity 1/rⁿ explodes geometrically. Each iteration of a wild
map can multiply the dimension bound by a fixed factor 1/r. This is the formal
shadow of a real phenomenon: repeatedly applying a snowflaking transformation
inflates dimension geometrically until it saturates at the dimension of the
ambient space. The theorem gives a hard, certified ceiling on how fast that
inflation can happen.

---

## Why this is more than bookkeeping

It would be easy to dismiss all of this as careful accounting — multiply the
constants, apply the rule, done. But three things make it matter.

**First, it unlocks the right objects.** The whole apparatus of modern fractal
geometry — self-similar sets, attractors of iterated function systems, the
dimension theory of dynamical systems — is built on self-maps of a set. By
delivering a *set-local* lower bound, this work lets the dimension-preservation
theorem be aimed at exactly those maps, rather than at the idealized
globally-defined maps that rarely occur in practice.

**Second, it reveals a hidden algebraic structure.** Distortion exponents
*multiply* under composition. That is the signature of a homomorphism: the act of
composing maps corresponds to multiplying numbers. The discrete iterates studied
here — words in a single generator `f` — are the first slice of a much larger
object: the free monoid on a whole family of maps, with distortion exponents
forming a multiplicative homomorphism into the positive reals. The fractal's
geometry is shadowed by an algebra of exponents.

**Third, it makes the "fixed point" picture literal.** The slogan that "a
fractal's dimension is the fixed point of its generating dynamics" is usually a
heuristic. Here it becomes a theorem: the sequence of orbit-piece dimensions is
provably constant, so the dimension is, quite literally, fixed by the iteration.
Pair that constancy with a separation condition (a "Moran open set condition"
ensuring the pieces don't overlap too much) and the common value gets pinned to
the classical *similarity dimension* log(m)/log(1/K) of an m-map system — the
formula at the root of all of self-similar fractal geometry.

---

## The shape that survives

Strip away the machinery and what remains is a small, durable truth. There is a
number that measures how intricate a shape is. There is a broad family of
transformations — stretch as you like, squeeze as you like, just keep both
bounded and never glue or collapse — and these transformations cannot change that
number, not once, not a thousand times. And the proof that they cannot rests on a
single reflection: that the rule protecting dimension from above, when you look at
it in a mirror, is exactly the rule protecting it from below.

A coastline fed through the machine a thousand times is still, to the precision of
its fingerprint, the same coastline. The crinkliness is conserved. That
conservation law, and the mirror that proves it, is the shape that survives its
own reflection.
