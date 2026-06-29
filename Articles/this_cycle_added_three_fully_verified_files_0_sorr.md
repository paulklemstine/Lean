# The Shape of Data Doesn't Care What You Call It

## A story about persistence, smoothing, and the freedom to rename

Imagine you are handed a cloud of points — the locations of cell-towers across a
country, the genomes of a viral outbreak, the firing patterns of neurons in a
slice of brain. You want to know its *shape*: Does it cluster into islands? Are
there loops, tunnels, hollow voids? This is the central question of **topological
data analysis**, and over the last two decades it has grown from a curiosity into
a working tool used in oncology, materials science, neuroscience, and cosmology.

The engine that drives it is an idea of disarming simplicity. Take your points and
start growing a ball around each one. When two balls touch, draw an edge. When
three pairwise-touching balls all overlap, fill in the triangle. Keep growing. At
radius zero you have nothing but isolated dots; at enormous radius everything is
fused into one blob. In between — and this is the magic — features are *born* and
later *die*. A loop appears at one scale and gets filled in at a larger one. A
cluster splits off and later merges back. The record of these births and deaths,
read across all scales at once, is a remarkably stable fingerprint of the data's
shape. This growing family of shapes is called a **filtration**, and the
fingerprint is its **persistence**.

This article is about a small but foundational truth concerning filtrations — one
of those facts that feels obvious once stated but must be nailed down with care
before any of the towering theorems above can stand. It is the principle that the
shape of your data **does not depend on what you call your data points.** Rename
the cell towers, shuffle the genome labels, permute the neuron indices — the
geometry you extract is exactly, provably, the same. And a companion principle:
once you have measured *one* shape precisely, you get the measurement for all of
its renamings, and for whole equivalence classes of shapes, completely for free.

These sound like truisms. They are not. Making them precise — and proving them
rather than assuming them — is what turns persistence from a heuristic into
mathematics.

---

## Filtrations as tropical weightings

Let us be concrete. Fix a set of labels — call them vertices. A **simplex** is
just a finite collection of vertices: a single point, a pair (an edge), a triple
(a triangle), and so on. A **filtration** is a rule that assigns to every simplex
a number, its *appearance time* — the scale at which it first shows up as you grow
the balls. Write `weight(σ)` for the appearance time of the simplex `σ`.

Two rules govern these weights:

- **Monotonicity.** If a simplex `σ` is contained in a larger simplex `τ`, then
  `σ` appears no later than `τ`: `weight(σ) ≤ weight(τ)`. You cannot build a
  triangle before its edges exist.
- **Grounding.** The empty simplex — the trivial "nothing" — sits at the bottom.

This is the entire definition, and it has a beautiful second reading. In **tropical
mathematics** one replaces ordinary addition by *taking minimums* and ordinary
multiplication by *addition*. In that arithmetic, a filtration is precisely a
tropical weighting of simplices, and the operations we are about to meet are the
natural tropical transformations. That is why we call this circle of ideas the
**categorical tropical Rips** picture — "Rips" after the Vietoris–Rips complex,
the ball-growing construction above.

Two operations on filtrations sit at the heart of the story.

**Smoothing (the shift).** Pick a non-negative number `a`. The *shift by `a`*
lowers every appearance time uniformly:

> `(shift a F).weight(σ) = F.weight(σ) − a`.

Everything is born `a` units earlier. In the tropical dictionary this is the
additive smoothing operator; in the ball-growing picture it is what you see if you
start with the balls already grown to radius `a`. Crucially, smoothing respects
both governing rules: lowering every weight by the same amount preserves order and
keeps the ground grounded.

**Relabeling (the comap).** Suppose you have a dictionary `e` that translates every
label in one vocabulary into a unique label in another, and back again — a perfect
one-to-one correspondence, what mathematicians call an *equivalence*. Given a
filtration `F` written in the second vocabulary, you can *pull it back* into the
first: to find the appearance time of a simplex `σ` in your vocabulary, translate
its vertices through the dictionary and look up the time in `F`:

> `(comap e F).weight(σ) = F.weight( e(σ) )`.

This is renaming, formalized. It is the act of relabeling your cell towers,
shuffling your genomes, permuting your neurons.

---

## How different are two shapes? The interleaving distance

To say "the same shape" we need a way to measure *how far apart* two filtrations
are. The accepted answer is the **interleaving distance**, and it is elegant.

Two filtrations `F` and `G` are said to be **δ-interleaved** if each can be made to
sit inside the other after a smoothing by `δ`: everything that has appeared in `F`
by scale `t` has appeared in `G` by scale `t + δ`, and vice versa. The smaller the
`δ` you can get away with, the more alike the two filtrations are. The
**interleaving distance** is the smallest such `δ`:

> `interleavingDist(F, G) = inf { δ ≥ 0 : F and G are δ-interleaved }`.

For the appearance-time filtrations we are discussing, this distance has a wonderfully
concrete face: it is simply the largest disagreement in appearance times across all
simplices,

> `interleavingDist(F, G) = sup_σ | F.weight(σ) − G.weight(σ) |`.

If `F` and `G` never differ by more than `δ` on any simplex, they are
`δ`-interleaved; and the worst single simplex sets the distance. This is the
quantity proved stable under perturbation in the famous stability theorems of
topological data analysis — wiggle your data a little and the persistence
fingerprint moves only a little. Here it is the stage on which our two principles
play out.

Two immediate consequences anchor everything else:

- **A shift moves you by exactly its size.** Smoothing a filtration by `a` displaces
  it by precisely `a`: `interleavingDist(F, shift a F) = a`. Every simplex moved by
  the same `a`, so the worst disagreement *is* `a`. The shift is a clean, calibrated
  ruler.
