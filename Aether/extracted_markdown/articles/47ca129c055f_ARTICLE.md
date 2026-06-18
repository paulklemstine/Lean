# The Shape of "I Cannot Prove Myself": How a Logic of Provability Hides a Theorem About Order

## A sentence that talks about itself

In 1931 Kurt Gödel built a sentence that says, in effect, *"I am not provable."* If the
sentence were provable, the system would prove something false; if it were unprovable,
then what it asserts is true — and the system is incomplete. This single self-referential
trick toppled the dream of a complete, mechanical foundation for all of mathematics.

Decades later, logicians realized something startling. You don't need the heavy machinery
of Gödel numbering, arithmetic, or syntax to capture the *behavior* of provability. You
can abstract it into a tiny algebra of three rules and watch the entire drama —
incompleteness, self-reference, the impossibility of proving your own consistency —
replay itself as pure structure. That abstraction is called **Gödel–Löb provability
logic**, or **GL**.

This article tells the story of one clean, surprising fact buried at the heart of GL:
the existence of its famous self-referential sentences is, when you strip everything else
away, *a statement about order* — specifically, about staircases that cannot descend
forever. Uniqueness of those sentences, meanwhile, is a statement about *modality* —
about the box operator that means "is provable." The two halves come apart cleanly, and
when they do, the abstract existence theorem becomes a concrete, terminating computation.

## The box that means "provable"

Imagine a single symbol, written `□`, pronounced "box," that you attach to a statement
`p` to form `□p`, read *"p is provable."* What rules should `□` obey, if it is to behave
like real provability in a strong mathematical theory?

Three rules turn out to be enough. We work inside a *Heyting algebra* — think of it as a
universe of truth-values richer than just true/false, equipped with operations for "and"
(`⊓`), "implies" (`⇨`), a top element `⊤` (absolute truth), and a bottom element `⊥`
(falsehood). On top of this universe we place `□`, demanding:

1. **Necessitation of truth:** `□⊤ = ⊤`. *Truth is provable.*
2. **Normality:** `□(a ⊓ b) = □a ⊓ □b`. *Provability respects "and": to prove a
   conjunction is exactly to prove each part.*
3. **Löb's axiom:** `□(□a ⇨ a) ≤ □a`. *If you can prove "whenever a is provable, a is
   true," then a is already provable.*

That third rule, Löb's axiom, is the strange and powerful one. It is the algebraic echo
of a 1955 theorem of Martin Löb, and it encodes the precise way a self-honest theory
trips over its own feet. Everything below flows from it.

We call any Heyting algebra carrying such a `□` a **Gödel–Löb algebra**. The remarkable
thing is how much follows from these three lines — *no arithmetic required.*

## Free consequences: transitivity, and Gödel's second theorem

The first surprise is that a *fourth* rule logicians often assume — **transitivity**,
`□a ≤ □□a`, meaning "if a is provable, then it is provable that a is provable" — does not
need to be assumed at all. It falls out of Löb's axiom by a two-line trick. Set
`c := a ⊓ □a`; a short calculation shows `□a ≤ □c`, and `□c` unfolds to give exactly
`□a ≤ □□a`. The logic of provability needs no separate transitivity axiom; Löb hands it
to you for free.

The second surprise is **Gödel's second incompleteness theorem**, in four symbols. Call an
algebra *consistent* if it cannot prove falsehood: `□⊥ ≠ ⊤`. Then a consistent Gödel–Löb
algebra *cannot prove its own consistency*:

> **Gödel's Second Theorem (algebraic form).** If `□⊥ ≠ ⊤`, then `□(□⊥ ⇨ ⊥) ≠ ⊤`.

The statement `□⊥ ⇨ ⊥` says "falsehood is not provable" — i.e., "this theory is
consistent." The theorem says: provability of *that* is unattainable. The proof is Löb's
axiom applied at `a = ⊥`. One of the deepest results of twentieth-century logic, reduced
to a single instance of a single algebraic inequality.

A close cousin is **Löb's rule**: if `□a ≤ a` — if `a` follows from its own provability —
then `a = ⊤`. The only fixed point of the box, the only element equal to its own
provability, is absolute truth itself. Self-provable statements are exactly the trivial
ones.

