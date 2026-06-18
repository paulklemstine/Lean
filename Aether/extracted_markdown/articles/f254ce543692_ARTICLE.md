# When Distance Itself Has a Closed Form: The Shape of Persistence

## A measuring tape for shape

Imagine you are handed a cloud of points — galaxies scattered across a survey,
atoms in a protein, pixels in a scan, or readings from a swarm of sensors — and
asked a deceptively simple question: *what shape is this?* Not the shape of any
single point, but the shape of the whole, the loops and voids and clusters that
only appear when you step back and squint.

The modern mathematical answer to this question is **persistent homology**, the
flagship tool of *topological data analysis*. The idea is to grow a structure
out of the data. Start with the bare points. Then, as you slowly turn a dial — a
scale parameter — connect points that are close, fill in triangles among triples
that are mutually close, and so on. At every scale you get a shape; as the dial
turns, features are *born* (a loop appears) and later *die* (the loop fills in).
The list of these births and deaths is the data's topological fingerprint.

A fingerprint is only useful if it is *stable*: nudge the data a little, and the
fingerprint should change only a little. Otherwise noise would drown the signal.
This is the celebrated **stability theorem** of persistence, and the natural
notion of "distance between fingerprints" it controls is the **interleaving
distance**. Two growing shapes are *δ-interleaved* if each one, shifted forward
by δ along the scale dial, contains the other. The interleaving distance is the
smallest such shift. It is, in a precise sense, *the* metric of the subject.

This article is about a sharp and beautiful fact: in a natural finite setting,
the interleaving distance is not merely controlled by how much the data
changed — it is *exactly equal* to it. The abstract, infimum-over-all-shifts
definition collapses into a single elementary formula. Persistence is not just
stable. It is an **isometry**: a perfect, distortion-free measuring tape.

## Filtrations as weight functions

To say this precisely we need a clean model of "a growing shape." We use the
most economical one possible.

Fix a finite vocabulary of vertices (the data points). A **simplex** is just a
finite set of vertices — an edge is a pair, a triangle is a triple, and so on.
A **filtration** is a rule that assigns to each simplex σ a real number, its
**weight** w(σ): the scale at which that simplex is *born*. Two conditions make
this a sensible growing shape:

- **Grounded:** the empty simplex is born by scale zero, w(∅) ≤ 0.
- **Monotone:** if one simplex is contained in another, σ ⊆ τ, then it is born
  no later: w(σ) ≤ w(τ). (A triangle cannot appear before its edges.)

That's the entire definition. A filtration *is* a monotone, grounded weight
function on finite sets. At each scale t, the shape you see is the **sublevel
complex**: all simplices with w(σ) ≤ t. As t rises, the complex only grows.

This little structure is enough to host the whole theory. Two filtrations F and G
are **δ-interleaved** (for δ ≥ 0) when their sublevel complexes shift into each
other:

> every simplex alive in F by scale t is alive in G by scale t + δ, and vice
> versa.

The **interleaving distance** d(F, G) is the infimum of all δ for which this
holds. (We measure it in the extended nonnegative reals, allowing the value ∞ when
no finite shift works — the honest answer when the two shapes are
incomparable.)

## The isometry formula

Here is the central result.

> **The Isometry Formula.** For any two filtrations F and G,
> $$ d(F, G) \;=\; \sup_{\sigma}\, \bigl|\,w_F(\sigma) - w_G(\sigma)\,\bigr|. $$
> The interleaving distance equals the supremum, over every simplex σ, of the gap
> between the two birth times.

The right-hand side is as concrete as it gets: look at every simplex, see how
much its birth scale moved between F and G, and take the worst case. That single
number *is* the interleaving distance — not an upper bound for it, not a quantity
that controls it, but the thing itself.

Why is this surprising? The left-hand side is defined by an optimization over an
infinite family of shifts and a quantifier over all scales and all simplices
simultaneously. A priori, the best interleaving might be cleverer than the naive
"just shift by the worst gap" strategy — perhaps some subtle coordination across
scales beats it. The formula says no: the naive strategy is optimal, and the
optimum is *attained*, at every scale, not just in the limit.

The proof rests on one elementary but decisive observation, the engine of the
whole result:

> **Interleaving is exactly uniform closeness.** Two filtrations are
> δ-interleaved if and only if δ ≥ 0 and every simplex's two birth times are
> within δ of each other:
> $$ \text{F and G are } \delta\text{-interleaved} \iff \delta \ge 0 \text{ and }
> \forall \sigma,\ |w_F(\sigma) - w_G(\sigma)| \le \delta. $$

One direction is the classical stability theorem: if all the weights are within δ,
the sublevel families shift into one another, so the filtrations interleave. The
*converse* is the new content, and it is almost embarrassingly direct. Suppose F
and G are δ-interleaved. To bound the gap at a particular simplex σ, simply test
the interleaving at the precise scale where σ is born. Plugging the birth time
t = w_F(σ) into "everything alive in F by t is alive in G by t + δ" forces
w_G(σ) ≤ w_F(σ) + δ; testing at t = w_G(σ) gives the reverse. Together they pin
the gap to within δ. The sublevel order encodes the weight order *exactly*, so
"the families shift into each other" is literally "the weights are close."

Once interleaving and weight-closeness are the same condition, the infimum
defining the distance becomes an infimum over sup-norm bounds — and the infimum of
"all δ that dominate the worst gap" is just the worst gap. The formula falls out.
(A small but pleasant subtlety: working in the *extended* reals makes this
unconditional. If the weight gaps are unbounded, both sides equal ∞, which is
exactly right: no finite shift can interleave shapes that drift apart without
limit.)

