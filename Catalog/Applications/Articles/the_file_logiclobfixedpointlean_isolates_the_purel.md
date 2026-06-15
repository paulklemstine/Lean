# The Sentence That Cannot Praise Itself: How Three Equations Capture the Limits of Proof

## A puzzle about self-reference

Imagine a mathematician who writes down a single, slippery sentence:

> "If this sentence is provable, then it is true."

It sounds harmless — even obviously correct. Surely anything you can *prove*
ought to be *true*? But buried inside that innocent phrasing is one of the most
beautiful traps in all of logic. In 1955 the logician Martin Löb discovered that
this sentence is not merely true: in any reasonable formal system, the *only* way
such a sentence can hold is if the thing it talks about was already, flatly,
unconditionally true to begin with. There is no clever, self-justifying sentence
that bootstraps itself into truth. The snake cannot swallow its own tail.

This is **Löb's theorem**, and it is the secret engine behind Kurt Gödel's
famous Incompleteness Theorems — the results that shattered the early-twentieth-century
dream of a complete, self-certifying foundation for mathematics. Gödel showed that
no sufficiently strong, consistent system can prove its own consistency. Löb
explained *why* in a single sharp principle about self-reference.

For decades these results have been told as stories about *arithmetic*: about
encoding sentences as numbers, about the delicate machinery of Gödel numbering,
about provability predicates inside Peano Arithmetic. That telling is correct,
but it hides something. Underneath the arithmetic, there is a small, crystalline
core that has nothing to do with numbers at all. It is **pure order theory** — the
mathematics of "less than or equal to." This article is about that core: how three
short equations, written in the language of lattices, are enough to reconstruct the
entire skeleton of provability logic, including Löb's theorem and Gödel's Second
Incompleteness Theorem, with no arithmetic in sight.

## The grammar of provability

To strip the arithmetic away, we need a way to talk about "provability" abstractly.
The trick — going back to Roberto Magari in the 1970s — is to treat provability as
an *operator* on a lattice of propositions.

Picture a collection of statements. Some are stronger, some weaker; "stronger"
means "implies." This ordering, together with the natural operations of "and"
(meet, written `⊓`), "or" (join, written `⊔`), and a notion of implication
(written `⇨`), forms what algebraists call a **Heyting algebra**. The top element
`⊤` is the always-true statement; the bottom element `⊥` is the absurd, always-false
statement (a contradiction).

Now add one new ingredient: a **box operator** `□`. Read `□a` as *"a is provable."*
We do not tell the box what "provable" means. We only demand that it obey three
rules — the three equations that turn out to be the entire DNA of provability:

1. **Truth is provable.** `□⊤ = ⊤`. The trivially true statement is always
   provable. (This is the algebraic shadow of Gödel's *necessitation* rule: if you
   can prove something outright, the system knows it can.)

2. **Proof respects conjunction.** `□(a ⊓ b) = □a ⊓ □b`. Proving "a and b" is
   exactly the same as proving a and separately proving b. (This is the algebraic
   form of the modal axiom **K**, the backbone of all modal logic.)

3. **Löb's axiom.** `□(□a ⇨ a) ≤ □a`. This is the strange one. In words: if the
   system can prove the sentence *"whenever a is provable, a is true,"* then the
   system can already prove a outright.

A Heyting algebra equipped with such a box is called a **Gödel–Löb algebra**, or
**Magari algebra**. That is the whole setup. No numbers, no encodings, no syntax —
just an ordering and three equations.

The astonishing claim, which we now make precise and which has been verified down
to the last logical step, is this:

> **From these three equations alone, the entire theory of provability follows.**

Let us watch it unfold.

## First surprise: monotonicity comes for free

You might expect we'd need to *assume* that the box respects the ordering — that if
`a` implies `b`, then "a is provable" implies "b is provable." It feels like a basic
sanity requirement. But it is not an assumption. It is a **theorem**, squeezed out
of rule 2 alone.

Here is the one-line argument. In any lattice, saying `a ≤ b` (a implies b) is the
same as saying `a ⊓ b = a` (anding with b changes nothing). So if `a ≤ b`, then

    □a = □(a ⊓ b) = □a ⊓ □b,

