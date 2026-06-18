# The Arithmetic of Roughness: How Distortion Multiplies When You Chain Maps

## A ruler that never quite fits

Hand someone a coastline and a ruler and ask them to measure it. With a one-kilometre
ruler they get one number. Switch to a one-metre ruler and the answer balloons, because
the smaller ruler dives into bays and around headlands the big ruler stepped over. Shrink
the ruler again and the length grows again. A coastline has no single length — it has a
*rate of growth*, a number that says how fast detail keeps appearing as you look closer.

That number is the **fractal dimension**, and it is one of the most quietly radical ideas
in modern mathematics. A smooth curve has dimension 1. A filled square has dimension 2.
But a coastline, a lightning bolt, the boundary of a cloud, the branching of a lung — these
live in between. The famous Koch snowflake, built by repeatedly replacing the middle third
of each line segment with a little triangular spike, has dimension exactly
log 4 / log 3 ≈ 1.262: more than a line, less than a region, infinitely wrinkled at every
scale.

The version of fractal dimension we care about here is the **Hausdorff dimension**, the
gold-standard definition that Felix Hausdorff introduced in 1918. It is delicate and
beautiful, and it has one property that makes the rest of this story possible: it is
*intrinsic*. It does not care how you draw the set, only about the set itself, measured by
its own internal distances.

This article is about a single, sharp question: **what happens to the Hausdorff dimension of
a fractal when you push it through a map?** Stretch it, fold it, bend it, snowflake it — does
the dimension survive? And — the real heart of the matter — when you apply *one map after
another*, how do their separate effects combine?

The answer, which has now been verified down to the last logical atom in a formal proof
system, is unexpectedly clean: **the distortions multiply**.

## Maps that behave, and maps that misbehave

To talk about dimension changing, we need to classify the maps we are allowed to use. There
are three families, arranged from gentlest to wildest.

**Lipschitz maps** are the well-mannered ones. A map *f* is Lipschitz with constant *K* on a
set *s* if it never stretches distances by more than a factor of *K*:

> for all points *x*, *y* in *s*,  distance(*f(x)*, *f(y)*) ≤ *K* · distance(*x*, *y*).

Think of squeezing a rubber sheet: you can compress it as much as you like, but you cannot
tear it, and you cannot blow up two nearby points to be wildly far apart. The crucial fact —
classical, and the foundation of everything below — is that **a Lipschitz map can never
increase Hausdorff dimension**. Squeezing can only simplify. In symbols, writing *dimH* for
Hausdorff dimension and *f(s)* for the image,

> dimH( *f(s)* ) ≤ dimH( *s* ).

**Antilipschitz maps** are the dual idea, and the one this work makes precise. A map *f* is
antilipschitz with constant *K* on *s* if it never *collapses* distances too much:

> for all *x*, *y* in *s*,  distance(*x*, *y*) ≤ *K* · distance(*f(x)*, *f(y)*).

Read it the other way: points that end up close after *f* must have started reasonably close.
The map is not allowed to crush a large, complicated set into a tiny simple blob. The mirror
image of the Lipschitz fact holds: **an antilipschitz map can never decrease Hausdorff
dimension**,

> dimH( *s* ) ≤ dimH( *f(s)* ).

A map that is *both* Lipschitz and antilipschitz is called **bi-Lipschitz**. It is the
fractal geometer's notion of "the same shape": it can stretch and shrink, but only within
fixed bounds, so it preserves the rate at which detail appears. The combination of the two
one-sided facts gives the cornerstone result:

> **Bi-Lipschitz invariance.** If *f* is bi-Lipschitz on *s*, then dimH( *f(s)* ) = dimH( *s* ).

Hausdorff dimension is a bi-Lipschitz invariant. Two fractals related by a bi-Lipschitz map
have *exactly* the same dimension, no matter how violently one is bent into the other.

