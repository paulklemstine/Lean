# The Shape of Data, Measured Exactly

## When two point clouds look almost the same, *how* almost?

Imagine two scans of the same coffee mug. One was taken with a slightly miscalibrated
laser, so every measured distance is off by a hair. The two resulting clouds of points
are not identical, but they are *close*. A natural and surprisingly deep question lurks
here: if you feed both clouds through a pipeline that extracts their *shape* — the loops,
the voids, the connected pieces — how different can the two shapes possibly be?

This is the central question of **topological data analysis** (TDA), and the standard
answer is reassuring but vague: "the shapes change continuously with the data." The
pipeline is *stable*. Nudge the input a little, and the output moves a little. But by
*how much*, exactly? For decades the working bound was a one-sided promise: the output
moves *no more than* the input. That is enough to trust the method, but it leaves a gap.
Maybe the output barely moves at all. Maybe the shape-extraction smooths away most of the
perturbation. We did not know.

This article is about closing that gap completely. The result, formalized and
machine-checked, is as sharp as a result can be:

> **The distance between the shapes equals, exactly, the worst-case difference in the data.**

Not "at most." *Equals.* The shape pipeline neither inflates nor deflates the distance
between two datasets. It is, in the precise mathematical sense, an **isometry** — a
perfect, distortion-free translation from the language of data to the language of shape.

Let us unpack how data becomes shape, what "distance between shapes" even means, and why
the equality is both surprising and, in hindsight, inevitable.

## From points to a growing family of shapes

The engine of TDA is an idea called a **filtration**. Instead of building one shape from
your data, you build a whole *movie* of shapes, indexed by a scale parameter that we will
call `t`.

Start with your data points as dust — no connections. Now slowly turn a dial. As the
scale `t` grows, you start drawing edges between points that are close, then triangles
among triples that are mutually close, then higher-dimensional "simplices" among larger
mutually-close clusters. At scale `t = 0` you see only dust; as `t → ∞` everything fuses
into one solid blob. In between, loops appear and disappear, voids open and close. The
features that *persist* across a long stretch of the dial are the real shape of the data;
the ones that flicker in and out are noise. This is **persistent homology**.

To make this precise we record, for each possible simplex `σ` (a vertex, an edge, a
triangle, …), the exact moment it is *born* — the smallest scale at which it appears. Call
that number its **weight**, `w(σ)`. A filtration is, at heart, nothing more than this
assignment of birth times, subject to two utterly natural rules:

- **The empty simplex is born at the start:** `w(∅) ≤ 0`.
- **Bigger simplices are born no earlier than their parts:** if `σ ⊆ τ` then
  `w(σ) ≤ w(τ)`. (A triangle cannot exist before its edges do.)

That is the entire definition. Formally, a filtration `F` on a vertex set is a function
`w : Finset(vertices) → ℝ` satisfying those two monotonicity rules. The shape at scale
`t` — written `F.sublevelFaces t` — is simply the collection of every simplex born by
then:

> `F.sublevelFaces t = { σ : w(σ) ≤ t }`.

The canonical example is the **Vietoris–Rips** construction. Given a table of pairwise
distances `d(x, y)` among your data points, the birth time of a simplex `σ` is its
*diameter* — the largest distance between any two of its vertices:

> `diamWeight(σ) = max over x, y in σ of d(x, y)`.

A pair of points becomes an edge once the dial reaches their separation; a triangle
appears once the dial reaches its longest side. This single recipe turns any distance
table into a filtration, and hence into a movie of shapes.

## Measuring the distance between two movies

Now we have two datasets, two filtrations `F` and `G`, two movies of shapes. How do we
measure how different they are?

The accepted answer is the **interleaving distance**, and the intuition is delightfully
physical. Suppose I claim the two movies are "the same up to a time-shift of `δ`." I am
claiming that if you take any frame of movie `F` at scale `t` and fast-forward movie `G`
by `δ`, then `G` already contains everything `F` showed — and symmetrically the other way
around. Formally, two filtrations are **`δ`-interleaved** (for `δ ≥ 0`) when

