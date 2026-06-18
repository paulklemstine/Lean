# The Shape of "Provable": A Tour Through the Geometry of Self-Reference

## A sentence that talks about itself

In 1931 Kurt Gödel taught mathematics a humbling lesson. Any formal system
strong enough to talk about ordinary arithmetic can write down a sentence that,
read carefully, says *"I am not provable."* If the system could prove that
sentence it would be wrong; if it could disprove it, it would again be wrong.
The only way out is for the sentence to be true but unprovable. Mathematics, it
turned out, can describe truths it cannot reach.

A second, sharper shock followed. Gödel's second theorem says that a consistent
system can never prove its *own* consistency. The statement "I never contradict
myself" is exactly one of those true-but-unreachable sentences. A theory can
gaze at its own reflection but can never certify that the reflection is sound.

For decades these results felt like isolated paradoxes — clever tricks with
self-reference. Then logicians discovered something beautiful: the entire
phenomenon of provability obeys a small, crisp set of algebraic laws. Bundle
those laws together and you get a tiny logical system called **GL**, after
**G**ödel and the Norwegian logician Martin **L**öb. GL is the algebra of the
word *"provable."* And the remarkable thing is that this algebra has a *shape*.
You can draw it.

This article is about that shape — and about a recent set of machine-checked
results that map out its geometry with surprising precision. We will meet
worlds arranged in well-founded trees, an "ordinal ruler" that measures how deep
self-reference can go, a tower of stronger and stronger notions of provability,
and a delicate asymmetry that explains why GL is fundamentally a logic of
*possibility* rather than *necessity*. No formal training is assumed; only
curiosity.

## Worlds you can see from here

The key idea that turns provability into geometry is due to Saul Kripke and,
for GL specifically, Krister Segerberg. Imagine a collection of **worlds**.
Some worlds can "see" others through an **accessibility relation**, written
`R`. If world `w` can see world `v`, we write `R w v`. Think of `v` as a
*possible future* of `w`, or — closer to the logic of provability — as a
*stronger, more committed theory* that `w` can imagine adopting.

A statement is **necessary** at a world if it holds in *every* world that world
can see. In modal notation we write this with a box: `□S` is the set of worlds
all of whose visible worlds satisfy `S`. Dually, a statement is **possible** if
it holds in *some* visible world; we write this with a diamond: `◇S`.

For GL, two rules govern who can see whom:

- **Irreflexivity**: no world can see *itself*. (`R w w` is forbidden.)
- **Transitivity**: if `w` sees `v` and `v` sees `u`, then `w` sees `u`.

Together with finiteness, these define a **GL frame**. In the formal
development the structure is recorded exactly this way: a type of `World`s, a
relation `R`, a proof that `R` is irreflexive, and a proof that `R` is
transitive.

Why irreflexivity? Because of Gödel's second theorem. The box `□` is meant to
read as "is provable." A world seeing itself would let a theory certify its own
soundness — precisely what Gödel forbade. Irreflexivity is the geometric
fingerprint of *"no theory proves its own consistency."*

These two innocent rules have an iron consequence. Because the relation is
transitive and irreflexive and the world-set is finite, you can never travel
forward forever. Any path `w → w₁ → w₂ → ⋯` must eventually stop. In the
language of order theory, the *reverse* of the accessibility relation is
**well-founded**. Formally this is the theorem `flip_wellFounded`: the converse
of accessibility in any GL frame is a well-founded relation. Every chain of
"more committed theories" terminates at a dead end. There is always a last
word.

## An ordinal ruler for self-reference

Here is where the geometry acquires a *measuring tape*.

Whenever a relation is well-founded, mathematics hands you a free gift: an
**ordinal rank**. Ordinals are the transfinite "counting numbers"
`0, 1, 2, …, ω, ω+1, …` that extend the naturals past infinity. The rank of an
element is, intuitively, the height of the tallest tree growing out of it. A
dead end — a world that sees nothing — has rank `0`. A world that sees only
dead ends has rank `1`. A world that can see worlds of every finite rank has
rank `ω`. And so on.