**Hölder maps** are the wild family, and where the real subtlety lives. A map is Hölder with
exponent *r* (a number between 0 and 1) if

> distance(*f(x)*, *f(y)*) ≤ *C* · distance(*x*, *y*)^*r*.

When *r* = 1 this is just Lipschitz. But when *r* < 1 the map can *manufacture roughness*.
Raising a small distance to a power less than 1 makes it relatively larger, so a Hölder map
with exponent *r* can inflate dimension — by a factor of as much as 1/*r*. This is exactly the
mathematics of "snowflaking", the operation that turns a smooth interval into something with
the fractal texture of the Koch curve. The two-sided estimate, when *f* and its inverse are
both Hölder, reads:

> **Two-sided Hölder distortion.** dimH( *f(s)* ) ≤ dimH( *s* ) / *r_f*  and
> dimH( *s* ) ≤ dimH( *f(s)* ) / *r_g*,

where *r_f* is the exponent of the forward map and *r_g* the exponent of the inverse. The
dimension is trapped in a corridor whose width is governed by the Hölder exponents.

These results form the backdrop. They are the "single-map" theory: take one map, see what it
does to dimension. They are genuinely useful — but they are not enough.

## Why one map is never enough

Here is the catch that motivates everything new in this work. **Fractals are not built from
single maps. They are built from chains of maps.**

Consider how fractals actually arise:

- An **iterated function system** — the standard machine for generating the Cantor set, the
  Sierpiński triangle, fern leaves — *is* a composition. You apply a handful of contractions,
  then apply them again to the result, then again, forever. The fractal is the fixed point of
  this endlessly repeated chaining.
- A **conjugacy** in dynamics — the statement that two systems are "the same" after a change
  of coordinates — is a sandwich *g* ∘ *f* ∘ *g*⁻¹. Three maps composed.
- A **quasi-symmetric map**, the natural notion of "same shape up to controlled distortion"
  in fractal geometry and the theory of hyperbolic groups, is analysed precisely by breaking
  it into Hölder pieces on nested scales and *composing the estimates*.

A theory of dimension distortion that only handles one map at a time is like a theory of
arithmetic that can add but cannot add three numbers. To be usable, the good classes of maps
must be **closed under composition**, and we must know exactly how the distortion constants and
exponents combine when we chain. Supplying that missing arithmetic is the contribution here.

## The composition laws

Three structural facts make the antilipschitz class — the dimension-*lower-bound* class,
historically the more awkward of the two — into a robust, composable theory.

**Composition multiplies the constants.** If *f* is antilipschitz with constant *K_f* on *s*,
and *g* is antilipschitz with constant *K_g* on the image *f(s)*, then the composite *g* ∘ *f*
is antilipschitz on *s* with constant *K_f* · *K_g*. The proof is a clean two-step chain:
*f* guarantees distance(*x*, *y*) ≤ *K_f* · distance(*f(x)*, *f(y)*), and *g*, applied to the
already-moved points, guarantees distance(*f(x)*, *f(y)*) ≤ *K_g* · distance(*g(f(x))*,
*g(f(y))*). Substitute one into the other and the constants multiply. This is the exact mirror
of the long-known composition law for Lipschitz maps.

**Restriction is free.** If a map is antilipschitz on a set *s*, it is automatically
antilipschitz, with the *same* constant, on any smaller piece inside *s*. Good behaviour on a
whole inherits to every part — exactly what you need when an iterated function system carves a
fractal into ever-finer nested cells.

**Global implies local.** A map that is antilipschitz everywhere is antilipschitz on every
subset. This is the bridge that lets you import a globally well-behaved map — a linear
embedding, a smooth diffeomorphism — into the set-local theory without losing anything.

With these in hand, the payoff theorems follow.

**Composite bi-Lipschitz invariance.** If *f* is bi-Lipschitz on *s* and *g* is bi-Lipschitz
on *f(s)*, then *g* ∘ *f* is bi-Lipschitz on *s*, and therefore

> dimH( (*g* ∘ *f*)(*s*) ) = dimH( *s* ).

Stack any number of "same-shape" maps and the result is still the same shape. Dimension
sails through the entire chain untouched. This is what licenses the standard move in fractal
geometry of analysing an iterated system one stage at a time and concluding something about
the limit.

## The punchline: exponents multiply

The crown of the work is what happens when you chain the *wild* Hölder maps — the ones that
can actually change dimension.

Suppose *f* is Hölder with exponent *r_f* (with a Hölder inverse of exponent *r_f′*), and *g*
is Hölder with exponent *r_g* (with a Hölder inverse of exponent *r_g′*). What is the composite
*g* ∘ *f*? Applying one Hölder bound after another, a distance raised to the power *r_f* gets
raised again to the power *r_g* — and (*d*^*r_f*)^*r_g* = *d*^(*r_g* · *r_f*). **The exponents
multiply.** The composite is Hölder with exponent *r_g* · *r_f*, and the dimension corridor
tightens accordingly:

> **Composite quasi-symmetric distortion.**
> dimH( (*g* ∘ *f*)(*s*) ) ≤ dimH( *s* ) / (*r_g* · *r_f*)  and
> dimH( *s* ) ≤ dimH( (*g* ∘ *f*)(*s*) ) / (*r_f′* · *r_g′*).

This is the single most important formula in the package, and it has a satisfying internal
logic. The dimension-distortion factor of a chain is the *product* of the distortion factors
of the links. Snowflake an interval by exponent 1/2, then snowflake the result by exponent
1/2 again, and you have multiplied dimension by up to 4 — exactly as if you had snowflaked
once by exponent 1/4. Roughness, manufactured in stages, accumulates multiplicatively.

And the whole story is internally consistent: set every Hölder exponent equal to 1, and the
Hölder maps become Lipschitz, the product *r_g* · *r_f* becomes 1, and the corridor collapses
to the single equality dimH( (*g* ∘ *f*)(*s*) ) = dimH( *s* ). The general product law and the
exact-invariance law are not two separate facts; the second is the first, seen at exponent 1.

## Why "set-local" is the right altitude

A subtle but important design choice runs through all of this: every statement is **set-local**.
The maps are not required to be Lipschitz, antilipschitz, or Hölder on some entire ambient
space — only on the specific set *s* we care about, and the next map only on the image of that
set.

This is not fussiness; it is necessity. Real fractals live inside larger spaces where the
governing maps misbehave almost everywhere. A contraction of an iterated function system is
beautifully bi-Lipschitz on the attractor and irrelevant off it. A dynamical conjugacy is
controlled on an invariant set and wild outside. By keeping every hypothesis confined to the
exact set in play — and, crucially, by having each map's hypothesis live on the *image* of the
previous one — the composition laws chain together without ever needing a single global
assumption. This is what makes the theory actually deployable on the objects it was designed
for.

## What it means

Strip away the formalism and the message is almost philosophical. Fractal dimension is the
measure of how complicated a set is across scales. Maps can simplify it (Lipschitz), refuse to
oversimplify it (antilipschitz), preserve it (bi-Lipschitz), or actively complicate it
(Hölder). The question this work settles is how those powers *compose* — and the answer is the
most orderly one imaginable. Preservation composes to preservation. Bounded distortion
composes to bounded distortion. And the wild, dimension-inflating power of Hölder maps composes
*multiplicatively*, exponent times exponent.

There is a deeper reason this matters now. Every one of these statements has been checked by a
formal proof system, which means there is no hidden gap, no "it is easy to see that", no
appeal to a picture. The composition of distortion estimates — historically the kind of
argument where constants quietly go astray and exponents get misremembered — is now nailed
down with the same certainty as 2 + 2 = 4. The arithmetic of roughness has been audited, and
it balances: when you chain the maps, the distortions multiply.
