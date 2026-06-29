# The Shape of a Proof: How a Local Promise Becomes a Global Map

## A puzzle about translation

Imagine two languages. In the first, every sentence is short and blunt. In the
second, the same ideas are spelled out at greater length, with more grammar and
ceremony. Now suppose you have a faithful translator who promises something
very modest: *"Give me any single sentence from the first language, and I will
render it in the second using at most three sentences."*

That is a tiny, local promise. It says nothing directly about translating a
whole novel. Yet intuition insists that the promise *scales*: a 100-sentence
story should translate into at most 300 sentences. The local bound seems to
propagate, automatically, to a global one.

This article is about the precise mathematical version of that intuition — but
for *proofs* instead of stories. In logic, a "proof" is a chain of small,
licensed steps that gets you from a starting fact to a conclusion. Different
proof systems are like different languages: some prove things in few steps,
others in many. A translation between proof systems is a recipe that converts
proofs in one system into proofs in another.

The central result we will describe — call it **proof-complexity holography** —
says that a purely *local* promise about translating one step at a time
propagates, with mathematical certainty, into a *global* statement about
distances in the entire geometry of proofs. The local bound is the "bulk"
information; the global distance bound is its "boundary shadow." This kind of
"the boundary remembers the bulk" phenomenon is exactly the flavor that physics
calls *holography*, and here it appears in the unlikely setting of formal logic.

## Proofs as distances

To make this work, we first turn proofs into geometry.

Fix a collection of basic objects we'll call **atoms** — think of them as
statements, or states, or just labelled points. A **theory** is simply a set of
allowed one-step moves between atoms. We write `a → b` when the theory licenses
a direct step from `a` to `b`. These are the axioms, the elementary rules of
the game.

A **derivation** of `b` from `a` is a finite chain of licensed steps:

```
a = x₀ → x₁ → x₂ → ⋯ → xₖ = b.
```

The number of steps `k` is the **length** of the derivation. We track length
carefully with a predicate written `DerivOfLen T a b k`, read as: *"in theory
`T`, there is a derivation of `b` from `a` that uses exactly `k` steps."* There
are two ways to build one. The empty derivation has length zero and gets you
from `a` to itself. And if you already have a length-`k` derivation reaching
some intermediate `b`, and the theory licenses one more step `b → c`, you can
tack it on to get a length-`(k+1)` derivation reaching `c`.

Now comes the geometric move. Define the **proof distance** from `a` to `b` as
the length of the *shortest* derivation connecting them:

```
minDerivLen T a b  =  the smallest k such that DerivOfLen T a b k holds.
```

This single number behaves remarkably like a distance. It is zero from any atom
to itself (the empty derivation). And it satisfies a directed triangle
inequality: the shortest route from `a` to `c` is never longer than going from
`a` to `b` and then `b` to `c`. In short, `minDerivLen` makes the atoms of any
theory into a discrete, directed metric space — a *proof geometry*. The
"points" are statements; the "distance" is the minimal number of inferential
steps separating them.

A clean running example is the **chain theory** on the natural numbers, whose
only axioms are `n → n+1`. Here you can only ever count upward, one tick at a
time. The proof distance from `a` to `b` (when `a ≤ b`) is exactly `b − a`,
the gap between them. The chain is the ruler of our subject: a perfectly rigid,
slack-free geometry where the shortest proof is the *only* proof, and its
length is forced.

## What a translation actually promises

We now formalize the translator from our opening puzzle. A **proof translation**
from a source theory `T` (on atoms `α`) to a target theory `S` (on atoms `β`)
consists of three pieces:

1. a function `map` that sends each source atom to a target atom;
2. a single number `stretch` (call it `L`), the translator's advertised
   worst-case cost; and
3. a **one-step certificate**: a guarantee that for *every* source axiom
   `a → b`, the translated endpoints `map a` and `map b` are connected in the
   target by a derivation of length **at most `L`**.

That third piece is the entire promise — and notice how local it is. It only
ever talks about a single axiom of the source at a time. It says nothing about
long derivations, nothing about distances, nothing about the global shape of
either geometry. It is the "translate any one sentence in at most three"
clause, and nothing more.

## The holographic theorem

Here is the payoff, the structural engine of the whole story. We call it
**holographic propagation**:

> **Theorem (holographic propagation).** If `φ` is a translation with stretch
> `L`, then every length-`k` derivation in the source is sent to a derivation in
> the target of length **at most `L · k`**.

In symbols: from `DerivOfLen T a b k` we may conclude
`DerivOfLen S (map a) (map b) j` for some `j ≤ L · k`.

The proof is an induction that is almost a tidy accounting exercise, and it is
worth savoring because it is where the magic becomes mundane. An empty
derivation (length 0) translates to an empty derivation (length 0), and
`L · 0 = 0`. For the inductive step, suppose we have a length-`k` derivation
reaching `b`, which by hypothesis translates into something of length at most
`L · k`. The derivation extends by one source axiom `b → c`. By the one-step
certificate, that single axiom translates into a target derivation of length at
most `L`. We **concatenate** the two translated pieces. Length is additive under
concatenation — gluing an `m`-step derivation to an `n`-step one yields an
`(m+n)`-step derivation — so the total length is at most `L·k + L = L·(k+1)`.
The bound propagates one rung at a time, exactly matching the growth of the
right-hand side.