where the middle step is rule 2. But `□a = □a ⊓ □b` says precisely that `□a ≤ □b`.
Done. **Monotonicity is not a fourth axiom; it was hiding inside meet-preservation
the whole time.**

This sets the tone. Over and over, properties that textbooks postulate separately
turn out to be derivable consequences of the three core equations.

## Second surprise: the self-referential sentence has an explicit answer

Recall the slippery sentence we started with: *"if this is provable, then it is
true."* In the algebra, the natural object encoding "if a is provable then a holds"
is the implication `□a ⇨ a`. Löb's axiom says `□(□a ⇨ a) ≤ □a`. But in fact this
inequality is secretly an **equality**:

> **The de Jongh–Sambin fixed point.** `□(□a ⇨ a) = □a`.

Why does the reverse inequality hold? Because `a ≤ (□a ⇨ a)` is always true (it is
just the statement `a ⊓ □a ≤ a`, which is obvious — anding can only shrink things),
and applying the monotonicity we just derived gives `□a ≤ □(□a ⇨ a)`. Combine with
Löb's axiom and the two sides pinch together into equality.

What does this *mean*? Consider the operation that takes a sentence `x` and returns
`□(x ⇨ a)` — "the system proves that x implies a." This is a self-referential
recipe: it builds a new sentence out of an old one, with the old one tucked safely
*inside a box*. A **fixed point** of this recipe is a sentence `x` that equals its
own image, `x = □(x ⇨ a)`. The de Jongh–Sambin theorem says such a fixed point not
only exists but is *completely explicit*: it is simply `□a`. The self-reference
resolves into something we can write down. There is no infinite regress, no
paradox — just a clean closed form. This is one of the deepest and most surprising
facts in modal logic, and here it falls out in three lines.

## Third surprise: Löb's theorem as a ban on self-praise

Now the headline result. **Löb's theorem**, in this algebraic dress, reads:

> If `□a ≤ a`, then `a = ⊤`.

In words: if a sentence `a` is *reflexive* — if its own provability already
guarantees its truth — then `a` must be the trivially true statement `⊤`. There are
**no nontrivial self-justifying sentences.** The only statement that can honestly
say "proving me makes me true" is the one that was true for nothing.

The proof is a small gem. Suppose `□a ≤ a`. Then the implication `□a ⇨ a` is the top
element `⊤` (an implication whose conclusion already dominates its hypothesis is
vacuously total). Feed this into Löb's axiom:

    ⊤ = □⊤ = □(□a ⇨ a) ≤ □a,

using rule 1 (`□⊤ = ⊤`) at the start. So `□a = ⊤`. But we assumed `□a ≤ a`, hence
`⊤ ≤ a`, i.e. `a = ⊤`. The sentence had nowhere to hide.

This is the precise sense in which our opening puzzle was a trap. The sentence "if
this is provable, then it is true" *can* hold — but only for content that was
already unconditionally true. Self-reference buys you nothing.

## Fourth surprise: introspection is derived, not assumed

Modal logicians have a hierarchy of systems. One famous axiom, called **axiom 4** or
*positive introspection*, says `□a ≤ □□a`: "if a is provable, then it is provable
that a is provable." The system knows what it knows. Many modal systems simply
*postulate* this.

In a Gödel–Löb algebra, you do not have to. **Axiom 4 is a theorem.** This is
Sambin's elegant derivation, and it uses a clever auxiliary element: the *diagonal*
`b = a ⊓ □a` ("a, and a is provable").

The chain of reasoning runs: rule 2 splits `□b = □a ⊓ □□a`. A short computation
shows `a ⊓ □b ≤ b`, which rearranges (via the implication-meet adjunction) into
`a ≤ (□b ⇨ b)`. Applying monotonicity gives `□a ≤ □(□b ⇨ b)`, Löb's axiom gives
`□(□b ⇨ b) ≤ □b`, and finally `□b ≤ □□a`. Stringing these together:

    □a ≤ □(□b ⇨ b) ≤ □b ≤ □□a.

So `□a ≤ □□a`. Introspection emerges from Löb's axiom. The philosophical payload is
striking: **well-foundedness — the impossibility of infinite descending chains of
provability — is already encoded inside Löb's single inequality.** You don't need to
assume the universe of proofs is well-ordered; Löb's axiom enforces it.

