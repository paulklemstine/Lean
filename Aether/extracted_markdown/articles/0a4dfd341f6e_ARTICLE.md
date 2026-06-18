# The Geometry of Roughness, and Why It Survives Being Folded Twice

## A coastline that never smooths out

Stand on a beach and try to measure the coastline. With a kilometre-long ruler you
trace a crude polygon and read off a length. Switch to a metre stick and the length
grows: now you catch every cove the kilometre ruler skated past. Switch to a
centimetre ruler and it grows again — every pebble, every notch, adds its little
detour. The coastline does not converge to a number. It is *too rough* to have a
length in the ordinary sense.

What it has instead is a **dimension** — but not the comfortable dimension of school
geometry, where a line is 1, a square is 2, a cube is 3. A coastline lives somewhere
*between* a line and a plane: its **Hausdorff dimension** might be 1.25. The famous
middle-thirds Cantor set — take a segment, delete the open middle third, repeat
forever on the pieces that remain — has dimension exactly log 2 / log 3 ≈ 0.6309.
It is more than a scatter of points (dimension 0) but less than a line (dimension 1).
This single number is the most honest summary of how complicated a set is at every
scale at once.

The story of this article is about one deceptively simple question: **what happens to
this number when you bend, stretch, or fold the set?** And in particular, what
happens when you do two such transformations in a row — the operation mathematicians
call *composition*. The answer turns out to be both clean and powerful, and it is the
hidden engine behind the entire theory of fractals.

## Maps that respect roughness

To talk about bending and stretching precisely, we need a vocabulary for maps between
spaces. Imagine a map `f` that takes points of one space to points of another. The
key question is always: *how does `f` treat distances?*

A **Lipschitz** map is one that never stretches distances by more than a fixed factor.
If `K` is the factor, then for any two points `x` and `y` in our set,

> distance(f x, f y) ≤ K · distance(x, y).

Lipschitz maps are the "tame" maps: they can squash, fold, and crumple, but they can't
explode distances. A crucial fact, classical and intuitive, is that **a Lipschitz map
can never increase Hausdorff dimension**. Squashing can only simplify; it cannot
manufacture new roughness out of nothing. In symbols, if `f` is Lipschitz on a set
`s`, then the image `f(s)` has dimension at most that of `s`.

The mirror image of this idea is what we will call an **antilipschitz** map. Where a
Lipschitz map refuses to *stretch* too much, an antilipschitz map refuses to *crush*
too much. Formally, with a constant `K`,

> distance(x, y) ≤ K · distance(f x, f y).

Read it carefully: it says the original distance can't be much larger than the image
distance, i.e. the map never collapses two distinct points too aggressively. The first
thing such a map guarantees is that it is **injective** on the set — if `f x = f y`
then the right side is zero, forcing `x = y`. An antilipschitz map keeps points apart,
and the consequence for geometry is the exact dual of the Lipschitz fact: **an
antilipschitz map can never *decrease* dimension**. If `f` is antilipschitz on `s`,
then `f(s)` has dimension at least that of `s`.

Put the two together and something beautiful happens. A map that is *both* Lipschitz
and antilipschitz — a **bi-Lipschitz** map — can neither raise nor lower dimension.
It preserves it exactly:

> If `f` is Lipschitz and antilipschitz on `s`, then dim f(s) = dim s.

This is the single most important rigidity theorem about fractals. Hausdorff dimension
is a *bi-Lipschitz invariant*. You can rotate, translate, smoothly warp, and locally
distort a Cantor set as much as you like; as long as you don't tear it apart or fuse
its points, that magic number log 2 / log 3 will not budge.

## The softer maps: Hölder and the art of the snowflake

Lipschitz is sometimes too strict. Nature, and mathematics, are full of maps that are
"continuous but worse than Lipschitz" near small scales. The right notion is **Hölder
continuity** with an exponent `r` between 0 and 1:

> distance(f x, f y) ≤ C · distance(x, y)^r.

When `r = 1` this is just Lipschitz again. When `r < 1`, the map can roughen things:
because raising a small distance to a power less than one *increases* it, a Hölder map
with exponent `r` is allowed to spread nearby points apart, injecting roughness. The
classical example is the **snowflake** construction: take a metric and replace each
distance `d` by `d^r`. Distances near zero get magnified, and a smooth curve becomes a
jagged fractal — the von Koch snowflake is the spiritual ancestor of this idea.

Hölder maps distort dimension in a precise, quantitative way. A Hölder map with
exponent `r` can multiply dimension by at most `1/r`:

> If `f` is Hölder with exponent `r > 0` on `s`, then dim f(s) ≤ dim s / r.

Since `1/r ≥ 1` when `r ≤ 1`, this confirms the intuition: snowflaking *inflates*
dimension. Now suppose `f` has an inverse `g` that is *also* Hölder, with its own
exponent. Then you get a **two-sided** estimate, trapping the image dimension between
two multiples of the original. This is the analytic heart of **quasi-symmetric**
geometry — the study of maps that preserve relative sizes and shapes "up to bounded
distortion," the maps that conjugate one fractal to another. Concretely, if `f` is
Hölder with exponent `rf` and its inverse is Hölder with exponent `rg`, then

> dim f(s) ≤ dim s / rf   and   dim s ≤ dim f(s) / rg.

These two inequalities are the quantitative license plate of every fractal that is a
"snowflaked copy" of another.