Applied to a GL frame, this gives every world an ordinal `rank w`, defined
precisely from the well-foundedness of the reversed accessibility relation. The
central fact, proved as `gl_rank_lt_of_R`, is short to state and deep in
meaning:

> **If `w` can see `v`, then `rank v < rank w`.**

Every step you take into a "more committed" world spends some of your ordinal
budget. Because ordinals cannot decrease forever, the journey must end. This is
the same engine that powers Gödel and Löb, now visible as pure geometry:
*self-reference has a depth, and the depth is an ordinal.*

This ruler is not an abstract decoration. It pins down, world by world, *how
many times you can iterate the notion of provability before it collapses* — a
point we return to below.

## The canonical example: counting down from infinity

The cleanest GL frame is also the most famous: take the worlds to be the
natural numbers `0, 1, 2, 3, …`, and let a number see every *smaller* number.
So world `5` sees `4, 3, 2, 1, 0`; world `0` sees nothing. This is the frame
`(ℕ, >)` — "greater-than" as accessibility.

It is irreflexive (no number is smaller than itself), transitive (smaller-than
chains compose), and — crucially — *converse* well-founded: you cannot descend
through the naturals forever; you always bottom out at `0`. (Note the
direction: the *naive* choice `(ℕ, <)`, where the future is *larger*, fails,
because `0 < 1 < 2 < ⋯` never stops. GL insists on counting *down*.)

In this frame the box has a delightfully concrete meaning. A number `n` is in
`□S` exactly when every smaller number lies in `S`:

> `natBox S = { n : ℕ | for all m < n, m ∈ S }`.

What is the box of the *empty* set? A world `n` belongs to `□∅` only if every
smaller world is in the empty set — impossible unless there *are* no smaller
worlds. So `□∅ = {0}`: the single bottom world. That tiny computation is
Gödel's second theorem in miniature. Read `⊥` (falsity) as "this theory is
inconsistent." Then `□⊥` is "inconsistency is provable" — and it is *not*
true everywhere (it fails at `1, 2, 3, …`). The theory cannot prove its own
inconsistency, hence cannot settle its own consistency.

Iterate the box and the pattern is stunning. The result `natBox_iterate_eq_Iio`
proves:

> `□^k ∅ = {0, 1, 2, …, k-1}` — the first `k` worlds.

Applying the box `k` times to the empty set yields exactly the worlds of depth
below `k`. The *k*-fold statement of inconsistency is true precisely at the
shallowest `k` worlds. As `k` grows, these sets grow strictly — a never-ending,
never-trivial staircase of stronger and stronger consistency statements, none
of which the theory can prove. This is **graded Gödel II**: not one unprovable
consistency statement, but an infinite, strictly increasing spectrum of them.

## From one example to *every* GL frame

The staircase above lives in one special frame. The headline new result lifts
it to *all* of them at once.

In the canonical frame, the rank of world `n` is just `n` itself, and `□^k ∅`
is the set `{n : rank n < k}`. Is this a coincidence of the natural numbers, or
a universal law? The theorem `boxSet_iterate_eq_rank_lt` settles it
definitively. In **any** GL frame whatsoever:

> **`□^k ∅ = { w | rank w < k }`.**

The *k*-fold falsity is satisfied exactly at the worlds whose ordinal rank lies
below `k`. The iterated box is a *thermometer for rank*. Two supporting results
make the picture airtight:

- `boxSet_empty_eq_maximal`: `□∅` is precisely the set of **dead-end** worlds —
  the worlds that see nothing. (These are the "maximal" or complete theories.)
- `rank_eq_zero_iff_maximal`: a world has rank `0` if and only if it is a dead
  end. Rank `0` is the floor of the building.

Put these together and a slogan emerges that would have delighted the founders
of proof theory:

> **Consistency strength *is* ordinal rank.**

The least number of times you must iterate "provably false" before the
statement fails at a world is *exactly* that world's ordinal rank. Gödel-style
"how strong is this consistency claim?" and the set-theorist's "how tall is this
well-founded tree?" are two names for a single invariant. The famous
`(ℕ, >)` staircase is now just the case `rank n = n`.

