# The Geometry of "Cannot Prove": A Map of the Worlds Where Mathematics Looks at Itself

## A sentence that should not exist

In 1931 a young logician named Kurt Gödel did something that still unsettles
people the first time they meet it: he wrote down a mathematical sentence that
truthfully says *"I cannot be proved."* If the sentence were false, it could be
proved — but then a falsehood would be provable, and the whole system would be
broken. So the sentence is true. And because it is true, it cannot be proved.
Mathematics, it turned out, contains true statements it can never reach.

A few years later, Gödel's *second* theorem delivered the aftershock: one of
those forever-unreachable truths is the statement *"this system is
consistent."* No sufficiently rich mathematical theory can prove its own
freedom from contradiction. To establish that arithmetic will never derive
`0 = 1`, you must step *outside* arithmetic and borrow strength from a larger
system — which, in turn, cannot vouch for itself either.

For decades these results lived in the realm of clever, hand-built sentences and
delicate coding tricks. Then, in the 1970s, something beautiful happened.
Logicians discovered that the entire phenomenon of "what a system can and cannot
prove about itself" could be captured by a tiny, austere piece of geometry: a
collection of **worlds** connected by arrows, obeying just two rules. This
article is about that geometry — and about a recent effort to map it with the
full rigor of machine-checked mathematics, extending it into ordinals, into
stacked hierarchies of provability, and into the algebra of combining systems.

## The box that means "provable"

The trick is to introduce a single new symbol, written `□`, and read it as
*"it is provable that …"*. So `□φ` means "φ is provable," and `◇φ` (the dual,
read "diamond") means "φ is consistent" — that is, "the negation of φ is *not*
provable."

Once you have this box, the headline theorems become startlingly compact.
Gödel's second incompleteness theorem becomes the single formula

> `¬□⊥` is true but `□(¬□⊥)` is false

— "the system is consistent, but the system cannot prove it is consistent."
And the deepest principle of all, **Löb's theorem**, becomes one elegant line:

> `□(□φ → φ) → □φ`.

In words: *if a system can prove "whenever φ is provable, φ is true," then the
system can already prove φ outright.* This sounds innocent until you set
`φ = ⊥` (a falsehood). Then it says: if a system could prove "my proofs are
trustworthy," it would immediately prove a contradiction. Self-trust is
poison. A consistent system can never certify its own reliability — the box
refuses to close the loop.

The collection of all truths expressible with this provability box, with these
laws, is called **provability logic**, or **GL**, after Gödel and the
mathematician Martin Hugo Löb.

## Turning logic into landscape

Here is the move that makes everything visual. Imagine a finite collection of
**worlds**. Between some of them we draw arrows: an arrow from world `w` to
world `v` means "from `w`, you can *see* `v`." Think of `v` as a hypothetical
scenario that world `w` regards as possible, or as a "more complete" theory that
extends `w`. We then declare:

> `□φ` is true at world `w` exactly when φ is true at **every** world `w` can see.

So "provable" means "true in all the worlds you can see from here." Diamond is
the mirror image: `◇φ` is true at `w` when φ holds in **some** world `w` can
see — "φ is consistent here because there's a world reachable from here where it
holds."

Now, what makes a collection of worlds-and-arrows a faithful picture of
provability? Astonishingly, just two rules:

1. **Irreflexivity:** no world has an arrow to itself. No world can see itself.
2. **Transitivity:** if `w` sees `v` and `v` sees `u`, then `w` sees `u`.

A finite structure obeying these two rules is called a **GL frame**. The first
rule — *no world sees itself* — is the geometric heart of the matter. It is the
direct spatial echo of Gödel's second theorem: a world that could see itself
would be a system that could inspect its own complete content and certify
itself, and we have just learned that no consistent system can do that. The
arrows must always point *away* from where you stand.

The remarkable theorem, established originally by Krister Segerberg and verified
in full formal detail in the work this article describes, is that **these finite
two-rule structures capture provability logic exactly.** Every law of GL is a
law of these frames, and vice versa. The abstract self-reference of Gödel and
Löb becomes the concrete combinatorics of dots and arrows.

And Löb's theorem itself? On a frame it reads:

> at every world where `□(□φ → φ)` holds, `□φ` holds too.

The formal development proves precisely this — that **every** finite GL frame
makes Löb's axiom true — by an argument that walks "downstream" along the arrows.
Because the arrows are irreflexive and transitive on finitely many worlds, you
can never travel forever; eventually you reach a world with no outgoing arrow at
all. Such a **dead-end world** sees nothing, so `□φ` is *vacuously* true there
(there are no counterexamples to check). From those dead ends, the truth of `φ`
ripples back upstream, world by world, until Löb's conclusion holds everywhere.
The engine that makes this work is a property called **well-foundedness**: you
cannot descend along the arrows forever.

## Every world gets a number — an ordinal number

Well-foundedness is more than a technical convenience; it is a hidden resource.
Whenever you have a collection of arrows along which you cannot travel forever,
you can attach to every point a **rank** measuring how far the longest journey
out of it can possibly go. For finite frames this rank is just an ordinary
counting number: a dead-end world has rank `0`; a world whose every arrow leads
to dead ends has rank `1`; and in general,

> the rank of a world is one more than the largest rank among the worlds it can
> see.

The formal development makes this precise and assigns every world of every GL
frame an **ordinal** — the transfinite numbers that mathematicians use to count
"how long" a well-ordered process can run. The central fact is clean and
inevitable:

> **Rank strictly decreases along arrows.** If `w` can see `v`, then
> `rank(v) < rank(w)`.