## The real prize: roughness composes

Everything above is about a *single* map. But fractals are never built from a single
map. The Cantor set is built by applying the same shrinking rule *over and over*. The
Mandelbrot and Julia sets come from *iterating* a function. Quasi-symmetric maps are
glued together from good maps on overlapping pieces. The substance of fractal geometry
is **chaining transformations** — and a theory of distortion that cannot handle chains
is, frankly, useless.

So the decisive question is: *if I apply one good map, and then another, what do I
get?* This is the contribution at the centre of our story, and the answer is as clean
as one could hope.

**First, the antilipschitz class is closed under composition.** If `f` keeps points
apart on `s` with constant `Kf`, and `g` keeps points apart on the image `f(s)` with
constant `Kg`, then the composite `g ∘ f` (do `f` first, then `g`) keeps points apart
on `s` with constant `Kf · Kg`:

> If `f` is antilipschitz on `s` (constant `Kf`) and `g` is antilipschitz on `f(s)`
> (constant `Kg`), then `g ∘ f` is antilipschitz on `s` with constant `Kf · Kg`.

The proof is a two-step chain of the defining inequalities, and the constants simply
multiply — exactly as they do for Lipschitz maps, whose composition law has been known
for a century. This is the missing dual, and it completes the symmetry.

Two small but essential companions come along for free. **Restriction:** if a map keeps
points apart on a big set, it keeps them apart on any smaller set inside it — roughness
control is inherited downward. **Global implies local:** a map that is antilipschitz
everywhere is, in particular, antilipschitz on any individual set you care to name. These
two facts are what let us zoom in on a single fractal piece and still wield the full
theory.

**Second — the corollary that fractal geometers actually use — bi-Lipschitz invariance
composes.** If `f` is bi-Lipschitz on `s` and `g` is bi-Lipschitz on the image `f(s)`,
then the composite `g ∘ f` preserves Hausdorff dimension:

> dim (g ∘ f)(s) = dim s.

This is the statement that makes the whole edifice usable. It says that dimension is
invariant not just under one nice change of coordinates, but under *any finite chain of
them*. You can pass a fractal through a whole pipeline of distortions — one for each
nested generation of an iterated construction — and as long as every link in the chain
is bi-Lipschitz, the dimension that comes out the far end equals the dimension that went
in.

## The grand finale: exponents multiply

The deepest result generalises both the composition law and the snowflake estimate at
once. Suppose `f` is Hölder with exponent `rf` (with a Hölder inverse of exponent
`rf'`), and `g` is Hölder with exponent `rg` (with a Hölder inverse of exponent `rg'`).
Chain them. Then the composite `g ∘ f` distorts dimension with the **products** of the
exponents:

> dim (g ∘ f)(s) ≤ dim s / (rg · rf)   and   dim s ≤ dim (g ∘ f)(s) / (rf' · rg').

This is the "law of multiplied snowflakes." Snowflake a space by exponent `rf`, then
snowflake the result by exponent `rg`, and the net effect on dimension is governed by
the single exponent `rf · rg`. Distortion budgets *multiply* down a pipeline, never
worse than the worst link, exactly as engineers intuit when they cascade approximations.

And the punchline ties the whole article into a bow: set every exponent equal to 1, and
the Hölder maps become Lipschitz, the products `rg · rf` and `rf' · rg'` become 1, and
the two inequalities collapse into a single equality — `dim (g ∘ f)(s) = dim s`. The
composite bi-Lipschitz invariance is just the exponent-one shadow of the composite
Hölder law. One theorem, with a dial labelled "roughness," and the whole spectrum from
exact rigidity to controlled snowflaking falls out as you turn it.

## Why this matters beyond the page

It is tempting to file all this under "abstract nonsense about weird sets." It is
anything but. Hausdorff dimension and its invariance laws are the working tools of:

- **Dynamical systems and chaos.** Strange attractors — the geometric skeletons of
  chaotic motion, from weather to fluid turbulence — are fractals, and their dimension
  is a fundamental physical invariant. Because the dynamics are built by *iterating* a
  map, the composition law is exactly what guarantees the dimension is a property of the
  attractor itself and not an artefact of which coordinates you chose.

- **Image and signal analysis.** The fractal dimension of a texture, a medical scan, or
  a financial time series is a quantitative fingerprint. Knowing that bi-Lipschitz
  preprocessing (rescaling, smooth warping, sensor calibration) cannot change it is what
  makes the fingerprint trustworthy across instruments.

- **Geometric group theory and rigidity.** Quasi-symmetric maps between the boundaries
  of negatively-curved spaces are the modern language of Mostow-style rigidity, and the
  product-exponent law is the dimensional accounting behind those arguments.

- **Iterated function systems and computer graphics.** Every procedurally generated
  fractal landscape is a composition of contractions. The composition closure proven
  here is the formal guarantee that the dimension of the final scene is the dimension
  the artist designed into the rules.

The Cantor set's dimension is log 2 / log 3 whether you draw it on paper, encode it in a
camera, warp it through a lens, or iterate it a billion times in software. That
permanence is not an accident. It is a theorem — now nailed down, composition and all.
Roughness, it turns out, is one of the most durable things in mathematics. You can fold
it, snowflake it, and chain a dozen transformations on top of one another, and the
number that measures it will look you calmly in the eye, unchanged.
