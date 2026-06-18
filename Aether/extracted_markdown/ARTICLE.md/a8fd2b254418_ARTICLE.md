# When Crumpled Maps Compose: How Distortion Adds Up on Fractals

## A ruler that lies — but lies in a controlled way

Imagine you are handed a map of a coastline. Not a clean political map, but a
real, jagged, infinitely wrinkled coastline — the kind that looks equally rough
whether you photograph it from orbit or from a low-flying drone. Now imagine the
map you were given is *distorted*. Distances on the page do not match distances
in the world. A centimeter near the harbor might be a kilometer; a centimeter
near the cliffs might be ten kilometers.

If the distortion were random, the map would be useless. But suppose the
distortion is *bounded*: there is a worst-case stretching factor and a worst-case
shrinking factor, and neither ever blows up to infinity or collapses to zero.
Such a map — one that can stretch and squeeze, but only within fixed limits — is
called **bi-Lipschitz**. It is the mathematician's idea of a map that is
"honest up to a constant."

Here is the first surprising fact, and the foundation of everything that
follows: **a bi-Lipschitz map cannot change the roughness of a coastline.** The
precise measure of roughness is the *Hausdorff dimension*, a number that is `1`
for a smooth curve, `2` for a filled-in square, and something strictly in
between — like `1.26` — for a genuinely fractal coastline. Stretch the coastline,
squeeze it, fold the page: as long as you never stretch or squeeze by more than a
fixed factor, that fractal dimension number is exactly preserved.

This is a beautiful piece of geometry. But it has a catch, and that catch is the
real subject of this article.

## The catch: real maps are only good *somewhere*

The clean theorem above assumes the map behaves well *everywhere*. Real maps
almost never do. A photograph behaves well in the center and warps badly at the
edges. A change of coordinates that tames one fractal may go haywire on the rest
of the plane. The maps that actually arise when we study fractals — the maps that
build the Koch snowflake out of smaller copies of itself, the conjugacies that
turn one dynamical system into another, the "quasi-symmetric" maps that allow the
distortion factor to drift gently with scale — are good *only on the particular
piece you care about*.

So mathematicians need a **set-local** theory: a calculus of distortion that
applies to a map which is bounded and honest *only on a chosen subset* `s`, and
says nothing about its behavior elsewhere. The groundwork for this was laid in an
earlier chapter of this project. There, three results were established for a
single map `f` restricted to a set `s`:

- **Set-local bi-Lipschitz invariance.** If `f` neither stretches nor shrinks
  `s` by more than fixed factors, then the image `f(s)` has *exactly* the same
  Hausdorff dimension as `s`.
- **Set-local antilipschitz lower bound.** If `f` merely refuses to *over-shrink*
  `s` (the "antilipschitz" condition: `edist x y ≤ K · edist(f x, f y)`), then
  the image can be no *less* rough than the original: `dimH s ≤ dimH(f(s))`.
- **Two-sided Hölder distortion.** If `f` is only *Hölder* — a weaker form of
  control where distances are raised to a power `r` before being compared — then
  the dimension is squeezed between `dimH s / r_f` on one side and
  `dimH s / r_g` on the other, where `r_f` and `r_g` are the Hölder exponents of
  the map and its inverse. Setting the exponents to `1` recovers exact
  invariance.

That earlier work answered the question for *one* map. But fractals are never
built from one map.

## Why composition is the whole game

A fractal is, almost by definition, a thing made by *repetition*. The Koch curve
is four copies of itself, each one-third the size. The Sierpiński gasket is three
copies. An "iterated function system" — the standard machine for manufacturing
fractals — is precisely a recipe for chaining maps together, over and over, on
nested pieces. The same is true of the conjugacies that compare two fractals: to
show two attractors are "the same" up to controlled distortion, you compose a map
from the first to a model with a map from the model to the second.

So a distortion calculus that cannot handle **composition** — the chaining of one
good map after another — is not yet a usable tool. It is like a theory of
addition that only works for single numbers. The central question of this chapter
is therefore simple to state:

> If `f` is well behaved on `s`, and `g` is well behaved on the image `f(s)`,
> is the composite `g ∘ f` well behaved on `s` — and how do the distortion
> bounds combine?

The answer, proved here, is as clean as one could hope: **the classes are closed
under composition, and the distortion exponents multiply.**

## The composition theorems, stated plainly

The heart of this work is a small family of theorems, each a link in a single
chain of reasoning.

**1. Antilipschitz maps compose, and their constants multiply.**
The set-local antilipschitz condition says a map will not crush distances by more
than a factor `K`. The theorem `AntilipschitzOnWith.comp` says: if `f` won't
crush `s` by more than `K_f`, and `g` won't crush the image `f(s)` by more than
`K_g`, then the composite `g ∘ f` won't crush `s` by more than the product
`K_f · K_g`. The proof is a two-step chain: first `f`'s guarantee, then `g`'s
guarantee applied at the image points, multiplied together. This is the exact
mirror image — the "dual" — of the long-known fact that Lipschitz maps compose
with multiplied constants.