## Climbing the tower: many kinds of "provable"

So far there has been one notion of provability. But proof theory needs more.
Beyond plain provability sits *provability with an oracle*, *provability using
one extra dose of soundness*, *provability in a stronger meta-theory*, and so
on — an entire tower of modalities `[0], [1], [2], …`, each stronger than the
last. This is the realm of Giorgi Japaridze's **polymodal provability logic
GLP**, the logic that drives modern *ordinal analysis* — the project of
measuring the exact logical strength of theories like Peano Arithmetic by
naming the ordinal at which they run out of power.

Geometrically, GLP is captured by a **GLP frame**: a single set of worlds
carrying a *nested family* of accessibility relations,

> `R₀ ⊇ R₁ ⊇ R₂ ⊇ ⋯`,

each one irreflexive and transitive, each contained in the one before. Higher
modalities see *fewer* worlds.

The new development extracts a clean structural moral, and it is a *reduction*
rather than a new mystery. Each level `level n` of a GLP frame — the same
worlds with the relation `R n` — is itself an ordinary GL frame. Three facts
follow almost for free:

- **Every level validates Löb's law** (`glp_level_validates_loeb`): the single
  notion of provability's deepest theorem holds at *every* rung of the tower,
  with no separate proof needed.
- **The relations are antitone** (`R_anti`): if `n ≤ m`, then `R m ⊆ R n`.
  Higher modalities are sparser.
- **The boxes are monotone in the index** (`glp_box_mono_in_level`): if
  `n ≤ m`, then `□ₙ S ⊆ □ₘ S`. Because a higher modality sees fewer worlds, it
  is *easier* to satisfy. This is the geometric heart of the GLP axiom
  `[n]φ → [n+1]φ`: anything provable at one level is provable at every higher
  level.

And the ordinal ruler still works rung by rung: along each `R n`, rank strictly
decreases (`glp_level_rank_lt`). What looked like it might require a brand-new
polymodal theory turned out to be the single-modal theory, applied carefully and
repeatedly.

## When two worlds march in step

The final strand asks a category-theorist's question: can you *combine* GL
frames? Take two frames `F` and `G` and form their **synchronized product**.
The worlds are pairs `(w₁, w₂)`, and a step is allowed only when *both*
coordinates step at the same time:

> `(w₁, w₂)` sees `(v₁, v₂)` exactly when `w₁` sees `v₁` *and* `w₂` sees `v₂`.

This is the natural "product" construction, and it stays inside the GL world:
the synchronized product of two GL frames is again a GL frame, and it still
validates Löb's law (`prod_validates_loeb`).

Now the elegant part. Consider a **rectangle** of worlds `A ×ˢ B` — all pairs
whose first coordinate is in some set `A` and whose second is in some set `B`.
How do the modalities interact with rectangles?

For the **diamond** — *possibility* — everything factors perfectly
(`prod_diamond_rectangle`):

> `◇(A ×ˢ B) = (◇A) ×ˢ (◇B)`.

You can reach the rectangle in one synchronized step exactly when you can reach
`A` in the first coordinate *and* reach `B` in the second, independently. The
existential "there is a step" splits cleanly across the two factors. This exact
factorization is the algebraic *signature of a genuine categorical product* —
the same pattern you see in the mathematics of products everywhere.

For the **box** — *necessity* — the story is more interesting, and it is where
the new file `GLProductBox.lean` lives. One half always holds
(`prod_box_rectangle_subset`):

> `(□A) ×ˢ (□B) ⊆ □(A ×ˢ B)`.

But the reverse can *fail*, and the new theorem `prod_box_not_factor` pins down
exactly why with an explicit witness. Take `F` to be a two-world frame with a
single edge (call the worlds `true → false`) and `G` to be a one-world
dead-end frame (call its single world `()`). Look at the pair `(true, ())`.