## The de Jongh–Sambin fixed point: building self-reference by hand

Gödel's sentence is self-referential: it refers to its own provability. In GL we can
manufacture such sentences directly. Fix any "target" `c`, and consider the operation

> `p ↦ □p ⇨ c`,

read *"if p is provable, then c."* A **fixed point** of this operation is an element `p`
that equals `□p ⇨ c` — a statement that asserts something about its own provability. Does
such a self-referential `p` always exist? And if so, is it unique?

The **de Jongh–Sambin theorem** answers both, beautifully. There is an *explicit* formula:

> `glFix c := □c ⇨ c`.

This single term is a fixed point of `p ↦ □p ⇨ c`. The reason is a small computational
gem: the provability of `glFix c` is exactly the provability of `c` itself,
`□(glFix c) = □c`. (One direction is Löb's axiom; the other is monotonicity.) Substituting
this back, `□(glFix c) ⇨ c = □c ⇨ c = glFix c`, so `glFix c` genuinely solves its own
equation. With `c = ⊥`, this `glFix ⊥ = □⊥ ⇨ ⊥` is precisely the Gödel consistency
sentence.

And it is the **only** solution. Any `a` with `a = □a ⇨ c` must equal `glFix c`. The proof
squeezes `□a` between `□c` and itself using the derived transitivity axiom, forcing
`□a = □c`, hence `a = □c ⇨ c`. Existence by formula; uniqueness by Löb.

## The deepest cut: uniqueness is Löb's rule in disguise

Here the story turns abstract — and clarifying. The uniqueness above is not special to the
map `p ↦ □p ⇨ c`. It holds for *any* operator in which the variable appears only inside a
box.

To make "only inside a box" precise, introduce the **biimplication** `a ⇔ b`, which equals
`⊤` exactly when `a = b` — the algebraic "if and only if." Call an operator `f`
**box-congruent** if

> `□(a ⇔ b) ≤ f a ⇔ f b`,

meaning: *if it's provable that a and b agree, then f's outputs agree.* This is the precise
algebraic shadow of the syntactic side condition "the variable occurs only under `□`."

> **General de Jongh–Sambin Uniqueness.** A box-congruent operator has *at most one* fixed
> point: if `a = f a` and `b = f b`, then `a = b`.

The proof is a one-liner once you see it. At the two fixed points, box-congruence gives
`□(a ⇔ b) ≤ a ⇔ b`. That is exactly the hypothesis of *Löb's rule* applied to the element
`a ⇔ b` — so `a ⇔ b = ⊤`, which means `a = b`. Uniqueness of self-referential sentences is
**Löb's rule, applied to "if and only if."** Nothing more.

This is the punchline of the whole edifice: the famously delicate uniqueness of Gödel and
Henkin sentences is not a fixed-point miracle. It is a single, transparent application of
Löb's rule.

## The other half: existence is a staircase that can't fall forever

Uniqueness, we have seen, is purely *modal* — it is about `□`. But what about *existence*?
For the explicit map `p ↦ □p ⇨ c` we wrote down a formula. For a *general* box-congruent
operator on an *arbitrary* algebra, there may be no formula at all — and indeed no fixed
point. Existence needs something extra.

That something is an order condition, and it is wonderfully concrete. Picture the
truth-values arranged by the order `≤`. Now picture a staircase descending:

> `⊤ ≥ g(⊤) ≥ g(g(⊤)) ≥ g(g(g(⊤))) ≥ ⋯`

obtained by hammering a monotone operator `g` against the top element again and again. In a
general algebra this staircase could descend forever, never settling. But if the algebra
satisfies the **descending chain condition** — no infinite strictly decreasing sequence,
the property logicians call `WellFoundedLT` — then the staircase *must* stop. And the place
it stops is a fixed point of `g`:

> **Descending-Iteration Fixed Point.** On any partial order with a top element and no
> infinite strictly descending chains, a monotone map `g` has a fixed point, realised as
> the stabilised value of the iteration `g, g∘g, g∘g∘g, …` started at `⊤`.

This is pure order theory — not a word about provability. The fixed point isn't conjured
by an abstract axiom; it is *computed*, by iterating until nothing changes.

## Gluing the halves: when self-reference becomes a finite computation

Now we connect the two halves, and the connection is itself a theorem. Box-congruence —
the property "variable only under a box" — is closed under composition. If `f` and `g` are
each box-congruent, so is `g ∘ f`. And here, finally, the derived **transitivity axiom**
earns its keep: the proof needs a *second* box to push the inner agreement under another
box, `□(a ⇔ b) ≤ □□(a ⇔ b) ≤ …`. Composition-closure of box-congruence is *exactly* where
axiom 4 is consumed.

Why does composition matter? Because the canonical Gödel/Sambin map `p ↦ □p ⇨ c` is
*antitone* — it flips the order — so the descending staircase argument doesn't apply to it
directly. But its **square**, `f ∘ f`, is *monotone* (antitone composed with antitone), and
box-congruent (composition of box-congruent maps). So the staircase argument finds a fixed
point of `f ∘ f`; uniqueness for `f ∘ f` then forces `f` itself to have that same fixed
point. The result:

> **Constructive de Jongh–Sambin Theorem (under DCC).** On a Gödel–Löb algebra satisfying
> the descending chain condition, every box-congruent operator `f` whose square `f ∘ f` is
> monotone has a *unique* fixed point, obtained constructively as the stable value of the
> descending iteration `(f ∘ f)(⊤), (f ∘ f)²(⊤), …`.

The hypothesis "`f ∘ f` monotone" is met by *every* monotone `f` and *every* antitone `f`,
so the canonical Gödel map is a special case — and one can check that its iterative fixed
point is exactly the closed form `glFix c = □c ⇨ c` we wrote down by hand. Self-reference,
which began as Gödel's ingenious diagonal sentence, becomes here a loop you can run:
iterate the operator from `⊤` until it stops.

## Where staircases stop — and where they don't

The descending chain condition is not a technicality; it is *load-bearing*, and you can
see exactly where it bites. The natural infinite models of GL are built on well-founded
*frames*: the natural numbers under "greater than," `(ℕ, >)`, or the ordinals under "less
than," `(Ordinal, <)`. In these, the box of a set `S` is "every accessible world satisfies
`S`," and one computes a clean **provability ladder**: the `k`-fold falsity `□^k⊥` is
exactly the initial segment `{0, 1, …, k−1}`, and transfinitely `□(Iio a) = Iio(a+1)`.
These models are consistent, and they host a strictly increasing hierarchy of unprovable
consistency statements — graded Gödel theorems, one per natural number (and one per
ordinal).

But the *algebra* of subsets of `ℕ` or of the ordinals has **infinite descending chains**
(`{0,1,2,…} ⊋ {1,2,…} ⊋ {2,3,…} ⊋ ⋯`). So the descending staircase need *not* stop there:
the iteration may never converge, and existence in those models rests on the explicit
formula `glFix`, not on the iteration. The iteration's true home is the **finite frames**
`(Fin n, <)`: finite, automatically well-founded, every staircase terminates, and every
box-congruent or monotone-square operator has its fixed point found by a loop that always
halts.

## The moral

Strip the syntax, the Gödel numbering, the arithmetic, and the towering edifice of
incompleteness from Gödel–Löb logic, and what remains is a clean decomposition:

- **Uniqueness of self-referential sentences = Löb's rule**, applied to "if and only if."
  Purely modal.
- **Existence of self-referential sentences = the descending chain condition.** Purely
  order-theoretic — a staircase that cannot fall forever.
- **The bridge between them = transitivity (axiom 4)**, which is itself a free gift of
  Löb's axiom, and which is consumed exactly when you compose box-congruent operators to
  turn an antitone map into a monotone square.

Gödel's diagonal lemma, that dazzling sleight of hand, turns out to have a serene
order-theoretic skeleton. The sentences that say "I cannot prove myself" exist for the same
reason a staircase in a well-founded order must reach a bottom step — and they are unique
for the same reason that nothing can prove its own truth without already being true. Two of
the most famous tricks in logic, reduced to a property of order and a single rule of
modality, meeting at the place where transitivity lives.