**2. Good behavior restricts to smaller pieces.**
The theorem `AntilipschitzOnWith.mono` records something intuitively obvious but
logically essential: if a map is honest on a set `s`, it is honest on every
subset `t ⊆ s`, with the same constant. You can always zoom in.

**3. Global control implies local control.**
The theorem `antilipschitzOnWith_of_antilipschitzWith` says that a map which is
antilipschitz *everywhere* is, in particular, antilipschitz on any chosen set.
This bridges the new set-local theory to the classical global one, so nothing is
lost by working locally.

**4. Composites of bi-Lipschitz maps preserve dimension.**
Now the payoff begins. Because both Lipschitz and antilipschitz control survive
composition, a composite of two set-local *bi-Lipschitz* maps is itself
bi-Lipschitz on `s`. The theorem `dimH_image_comp_eq_of_lipschitzOn_antilipschitzOn`
therefore concludes that

> `dimH((g ∘ f)(s)) = dimH s`.

Chain as many honest maps as you like; the fractal dimension never moves. This is
the rigorous statement of the intuition we opened with — extended from a single
map to an arbitrarily long pipeline of maps.

**5. The headline: composite quasi-symmetric distortion, with multiplied
exponents.**
The deepest result, `dimH_image_comp_bounds_of_biholderOn`, handles the general
Hölder (quasi-symmetric flavored) case. Suppose `f` is bi-Hölder on `s` with
forward exponent `r_f` and inverse exponent `r_f'`, and `g` is bi-Hölder on the
image with exponents `r_g` and `r_g'`. Then the composite obeys the two-sided
bound

> `dimH((g ∘ f)(s)) ≤ dimH s / (r_g · r_f)`   and
> `dimH s ≤ dimH((g ∘ f)(s)) / (r_f' · r_g')`.

The exponents do not add, do not average — they **multiply**. The forward squeeze
factor of the pipeline is the product of the forward squeeze factors; the inverse
squeeze factor is the product of the inverse ones. And if every exponent equals
`1` (the bi-Lipschitz case), both products collapse to `1` and the inequalities
pinch shut to exact equality — recovering theorem 4 as a special case, an
internal consistency check that the whole edifice fits together.

## Why "multiply" is the right and beautiful answer

There is a reason multiplication is the natural law here, and it is worth
savoring. A Hölder map with exponent `r` distorts *scale* by raising it to the
power `r`: a small distance `δ` becomes roughly `δ^r`. Compose two such maps and
the scales transform as `δ → δ^{r_f} → (δ^{r_f})^{r_g} = δ^{r_f · r_g}`. Powers
of powers multiply their exponents — that is the algebra of nested rescaling. The
dimension bound simply reads this scaling law off at the level of the whole
fractal. The geometry of "roughening a rough thing" is governed by the same rule
as `(x^a)^b = x^{ab}` from school algebra. That a deep statement about fractal
coastlines reduces to a law about exponents is exactly the kind of unity that
makes mathematics feel inevitable.

## The bigger picture: distortion as a category

Step back and a pattern emerges. We have a collection of *objects* (fractal
pieces, each a set with a dimension) and a collection of *morphisms* (the good
maps between them). The morphisms compose. The composition is associative. There
is an identity map that changes nothing. And there is a *numerical invariant* —
the distortion exponent — that behaves multiplicatively as you travel along a
chain of morphisms.

This is the signature of a **category** with a multiplicative functor to the
numbers. The theorems above are, quietly, the proof that set-local bi-Hölder maps
form such a structure, and that Hausdorff dimension distortion is a functor on
it. Once you see distortion calculus this way, the future directions almost write
themselves: assemble the maps into a genuine category or groupoid, study the
invariants that survive, and lift the whole theory to the moduli of fractals.

## What this is good for

Beyond the inner beauty, the composition law is the working tool of fractal
analysis:

- **Iterated function systems.** Attractors are fixed points of composed
  contractions. The composition law lets you track how dimension is controlled
  through every level of the construction without re-proving anything.
- **Quasi-symmetric rigidity.** To show two fractals are "the same shape" you
  build a conjugacy by gluing local maps. The multiplied-exponent bound tells you
  exactly how much dimension can drift across the whole conjugacy — and when it
  cannot drift at all.
- **Dynamical systems.** Comparing the long-term behavior of two systems means
  composing coordinate changes. The invariance theorem certifies that fractal
  invariants of strange attractors are genuinely intrinsic, not artifacts of the
  coordinates.

## The moral

The single-map theorems told us that an honest map preserves roughness. The
composition theorems tell us something far more useful: **honesty is contagious
along a pipeline, and distortion accumulates by multiplication, not by chance.**
You can now build a fractal the way it is actually built — one good map at a time,
on one nested piece at a time — and know in advance, with certainty, exactly what
happens to its dimension. The ruler may lie at every step. But the lies multiply
in a way we can read off completely, and when the maps are bi-Lipschitz, the lies
cancel and the truth comes through unchanged.
