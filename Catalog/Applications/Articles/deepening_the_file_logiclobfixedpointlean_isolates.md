# The Sentence That Can Only Be True: How One Logical Law Builds an Infinite Tower of Unprovable Truths

## A puzzle about self-reference

Imagine a sentence that talks about its own provability. Not a paradox like
"this sentence is false," but something subtler: a statement *S* that says, in
effect, "if I am provable, then I am true." It sounds almost circular, almost
empty. And yet, in the world of formal mathematics, such sentences turn out to
be among the most powerful objects we can write down.

This article is about a single law governing such self-referential sentences —
**Löb's law** — and the astonishing amount of structure that flows out of it.
From this one law, with almost nothing else, we will recover Gödel's famous
Second Incompleteness Theorem ("no consistent system can prove its own
consistency"), a clean theorem about when self-referential definitions have a
*unique* solution, and finally an infinite, strictly increasing tower of
truths, each one unprovable, each one stronger than the last.

The remarkable thing is that none of this requires us to talk about syntax,
Gödel numbering, or the gory machinery of arithmetic. It can all be phrased as
a piece of **order theory** — the mathematics of "less than or equal to." We
will tell the story algebraically, and then watch it come to life in a single
concrete model built out of nothing but the natural numbers and the relation
"greater than."

## Provability as an operator

Start with a collection of statements. We do not care what they *mean*; we only
care how they relate. Two statements can be compared: write `a ≤ b` to mean
"`a` is at least as strong as `b`" — anything that proves `a` also proves `b`.
(Logicians usually orient this the other way, but for our story this convention
keeps the pictures simple.) There is a strongest statement `⊥` ("false,"
which entails everything) and a weakest statement `⊤` ("true," which everything
entails). We can combine statements with "and" (written `⊓`, the *meet*) and
"or" (written `⊔`, the *join*), and there is an implication `a ⇨ b` ("if `a`
then `b`"). A structure with all of these well-behaved operations is called a
**Heyting algebra** — the algebraic skeleton of logic itself.

Now add one more ingredient: a box, written `□`. Read `□a` as "`a` is
provable." This box is not arbitrary. It obeys three rules that any honest
notion of provability must satisfy:

1. **`□⊤ = ⊤`** — truth is always provable. (The empty argument proves the
   trivially true statement.)
2. **`□(a ⊓ b) = □a ⊓ □b`** — proving "`a` and `b`" is the same as proving
   `a` and proving `b`. Proofs distribute over conjunction.
3. **Löb's law:** **`□(□a ⇨ a) ≤ □a`.** This is the deep one. In words: *if you
   can prove "whenever `a` is provable, `a` is true," then `a` is already
   provable.*

A Heyting algebra equipped with such a box is what we call a **Gödel–Löb
algebra**. The whole edifice rests on these three lines. Everything below is a
*consequence*.

## Why Löb's law is so strange

Löb's law looks innocent, but it has teeth. Let us extract our first
consequence, often called **Löb's rule**:

> **If `□a ≤ a`, then `a = ⊤`.**

In plain words: *if a statement is true whenever it is provable, then it is
outright true.* Read that twice. It says that the only sentences which are
"safe" — true the moment they are provable — are the ones that were trivially
true to begin with. There is no clever sentence that earns its truth purely by
being provable.

The proof is two lines of algebra. To say `□a ≤ a` is exactly to say the
implication `□a ⇨ a` equals `⊤`. Apply the box: `□(□a ⇨ a) = □⊤ = ⊤`. But
Löb's law says `□(□a ⇨ a) ≤ □a`. So `⊤ ≤ □a`, meaning `□a = ⊤`. Combined with
`□a ≤ a`, we get `⊤ ≤ a`, i.e. `a = ⊤`. Done.

This single rule is the engine of the entire theory. We will turn the crank on
it again and again.

## Gödel's Second Theorem, in three lines

Here is the headline application. In our algebra, the statement `⊥` is
falsehood, so `□⊥` is the statement "falsehood is provable" — that is, "the
system is **inconsistent**." Its negation, `□⊥ ⇨ ⊥`, is the **consistency
statement**: "falsehood is *not* provable."

A Gödel–Löb algebra is **consistent** when `□⊥ ≠ ⊤` — when "I can prove
falsehood" is not itself a theorem.

> **Gödel's Second Incompleteness Theorem (algebraic form).** *If the system is
> consistent (`□⊥ ≠ ⊤`), then it cannot prove its own consistency:
> `□(□⊥ ⇨ ⊥) ≠ ⊤`.*

The proof is, once again, Löb's law. Apply Löb with `a = ⊥`:
`□(□⊥ ⇨ ⊥) ≤ □⊥`. Now suppose, for contradiction, that consistency *were*
provable, i.e. `□(□⊥ ⇨ ⊥) = ⊤`. Then `⊤ ≤ □⊥`, so `□⊥ = ⊤` — the system is
inconsistent, contradicting our assumption. Therefore consistency is
unprovable.

That is Gödel's Second Theorem, one of the deepest results of the twentieth
century, falling out of a single ordering inequality. No Gödel numbering, no
diagonal lemma spelled out — all of that work has been compressed into Löb's
law, which we simply *postulated* as the defining feature of provability.

## Fixed points: when self-reference has exactly one answer

Self-referential definitions are everywhere in logic. We often want to define a
sentence `p` by an equation like

```
p = (□p ⇨ c),
```

which reads "`p` holds exactly when, if `p` is provable, then `c`." This is a
genuine fixed-point equation: `p` appears on both sides. Two questions
immediately arise. *Does a solution exist?* And *is it unique?*

Existence is easy and beautiful. The **canonical solution** is

```
glFix c := □c ⇨ c,
```

and one checks it works using a sharpened form of Löb's law — the equality
`□(□a ⇨ a) = □a` (the "≤" is Löb; the "≥" is just monotonicity). Plugging in,
`□(glFix c) = □(□c ⇨ c) = □c`, and therefore `□(glFix c) ⇨ c = □c ⇨ c =
glFix c`. So `glFix c` really does solve `p = □p ⇨ c`. Even better, its
provability is pinned down exactly: `□(glFix c) = □c`.

Uniqueness is where the magic returns. Here is the general principle, and it is
the conceptual heart of the whole cycle:

> **Uniqueness of modalised fixed points.** *Suppose a construction `F(p)`
> mentions its variable `p` only "inside a box" — every occurrence of `p` sits
> under a `□`. Then `F` has at most one fixed point.*

Why? Suppose `a` and `b` are both fixed points: `a = F(a)` and `b = F(b)`.
Because `p` only appears boxed, knowing that `a` and `b` are *provably
equivalent* is enough to conclude `F(a)` and `F(b)` are equivalent. Writing
`a ⇔ b` for the statement "`a` and `b` are equivalent," this says

```
□(a ⇔ b) ≤ (F(a) ⇔ F(b)) = (a ⇔ b).
```

But that is exactly the shape `□x ≤ x`! By Löb's rule, `x = ⊤` — that is,
`a ⇔ b = ⊤`, which means `a = b`. **Uniqueness of self-referential definitions
is not a fixed-point miracle. It is Löb's rule applied to a biconditional.**

This insight is powerful precisely because it generalises effortlessly. Take a
two-parameter version, `p = d ⊓ (□p ⇨ c)` ("`p` holds when both `d` holds and,
if `p` is provable, `c`"). The variable `p` still appears only under a box, so
the very same argument gives uniqueness — no new computation required. An
earlier, naive attempt to prove this by re-running an explicit calculation of
`□p` had stalled, because the extra conjunct `d` perturbs the bookkeeping. The
biconditional-and-Löb argument never computes `□p` at all, which is exactly why
it sails through.

## What Löb's law forbids

It is illuminating to ask what *fails* without Löb's law. Consider the most
naive notion of provability imaginable: "provable = true," i.e. `□a = a`, the
identity operator. Surely the simplest possible box?

It is fatal. If `□` were the identity, then Löb's rule (`□a ≤ a ⟹ a = ⊤`)
would say `a ≤ a ⟹ a = ⊤` — but `a ≤ a` is *always* true, so *every* statement
would equal `⊤`. The algebra collapses to a single point. Put differently:

> **In any nontrivial Gödel–Löb algebra, the box is never the identity.**

Concretely, take statements to be subsets of the natural numbers and let `□`
be the identity. Löb's law `□(□a ⇨ a) ≤ □a` becomes `(a ⇨ a) ≤ a`, i.e.
`⊤ ≤ a`, for every `a`. At `a = ∅` (the empty set) this demands the whole
universe be contained in the empty set — flatly false. Löb's law is *precisely*
the barrier that prevents a statement from being its own self-fulfilling
prophecy. The gap between "provable" and "true" is not an accident of
arithmetic; it is forced by the logic of provability itself.

## A world made of numbers

Abstraction is satisfying, but a theory needs a *model* — a concrete object
where every axiom can be checked and every quantity computed. Here is one of the
most elegant in all of logic.

Take the statements to be **subsets of the natural numbers** `ℕ`. Think of each
natural number `n` as a "world" or a "stage." Define the box by

```
□S = { n : every world m < n belongs to S }.
```

In words, *`n` proves `S` exactly when every strictly smaller world satisfies
`S`.* This is provability along the well-founded relation "greater than": to
establish something at stage `n`, you must have established it at every earlier
stage. Because there is no infinite descending chain of natural numbers (you
cannot keep going `... < 3 < 2 < 1 < 0`), this operator satisfies Löb's law.
The proof is a single strong induction, the algebraic shadow of the fact that
well-founded frames validate Löb.

This model — call it **NatGL** — is *consistent*: `□⊥` turns out to be exactly
the one-element set `{0}` (world `0` vacuously proves everything, since it has no
smaller worlds), and `{0}` is not the whole of `ℕ`. So `□⊥ ≠ ⊤`, and all of our
abstract theorems — Löb's rule, the fixed-point uniqueness, Gödel's Second
Theorem — instantly specialise to this concrete arithmetic world.

But NatGL gives us something the abstract theory cannot: it lets us *compute*.

## The tower of unprovable truths

Iterate the box. What is `□⊥`? The set `{0}`. What is `□□⊥` — provability of
provability of falsehood? A short induction reveals a breathtakingly clean
answer:

> **`□ⁿ⊥ = {0, 1, 2, ..., n−1}`** — the initial segment of length `n`.

The `n`-fold inconsistency statement is *exactly* the set of worlds of depth
less than `n`. The "rank" of a consistency statement — how deeply nested its
provability claims are — is not an extra piece of structure you have to define.
In this canonical model it is **the identity function on the natural numbers**:
`□ⁿ⊥` literally *is* the set `{0, 1, ..., n−1}`.

Two consequences fall out instantly, and together they form the climax of the
story.

First, **these statements form a strictly increasing chain**:

```
⊥ = ∅  ⊊  {0}  ⊊  {0,1}  ⊊  {0,1,2}  ⊊  ...
```

Each consistency strength `□ⁿ⊥` is *genuinely stronger* than the one before, and
none of them ever reaches `⊤ = ℕ`. There is an infinite ladder of strictly
increasing consistency strengths, climbing forever but never touching the top.

Second — and this is the payoff — **every rung of the ladder is unprovable**:

> **Graded Gödel II.** *For every `n`, the `n`-fold consistency statement
> `□ⁿ⁺¹⊥ ⇨ ⊥` is unprovable in NatGL: `□(□ⁿ⁺¹⊥ ⇨ ⊥) ≠ ⊤`.*

Gödel's original Second Theorem is just the bottom rung (`n = 0`): the system
cannot prove its own consistency. But here we get an entire **spectrum**. The
system cannot prove its consistency; it cannot prove the consistency of "the
system plus its own consistency"; it cannot prove the consistency of *that*; and
so on, forever, each statement strictly stronger than the last, each one
provably beyond reach. The single, isolated incompleteness phenomenon of Gödel
unfolds into an infinite, strictly ordered hierarchy.

(One subtlety: the very bottom level `n = 0` is genuinely different.
`□⁰⊥ = ⊥`, and *its* consistency `⊥ ⇨ ⊥ = ⊤` is trivially provable. It is only
the *nontrivial* consistency strengths `□ⁿ⁺¹⊥` that escape provability. The
hierarchy begins exactly where the content begins.)

## Why the order matters

A final twist rewards a moment's reflection. We built the model on the relation
"greater than," not "less than." Why? Because Löb's law demands a *well-founded*
frame — one with no infinite descending chains. The natural numbers under "less
than" have infinite *ascending* chains (`0 < 1 < 2 < ...`), and along that order
Löb's law is *false*. It is the converse order, "greater than" — where every
descent must eventually stop at `0` — that makes everything work. This is the
same reason, glimpsed from the algebraic side, that the Kripke frames of
provability logic must be converse-well-founded. The arrow of provability points
*backward*, from each stage to the finitely many stages beneath it, and it is
the inevitability of reaching the bottom that gives Löb's law its bite.

## The shape of the idea

Step back and look at what we have. We began with three algebraic rules for a
"provability" operator. From the single most striking of them, Löb's law, we
distilled one rule — *"if true-whenever-provable, then true"* — and from that
rule alone we derived:

- **Gödel's Second Incompleteness Theorem**, that consistency is unprovable;
- a clean, completely general theorem that **self-referential definitions have
  unique solutions** whenever the variable hides under a box, with an *explicit*
  formula `□c ⇨ c` for the canonical case;
- the fact that the box can **never** be the naive "provable = true" operator;
  and finally,
- in a model built from numbers and the relation "greater than," an infinite,
  strictly increasing, never-trivial **tower of unprovable consistency
  strengths**, with the elegant closed form `□ⁿ⊥ = {0, 1, ..., n−1}`.

The deepest results in the foundations of mathematics — the limits of what any
formal system can know about itself — turn out to be, at heart, a story about a
"less than or equal to" sign and a box that can never lie to itself. That is the
quiet power of finding the right level of abstraction: a sentence that can only
be true, used as a fulcrum, lifts the whole theory of incompleteness into the
clear, computable light of order theory.