- **The distance is genuinely a distance.** It is zero between a filtration and
  itself, it is symmetric, and it satisfies the triangle inequality — the
  hallmarks of a metric (here an *extended* one, since infinite distances are
  allowed for infinitely large vocabularies).

---

## The first principle: renaming changes nothing

Now the centerpiece. Take any two filtrations `F` and `G` in some vocabulary, and
any perfect dictionary `e`. Relabel both. The claim is that they are exactly as
interleaved as before — neither more nor less:

> **Relabeling invariance of interleaving.** For every renaming `e` and every
> scale `δ`, the relabeled pair `comap e F` and `comap e G` is δ-interleaved if and
> only if the original pair `F` and `G` is.

This biconditional is the technical heart, and the reason it holds is the reason
renaming *ought* to be invisible: a witness that `F` slides into `G` after
smoothing translates, vertex by vertex through the dictionary `e`, into a witness
for the relabeled pair, and the dictionary's inverse translates it back. Nothing is
created or destroyed in translation.

From this single equivalence, the quantitative statements fall out at once:

> **Distances are renaming-invariant.**
> `interleavingDist(comap e F, comap e G) = interleavingDist(F, G)`,
> and the same holds for the version that allows infinite distances.

The infimum of a set of admissible `δ`'s cannot change if the *set* of admissible
`δ`'s does not change — and we just proved it does not. So the number is identical.
In plain terms: **the interleaving distance is blind to labels.** It is a property
of the shape, not of the spreadsheet.

A pleasant compatibility lemma rides alongside: **smoothing and renaming commute.**
Whether you smooth first and then relabel, or relabel first and then smooth, you
land on exactly the same filtration:

> `comap e (shift a F) = shift a (comap e F)`.

The two fundamental operations don't interfere. This is the kind of "naturality"
that makes a construction trustworthy: it behaves the same no matter the order in
which you apply the moves.

---

## Quotients: when "the same shape" becomes a single point

Here the story deepens. If two filtrations have interleaving distance *zero*, they
are, for every purpose that the distance can detect, identical — even if their
weight functions differ on some technicality. The honest thing to do is to *glue
them together*, collapsing each family of distance-zero filtrations into a single
point. The result is a new space — call it the space of *shape classes* — in which
the interleaving distance becomes a true, point-separating metric: distinct classes
sit at strictly positive distance, and the only way to be at distance zero is to be
the same class.

The renaming invariance survives this collapse perfectly:

> **Invariance descends to shape classes.** The genuine distance between the class
> of `comap e F` and the class of `comap e G` equals the genuine distance between
> the class of `F` and the class of `G`.

So even in the cleaned-up world of shape classes — the natural home of persistence,
where Mathlib-style metric topology, completeness, and continuity all become
available — relabeling remains invisible. The shape is the shape.

---

## The second principle: measure once, transport everywhere

The final movement of the piece is the most useful in practice. Suppose you have
done the hard work of *exactly* computing some self-smoothing distance for a
particular filtration `F`: you have established, say, that smoothing `F` by `a`
moves it by precisely `a`,

> `interleavingDist(F, shift a F) = a`.

This is the kind of sharp, hard-won equality (not just an inequality) that takes
real effort to pin down for a specific filtration. The **transport principle** says
you never have to do that work twice:

> **Transport across renamings.** If `interleavingDist(F, shift a F) = a`, then for
> *every* relabeling `e`,
> `interleavingDist(comap e F, shift a (comap e F)) = a`.

The proof is a two-line miracle made possible by the lemmas above: smoothing
commutes with relabeling, so `shift a (comap e F)` is the same as
`comap e (shift a F)`; and relabeling preserves distance, so the equation simply
carries over. One exact measurement, infinitely many free corollaries — one for
every way of renaming your data.

And it goes further still, all the way down to the quotient:

> **Transport into shape classes.** Any exact self-smoothing distance for `F`
> transfers to the genuine distance between the shape classes of `comap e F` and
> its smoothing.

So a single precise statement about one filtration becomes a precise statement
about an entire orbit of renamed filtrations *and* their idealized shape classes,
with no additional labor.

---

## Why this matters

It is tempting to wave all of this away as bookkeeping. It is not. Every applied
pipeline in topological data analysis implicitly assumes that the answer doesn't
depend on the arbitrary order in which the data arrived, or the arbitrary names of
the samples. When that assumption is *proved* rather than presumed, three things
happen.

First, **algorithms become trustworthy.** If your software relabels points for
efficiency — sorting them, hashing them, distributing them across machines — you
now have a guarantee that the relabeling cannot corrupt the geometric answer.

Second, **computation becomes cheaper.** The transport principle is a license to
compute a distance on the most convenient representative of a shape and read off
the answer for all the others. In a world where these computations are expensive,
free corollaries are precious.

Third, and most deeply, **the right objects come into focus.** By collapsing
distance-zero filtrations into shape classes, we stop studying spreadsheets and
start studying shapes. The interleaving distance, once a comparison of two
arbitrary tables of numbers, becomes a genuine metric on a space of pure geometric
content — exactly the setting in which the great stability theorems of the field
live, and exactly the setting that the renaming and transport principles make
rigorous.

There is a tropical undertone to the whole composition. In min-plus arithmetic the
shift is addition and interleaving is a tropical comparison; the fact that renaming
commutes with smoothing is the statement that relabeling is a *tropical-linear*
symmetry of the whole structure. Persistence, smoothing, and the freedom to rename
turn out to be three facets of one min-plus gem.

The data has a shape. It does not care what you call it. And once you have measured
that shape once, carefully, you have measured it everywhere.