## A free corollary: telling shapes apart

The formula instantly recovers a basic sanity check. The distance between F and G
is zero **if and only if** F equals G:
$$ d(F, G) = 0 \iff F = G. $$
For the distance to vanish, the worst weight gap must be zero, so every weight
agrees, so the filtrations are identical (a filtration is nothing but its weight
function). This is the *T0 separation* property — distinct shapes are never at
distance zero — and here it is a one-line consequence of the closed form rather
than a separate theorem.

## Persistence is a functor — and a short one

With the metric pinned to a sup-norm on weight functions, the structural
landscape opens up. The most useful move is to ask how distance behaves under
**relabeling** the vertices.

Given any map f from one vertex set to another, there is a natural **pullback**:
to weigh a simplex σ downstairs, push it forward through f and read off its weight
upstairs,
$$ (f^{*}G)(\sigma) \;=\; w_G\bigl(f(\sigma)\bigr). $$
(Here f(σ) is the image set of σ under f.) Because taking images respects
inclusions, the pullback of a filtration is again a filtration. And pullback is
**contravariant and functorial**: relabeling by the identity does nothing, and
relabeling by a composite g∘f is the same as relabeling by f and then by g (in the
reversed order). Persistence is a genuine functor.

The isometry formula then delivers a clean stability principle for free:

> **Pullback is 1-Lipschitz.** For any vertex map f and any filtrations F, G,
> $$ d(f^{*}F,\; f^{*}G) \;\le\; d(F, G). $$
> Relabeling can only *shrink* distances. Persistence maps short maps to short
> maps.

The reason is pure bookkeeping over the formula. The simplices downstairs, pushed
through f, land among the simplices upstairs; so the supremum of weight gaps
downstairs ranges over a *subset* of the gaps upstairs, and a supremum over a
subset can only be smaller.

When does relabeling preserve distance exactly? Precisely when f is **surjective**
— when every simplex upstairs is hit by something downstairs:

> **Pullback along a surjection is an isometry.** If f is onto, then
> $$ d(f^{*}F,\; f^{*}G) \;=\; d(F, G). $$

A surjection makes the reindexing cover *all* the upstairs simplices, so no gap is
lost and the two suprema coincide.

This is also a quiet correction to an earlier conjecture, which had guessed that
*injective* maps preserve distance. They do not: an injection from a small vertex
set into a strictly larger one leaves simplices upstairs untouched, and F and G can
disagree wildly on exactly those untouched simplices — so the pullback distance can
fall strictly below the true one. Surjectivity, not injectivity, is the right
hypothesis. The closed form makes the difference transparent: what matters is
whether the reindexing *covers* the index set, and only a surjection does.

## A representation theorem: classifying all shapes

The final payoff is a complete classification. We already know a filtration *is*
its weight function — distinct weight functions give distinct filtrations
(injectivity). The converse asks: which functions arise as weights? The answer is
exactly the obvious ones.

> **Representation Theorem.** Every monotone, grounded function w on finite sets —
> one with w(∅) ≤ 0 and w(σ) ≤ w(τ) whenever σ ⊆ τ — is the weight function of one
> and only one filtration.

So the map "filtration ↦ weight function" is a perfect bijection onto the set of
monotone, grounded functions. Combined with the isometry formula, this means:

> The space of filtrations under the interleaving distance is, **up to a faithful
> distance-preserving identification**, nothing more and nothing less than the
> monotone, grounded functions equipped with the sup-distance.

Every question about the geometry of persistence — how far apart two shapes are,
how relabeling moves them, how sequences of shapes converge — translates without
loss into an elementary question about monotone functions in the supremum norm.
The rich, infinitary machinery of interleavings becomes calculus on functions.

## Why this matters

Topological data analysis earned its place in science because its summaries are
*stable*: small perturbations of the data produce small perturbations of the
fingerprint. That stability is usually stated as an inequality — a one-sided
guarantee that the distance is *no larger* than the perturbation. The results here
sharpen the inequality into an *equality*. In this finite combinatorial model the
fingerprint loses nothing and adds nothing: the distance between two shapes is
precisely the worst-case shift of a birth time.

Three consequences make this more than an aesthetic improvement.

First, **computation becomes trivial in principle.** To compare two filtrations
you need not search over shifts or interleavings; you scan the simplices, take the
largest birth-time gap, and stop. The hard-looking metric is a one-pass maximum.

Second, **functoriality is automatic.** Relabeling data — coarsening a sensor
grid, merging duplicate points, projecting onto a feature — is a short map, and
when it is onto it is an exact isometry. This is precisely the behavior you want
from a robust summary: aggregation never inflates distances, and faithful
aggregation preserves them.

Third, **the whole theory is classified.** The space of persistence summaries is
identified, on the nose, with a familiar object: monotone functions under the
sup-norm. Completeness, limits, approximation — all the questions a working data
analyst eventually asks — can be answered there, in territory that is already well
mapped.

There is a methodological moral too. A great deal of mathematics is a chain of
one-sided estimates, each bounding the next, never quite meeting. Now and then the
estimates close into a loop and an *equality* emerges. When that happens the
subject changes character: geometry becomes bookkeeping, theorems become
calculations, and what looked like a deep optimization reveals itself as a simple
maximum. The interleaving distance — long the abstract heart of a deep stability
theory — turns out, in this clean finite world, to have been a closed form all
along. Sometimes the deepest thing you can prove about a measuring tape is that it
measures exactly.