This is, in miniature, what proof theorists call *ordinal analysis*: the project
of measuring the strength of a mathematical theory by the largest ordinal it can
"reach." The canonical example lives one level down. Take the worlds to be the
natural numbers `0, 1, 2, 3, …`, and draw an arrow from `n` to every *smaller*
number. This `(ℕ, >)` frame is the purest GL frame there is, and the rank of
world `n` turns out to be exactly `n`. In this model the iterated statement
"`□^k ⊥`" — "it is `k`-fold provable that the system is inconsistent" — is
*literally* the set of worlds of rank less than `k`. The consistency strength of
a theory and the depth of a world become the very same number. Each extra layer
of self-reflection costs exactly one ordinal step, and the strengths climb
forever without ever reaching the top.

## Stacking the boxes: a tower of provabilities

Here the recent work pushes into genuinely new territory. Ordinary GL has one
provability box. But there is a richer logic, due to Giorgi Japaridze, with a
*whole sequence* of boxes — `[0]`, `[1]`, `[2]`, and so on — each stronger and
more demanding than the last. The box `[0]` is plain provability; `[1]` is
provability with an extra "oracle" for the consistency of the base theory; `[2]`
adds another layer; and the tower climbs without end. This is **polymodal
provability logic**, or **GLP**, and it is the engine behind some of the most
precise measurements of mathematical strength ever made.

Geometrically, a **GLP frame** is one set of worlds carrying not one family of
arrows but a *nested stack* of them:

> `R₀ ⊇ R₁ ⊇ R₂ ⊇ ⋯`

Each layer `Rₙ` is itself a GL frame (irreflexive, transitive), and — crucially —
each higher layer keeps **fewer** arrows than the one below. The formal
development proves this nesting is *antitone*: if `n ≤ m`, then every arrow at
level `m` is also an arrow at level `n`. The higher modalities see less.

From this single structural fact, two satisfying consequences fall out almost for
free, and the formalization records both:

- **Löb holds at every level.** Because each layer of a GLP frame is, by itself,
  an honest GL frame, the entire single-box theory — Löb's theorem, well-foundedness,
  the ordinal rank — applies layer by layer. Nothing new needs to be proved about
  self-reference at the higher levels; it is inherited wholesale.

- **The boxes get logically weaker as you climb.** Because higher layers have
  fewer arrows, a higher box `[n+1]` has fewer worlds to check and is therefore
  *easier* to satisfy. The formalization proves this monotonicity directly, and it
  is exactly the frame-level fingerprint of the GLP axiom `[n]φ → [n+1]φ`: anything
  provable at one level is provable at the next. What might have demanded a fresh,
  intricate argument turns out to be simple bookkeeping about which arrows survive.

This is the quiet kind of mathematical pleasure: a phenomenon that looked like it
would need new machinery dissolves into a corollary of structure you already had.

## Combining systems: when tangling refuses to untangle

The final thread concerns what happens when you put two systems side by side.
Suppose you have two GL frames, `F` and `G`, each modeling its own theory. There
is a natural way to run them in lockstep — the **synchronized product** `F × G` —
whose worlds are pairs `(w₁, w₂)`, with an arrow from `(w₁, w₂)` to `(v₁, v₂)`
exactly when there is an arrow `w₁ → v₁` in `F` *and* an arrow `w₂ → v₂` in `G`.
Both coordinates must step together.

The formalization proves that this product of two GL frames is *again* a GL
frame — irreflexive and transitive — so the whole apparatus survives combination.
But the truly revealing result is about the diamond, the consistency operator.
For a "rectangle" of possibilities `A × B` (scenario `A` in the first system,
scenario `B` in the second), the consistency of the rectangle factors *perfectly*:

> `◇(A × B) = ◇A × ◇B`.

"The combined scenario is consistent precisely when each part is consistent." This
clean factorization is the algebraic signature of a genuine **categorical
product** — the formal sense in which `F × G` is the *right* way to combine two
frames.

And now the punchline, the part the researchers flag as the seed for the next
chapter. The provability box does **not** factor this way. The reason is exactly
the dead-end worlds we met earlier. If the first coordinate has reached a
dead-end world — one with no outgoing arrows — then `□` is *vacuously* true there,
no matter what the second coordinate is doing. The two systems' blind spots do
not cancel; they contaminate the whole. Consistency (the diamond) combines
cleanly; provability (the box) does not. The tangling of self-reference, it
turns out, is *compositional in one direction only* — and that asymmetry, written
in the plain language of arrows and worlds, is a precise, machine-checked
statement about how the limits of self-knowledge behave when minds, or machines,
or theories are joined together.

## Why map this at all?

It is tempting to file all of this under "beautiful but useless" — the private
art of logicians. But the geometry of provability is quietly everywhere that
systems reason about themselves. A verification tool asked to certify its own
correctness, a learning algorithm asked to bound its own error, a proof-checking
program asked to validate its own checker — each is a system reaching for the
forbidden self-arrow, and each runs into Löb's wall. The frames in this work are,
in effect, a *map of where the walls are*: which scenarios a self-reflective
system can see, which it is structurally blind to, and exactly how much ordinal
"height" each extra layer of self-trust would cost.

What is new here is not the discovery that the walls exist — Gödel and Löb told us
that — but that the entire landscape has now been laid out with the unforgiving
precision of a machine-checked proof. Every world, every arrow, every ordinal
rank, every level of the polymodal tower, and the exact way consistency factors
across a product while provability refuses to: all of it is pinned down, with no
hand-waving and no hidden gaps. The sentence that says "I cannot be proved" has,
at last, a fully rigorous home — a small, sharp geometry where mathematics looks
at itself and, honestly, reports what it sees.