> for every scale `t`,  `F.sublevelFaces t ⊆ G.sublevelFaces (t + δ)`
> and `G.sublevelFaces t ⊆ F.sublevelFaces (t + δ)`.

Each movie, slowed by `δ`, contains the other. The smaller the `δ` you can get away with,
the more similar the movies. The **interleaving distance** is the best (smallest) such
shift:

> `interleavingDist(F, G) = inf { δ : F and G are δ-interleaved }`.

There is a subtlety lurking here. Sometimes *no* finite shift works — the movies are
qualitatively different and no amount of fast-forwarding aligns them. To handle this
cleanly, the honest home for the interleaving distance is the **extended** non-negative
reals `[0, ∞]`, where an empty set of valid shifts correctly returns `∞` rather than a
misleading `0`. Written `eInterleavingDist`, this version satisfies all the axioms of a
distance: it is symmetric, it vanishes exactly on identical movies, and it obeys the
triangle inequality.

This interleaving distance is the gold-standard yardstick of TDA. It is, however,
defined by an *optimization* — an infimum over a whole continuum of possible shifts. That
makes it powerful but opaque. You cannot read it off the data directly; you have to,
in principle, search.

## The surprise: the optimization has a closed-form answer

Here is the punchline. Define the most naive possible comparison of two filtrations: just
look at every simplex `σ`, compare its birth time in `F` with its birth time in `G`, and
take the worst discrepancy across all simplices:

> `weightSupDist(F, G) = sup over σ of | w_F(σ) − w_G(σ) |`.

This is the "sup-distance of the weight functions." It requires no optimization, no
searching over shifts — it is a direct, term-by-term comparison of birth times. It is the
crudest thing you could write down.

The main theorem says this crude quantity **is** the sophisticated interleaving distance,
on the nose:

> **Isometry Theorem.** For any two filtrations `F` and `G`,
> `eInterleavingDist(F, G) = sup over σ of | w_F(σ) − w_G(σ) |`.

The elaborate, optimization-defined yardstick collapses to a one-line formula. The best
possible time-shift between the two movies is precisely the largest gap in birth times.

Why is this both surprising and, in retrospect, forced? It splits into two halves, and
each is illuminating.

**Half one: the interleaving distance is at least the worst gap.** Suppose `F` and `G` are
`δ`-interleaved. Take any simplex `σ`. In movie `F` it is born at time `w_F(σ)`, so it is
present in `F.sublevelFaces(w_F(σ))`. By the interleaving, it must therefore be present in
`G.sublevelFaces(w_F(σ) + δ)` — meaning `G` gives it birth no later than `w_F(σ) + δ`,
i.e. `w_G(σ) ≤ w_F(σ) + δ`. Running the same argument with the roles swapped gives
`w_F(σ) ≤ w_G(σ) + δ`. Together: `|w_F(σ) − w_G(σ)| ≤ δ`. So *every* valid shift `δ`
dominates *every* birth-time gap. The best shift therefore dominates the worst gap. This
is the formalized lemma **`interleaved_iff_weightCloseBy`** in its forward direction —
"interleaving forces uniform closeness of weights" — and it is proved by exactly this
move: evaluate the interleaving inclusions at the two natural birth times.

**Half two: the worst gap is itself an achievable shift.** This is the deeper half, and it
is where the older theory stopped short. Let `D` be the worst birth-time gap,
`D = sup_σ |w_F(σ) − w_G(σ)|`, and suppose it is finite. The classical
**Cohen–Steiner–Edelsbrunner–Harer stability theorem** — here in the form
**`stability_supDist`** — says precisely that if all birth times agree to within `D`, then
the two filtrations *are* `D`-interleaved. So `D` is not merely a lower bound on the
achievable shifts; it is *itself* one of them. The infimum defining the interleaving
distance is therefore **attained**: there is an honest, realized `D`-interleaving, and no
shift smaller than `D` can work because of half one.

Put the two halves together and the infimum is pinned exactly to `D`. The optimization
has a winner, and the winning value is the formula. In the formalization these are the
twin lemmas **`weightSupEDist_le_eInterleavingDist`** (half one) and
**`eInterleavingDist_le_weightSupEDist`** (half two), combined into the headline
**`eInterleavingDist_eq_weightSupEDist`**.