That additive concatenation law is the quiet hero. It is the fact that proof
length behaves like a length should: pieces add up. The local promise (cost `L`
per axiom) and the additive bookkeeping (lengths add) together force the global
bound (cost `L · k` for a `k`-step proof). Nothing else is needed.

## The boundary shadow: a Lipschitz proof metric

Holographic propagation is a statement about *derivations* — the bulk objects,
the full chains of reasoning. Its shadow on the *boundary* — the distances — is
immediate and beautiful:

> **Theorem (the proof metric is `L`-Lipschitz).** Whenever `b` is derivable
> from `a` in the source, the translated points satisfy
> `minDerivLen S (map a) (map b) ≤ L · minDerivLen T a b`.

A translator with stretch `L` can never more than `L`-fold inflate proof
distances. The argument is exactly the holographic principle in action: take the
*shortest* source derivation realizing the source distance, push it through
holographic propagation to get a target derivation of length at most
`L · (source distance)`, and note that the target's *shortest* derivation can
only be shorter still.

This is the heart of the matter. The famous Cook–Reckhow notion of
*p-simulation* in proof complexity — one proof system simulating another with
only polynomial blow-up in size — is precisely this Lipschitz condition, read
inside the proof metric. What looked like a statement about sizes of proof
objects is revealed as a statement that translations are *bounded-distortion
maps* of proof geometries. Simulation is contraction. The geometry was hiding in
the complexity theory all along.

## Translations compose; stretches multiply

Languages chain: translate from English to French, then French to Latin, and you
have an English-to-Latin translator. What happens to the cost?

> **Theorem (composition).** If `φ` translates `T` into `S` with stretch `L`,
> and `ψ` translates `S` into `R` with stretch `M`, then for every source axiom
> the composite `ψ ∘ φ` realizes it with a derivation of length at most `M · L`.

The costs **multiply**. And — this is the elegant part — we don't prove this from
scratch. We *reuse* holographic propagation. A single source axiom translates,
via `φ`, into an `S`-derivation of length at most `L`. Feed that derivation
through holographic propagation for `ψ` (which has stretch `M`), and it becomes
an `R`-derivation of length at most `M · L`. The composition law is not a new
axiom about translations; it is a *corollary* of the same engine. This is what
makes the whole subject hang together: the order-theoretic fact that simulation
is transitive, and the metric fact that distances compose, turn out to be two
faces of one underlying mechanism.

## The ruler is exact: holographic rigidity

A Lipschitz bound is an inequality, and an inequality always invites the
question: *is it ever tight?* Could the factor `L` be wasteful, never actually
achieved?

It can be exactly achieved — and the chain theory shows how. Consider the
**doubling translation** of the chain into itself: send each number `n` to `2n`,
with stretch `2`. Why stretch 2? Because the source axiom `n → n+1` lands on
the pair `2n` and `2n+2`, which the chain connects in exactly two steps
(`2n → 2n+1 → 2n+2`). The one-step certificate is satisfied with cost precisely
2, not less.

> **Theorem (holographic exactness on the chain).** For `a ≤ b`,
> `minDerivLen chainT (2a) (2b) = 2 · minDerivLen chainT a b`.

The doubling map multiplies *every* proof distance by exactly 2 — not "at most
2," but exactly. The Lipschitz bound is attained, with zero slack. This is the
extremal, rigid case: the chain has no shortcuts, no redundancy, no give. In the
language of the subject, "zero proof slack" (the chain realizes geodesics) is
*the same phenomenon* as "the Lipschitz constant is attained." Rigidity in the
geometry and tightness in the bound are one fact wearing two hats.

## Why this is more than an analogy

It would be easy to dismiss the word "holography" as poetic decoration. It is
not. The structural content is genuinely the same as the physicists' slogan that
boundary data can encode bulk data:

- The **bulk** is the full space of derivations — every chain of reasoning, of
  every length.
- The **boundary** is the metric — just the distances, a single number for each
  pair of statements.
- The **holographic dictionary** is the pair of theorems above: a local bound in
  the bulk (cost `L` per axiom) determines a global bound on the boundary
  (`L`-Lipschitz distances), and conversely the boundary's rigidity (exact
  doubling) reflects the bulk's lack of shortcuts.

And because all of this is stated for an utterly general notion of "theory" — any
set of atoms with any one-step rules — it is not a story about one proof system
but about the *category* of all of them. Translations are the morphisms; stretch
is the cost; the proof metric is a bounded-distortion functor into the
multiplicative world of natural numbers. The sprawling Cook–Reckhow simulation
order, with its polynomial blow-ups and its separations, becomes the shadow of a
geometry whose every morphism carries a single honest number.

## The takeaway

Start with the humblest possible promise — *"I can translate any one rule using
at most `L` steps"* — and the mathematics does the rest. It guarantees that long
proofs translate with cost at most `L` per step, that proof distances are
distorted by no more than a factor of `L`, that chained translators multiply
their costs, and that on the rigid chain the bound is hit dead-on. A local
certificate becomes a global map. The boundary remembers the bulk.

There is something quietly profound in this. We tend to think of a proof as a
static artifact, a certificate to be checked. Here it becomes a *path* in a
space, with a length and a direction, and translations between logical systems
become *maps* between spaces that bend distances by a bounded amount. Proof
complexity — usually phrased in the dry vocabulary of sizes and polynomials —
turns out to have a geometry, and that geometry is holographic. The shortest way
to say a true thing in one language controls how concisely it can be said in
every language you can faithfully translate into. Translation, it turns out, has
a shape.