- Is `(true, ())` in `□(A ×ˢ B)`? The world `()` is a dead end — it sees
  nothing — so `(true, ())` has *no successors at all* in the synchronized
  product. The box quantifies over an empty set of successors, so it is
  **vacuously true**. Yes.
- Is `(true, ())` in `(□A) ×ˢ (□B)`? This needs `true` to be in `□A`. But
  `true` sees `false`, and if `false ∉ A`, then `true ∉ □A`. **No.**

So `(true, ())` lies in the box of the rectangle but not in the rectangle of
boxes: the inclusion is *strict*. **Box does not factor.**

The reason is a piece of pure logic that everyone learns and then forgets: the
asymmetry between "for all" and "there exists." The diamond is an *existential*
("some synchronized step lands here") and existentials split over products. The
box is a *universal* ("all synchronized steps land here") — and a dead end in
*one* coordinate empties the quantifier in *both*, making the box silently true
regardless of the other coordinate. Possibility distributes; necessity gets
ambushed by dead ends.

There is even a precise statement of *when* box behaves. The companion result
`prod_box_rectangle_of_edgeless` shows that box factors perfectly when **both**
factor frames are *edgeless* — when nobody sees anybody. This corrects a tempting
earlier guess. One might suppose box factors exactly when both frames are
*serial* (every world has a successor, so dead ends never arise). But in a GL
frame, seriality is impossible: converse well-foundedness *forces* a dead end in
any non-empty frame. A serial GL frame must be *empty*. So the honest
coincidence criterion is not seriality but edge-freeness, and the dead end is
revealed as the genuine obstruction. GL, it turns out, is intrinsically a logic
of *diamonds*: possibility is the operation that respects its structure.

## Why any of this matters

Step back and look at the landscape these results map.

**A bridge to set theory.** The ordinal rank `rank` turns a logical frame into
a transfinite ruler, and the stratification theorem makes "consistency strength"
literally equal to "ordinal rank." Two great towers of twentieth-century
mathematics — Gödel's incompleteness and Cantor's ordinals — are shown to share
a single staircase.

**A bridge to proof theory.** The polymodal GLP frames are the engine of
ordinal analysis, the discipline that assigns to each formal theory a precise
ordinal (Peano Arithmetic, for instance, famously bottoms out at the ordinal
ε₀). By showing every level of a GLP frame is a plain GL frame, the work makes
the whole tower of provability modalities answerable to one uniform geometry.

**A bridge to category theory.** The product of GL frames, and the sharp split
between a diamond that factors and a box that does not, identifies *which*
modal operator carries the categorical structure. Possibility is the
product-respecting operation; necessity is ambushed by the very dead ends that
well-foundedness guarantees. GL is a "diamond-natural" logic, and now there is a
theorem to say so.

And there is a meta-lesson in the *failure* analysis. A natural conjecture —
"box factors iff both frames are serial" — turned out to be vacuous, because the
defining feature of GL (you cannot go forward forever) makes seriality
impossible. Chasing the conjecture to its breaking point revealed the *correct*
criterion (edge-freeness) and, with it, a deeper understanding of why dead ends
are unavoidable. In mathematics, a conjecture that collapses gracefully is often
worth more than one that quietly holds.

## The view from the summit

Gödel's sentence that whispers "I am not provable" began as a paradox at the
edge of logic. Ninety years later we can see it as the seed of a whole
*geometry*: worlds arranged in well-founded trees, an ordinal ruler measuring
the depth of self-reference, a tower of richer and richer provabilities, and a
product structure that quietly insists possibility, not necessity, is the soul
of the system.

The deepest surprise is how *concrete* it all becomes. "How strong is this
consistency claim?" — once a philosopher's puzzle — is answered by an ordinal
you can compute. "Can two notions of provability be combined?" — once a
technical curiosity — is answered by a product whose every successor is a
synchronized step. The abstractions of self-reference have a shape, and the
shape can be drawn, measured, and proved.

There is a particular kind of beauty in watching a paradox grow up into a
geometry. Gödel showed mathematics its limits; the geometry of GL shows that
even those limits have a precise and elegant form.