## The grand finale: Gödel's Second Incompleteness Theorem

Everything above has been leading to one place. What happens if we run the
de Jongh–Sambin fixed point at the most dangerous sentence of all — the
contradiction `⊥`?

Read `□⊥` as "the system proves a contradiction" — that is, "the system is
inconsistent." Then the sentence `□⊥ ⇨ ⊥` says "if a contradiction is provable, then
a contradiction holds," which is exactly the system asserting *its own consistency*.
(Logicians write the consistency statement as `Con` = `¬Prov(⊥)`; here it is
`□⊥ ⇨ ⊥`.)

Now substitute `a = ⊥` into the fixed-point equation `□(□a ⇨ a) = □a`:

> **Gödel's Second Incompleteness Theorem.** `□(□⊥ ⇨ ⊥) = □⊥`.

Stare at this. The left side is "the system proves its own consistency." The right
side is "the system proves a contradiction." They are **equal**. So a system can
prove its own consistency *if and only if* it is actually inconsistent. Turn it
around: any **consistent** system (one where `□⊥ ≠ ⊤`, i.e. it does not prove every
falsehood) *cannot* prove its own consistency, because if it could, that proof would
be `⊤`, forcing `□⊥ = ⊤` and collapsing the whole system into contradiction.

This is Gödel's most philosophically explosive result, and here it is not a deep
arithmetical theorem requiring pages of Gödel numbering. It is a **one-line
corollary** of the fixed-point identity, which was itself three lines, which rested
on three equations. The 1931 earthquake reduced to a substitution.

## Making it concrete: counting the unprovable

Abstraction is powerful, but is there an actual structure that obeys all three
equations *and* is genuinely consistent — so that these results are not vacuously
true? Yes, and it is delightfully simple.

Take the propositions to be **sets of natural numbers**. Think of a set `S ⊆ ℕ` as a
proposition that is "true at stage n" exactly when `n ∈ S`. Define the box by

    □S = { n | every m < n belongs to S }.

In words, `n` proves `S` if every *earlier* stage already satisfies `S`. This is the
provability operator of the **well-founded frame `(ℕ, <)`** — looking strictly
backward in time. One can check (and it has been verified) that this `□` satisfies
all three Gödel–Löb equations.

Now the abstractions become arithmetic you can compute:

- **The model is consistent.** `□⊥` (where `⊥` is the empty set) equals `{0}`, the
  single stage with no predecessors — not the whole of `ℕ`. So `□⊥ ≠ ⊤`: the model
  does *not* prove falsity everywhere.

- **Iterated provability counts depth.** Applying the box `k` times to `⊥` gives
  exactly the first `k` numbers: `□^k⊥ = {0, 1, …, k-1}`. The number of boxes you
  stack equals how far into the well-founded order you can see.

- **A strictly rising tower of unprovable consistencies.** The sets `□⊥ ⊊ □²⊥ ⊊
  □³⊥ ⊊ …` form a strictly increasing chain that *never* reaches `⊤`. Each step is a
  stronger consistency statement than the last, and **every one of them is
  unprovable.** This is a *graded* Gödel II: not a single unprovable sentence, but an
  infinite, explicitly enumerated spectrum of them, each measuring a deeper layer of
  what the system cannot certify about itself.

## Why this matters

There is a recurring dream in mathematics: to find the *minimal* assumptions from
which a rich theory flows. When you succeed, you don't just re-prove old results —
you understand them. You see which features were essential and which were scaffolding.

The lesson of the Gödel–Löb algebra is that the profound limitative theorems of
twentieth-century logic — the ones that told us mathematics can never fully ground
itself — are *not* fundamentally about numbers, encodings, or syntax. Those were the
historical vehicle. The real content is **order-theoretic**: it lives in the
interaction of a single operator with a partial order, governed by one inequality
that quietly forbids infinite descent.

Strip away the arithmetic and you find a structure of austere beauty:

- Monotonicity is free.
- The fixed point is explicit.
- Self-praise is impossible.
- Introspection is automatic.
- And a system's faith in itself is exactly its inconsistency.

Three equations. The whole limit of proof. The sentence that cannot praise itself
turns out to be the keystone of an entire cathedral — and the cathedral, it
emerges, was built on order alone.