## Why "attained" is the whole story

It is worth pausing on the word *attained*, because it is the conceptual hinge.

An infimum is a *boundary*: the smallest value you can approach. But approaching is not the
same as reaching. The number `0` is the infimum of all positive numbers, yet no positive
number equals it. For years, the interleaving distance was understood only at the level of
*approaching*: one knew that the distance was `0` exactly when the two movies could be
aligned with arbitrarily tiny shifts — shifts squeezing down toward zero but perhaps never
hitting it. That is a *limiting* description, and limiting descriptions are slippery. Could
two genuinely different datasets be alignable with ever-smaller shifts, never quite
reaching a perfect alignment, and so sit at distance `0` while being distinct? If so, the
"distance" would fail to tell points apart — a defect.

The resolution, established just before this result and now generalized by it, is that the
infimum is *reached*. Distance `0` does not mean "approachable by tiny shifts"; it means
"there is a literal `0`-shift alignment," which forces the birth times to be *equal*, which
forces the filtrations to be *equal*. No two distinct datasets hide at distance zero. The
yardstick genuinely separates points. As a one-line corollary of the isometry formula
(**`weightSupEDist_eq_zero_iff_eq`**), the worst birth-time gap is zero precisely when the
two filtrations coincide.

The isometry theorem is the same phenomenon writ large: the infimum is attained not just at
the boundary value `0`, but at *every* value. Whatever the worst gap `D` happens to be,
there is an actual `D`-interleaving realizing it. "Approaching" and "reaching" coincide
everywhere, and that is exactly why a searching optimization collapses to a closed form.

## What this buys us

Three consequences are worth spelling out, because they change how one can think about the
whole pipeline.

**Persistence is a perfect translator.** Map each dataset to its weight function — its
table of birth times — sitting inside the space of all such functions under the sup-distance.
The isometry theorem says this map preserves distances *exactly*. The space of filtrations,
under the interleaving distance, is a faithful copy of a piece of an ordinary
sup-normed function space. Everything we know about such well-behaved spaces — limits,
completeness, approximation — transfers over verbatim. The exotic-sounding interleaving
geometry is, underneath, the most familiar geometry there is: the geometry of "largest
coordinate-wise difference."

**Stability is tight, not just safe.** The classical guarantee was an inequality:
distort the data by `ε`, and the shape moves by *at most* `ε`. We now know it is an
equality: the shape moves by *exactly* the worst distortion. There is no hidden smoothing,
no free noise reduction. This is bracing news. It means the pipeline is exactly as
sensitive to a single bad measurement as the worst birth-time it produces — you cannot
hope that downstream topology will quietly average away an outlier. But it is also
empowering: the interleaving distance, expensive to compute by its definition, can now be
read off directly as a maximum of `|w_F(σ) − w_G(σ)|` over simplices.

**A concrete check you can run by hand.** Take a perfect unit triangle: three points, all
pairwise distances `1`. Now take a slightly swollen triangle: three points, all pairwise
distances `1.1`. Build both Vietoris–Rips filtrations. Every simplex with at least two
distinct vertices — the three edges and the one triangle — is born at `1` in the first
movie and at `1.1` in the second; the single-vertex and empty simplices are born at `0` in
both. The worst birth-time gap is therefore `|1 − 1.1| = 0.1`. The isometry theorem
declares, with no further work, that the interleaving distance between these two clouds is
*exactly* `0.1` — matching the `0.1` perturbation in the data, neither more nor less. (The
accompanying numerical demonstration walks through this and several richer examples.)

## The moral

There is a recurring pattern in mathematics where a quantity is first known only by an
elaborate variational definition — an infimum, a supremum, an optimization — and only later
revealed to have a clean closed form. Each such collapse is a small act of demystification:
what looked like a search turns out to be a formula. The interleaving distance, the
cornerstone of the stability theory that makes topological data analysis trustworthy, joins
that list. Its elaborate definition as the best of all possible time-shifts between two
growing families of shapes is, in the end, just the largest gap between two tables of birth
times.

The pipeline that turns data into shape neither adds nor hides distance. It tells the
truth, exactly. Persistence is an isometry.
