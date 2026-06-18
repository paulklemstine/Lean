# When Logic Freezes: The Hidden Phase Transitions Inside Proofs

Heat a block of ice and, for a long while, almost nothing happens. The temperature
climbs degree by degree, the ice stays ice — and then, at exactly zero degrees Celsius,
the whole structure surrenders at once and becomes water. Physicists call this a *phase
transition*: a sharp, almost violent change in the global behavior of a system as you
turn a single knob.

Phase transitions are everywhere once you learn to look for them. A scattering of roads
between towns stays a disconnected patchwork until you add just enough of them, and then
— suddenly — almost every town can reach almost every other. A jumble of logical
constraints in a satisfiability problem is easy to satisfy until you cross a critical
density, after which it becomes essentially impossible. The thresholds are razor-sharp,
and where they sit, and why, is one of the great recurring stories of modern mathematics.

This article is about a phase transition you have probably never imagined: one that
happens *inside the act of proving things*. It turns out that "can this be proved from
those assumptions?" behaves exactly like "can this town be reached from that one?" —
and that a small, sturdy pair of mathematical ideas governs the whole phenomenon, all
the way from the simplest chains of reasoning to the tangled multi-premise rules that
power real logical systems.

## Reasoning as a road map

Start with the most stripped-down picture of reasoning imaginable. Forget complicated
sentences; just think of *atoms* — indivisible facts, which we will write as `a`, `b`,
`c`, and so on. A **rule** is a single arrow `a → b`, read "from `a` you may conclude
`b`." A collection of such rules is what we will call an **implicational theory**.

Mathematically, a theory is nothing more than a relation `T` that tells you, for any two
atoms `a` and `b`, whether the arrow `a → b` is one of your rules. You can picture it as
a directed graph: dots for atoms, arrows for rules.

Now, what does it mean to *prove* something? If you already know `a`, and you have the
rule `a → b`, you may write down `b`. If you then have `b → c`, you may write down `c`.
A **proof** of `b` from `a` is just a chain of arrows leading from `a` to `b`. In other
words:

> **Derivability is reachability.** A fact `b` is provable from a fact `a` precisely
> when there is a directed path from `a` to `b` in the graph of your rules.

Formally, derivability is the *reflexive–transitive closure* of the rule relation: the
smallest relation that includes every rule, lets you stay put (you can always "prove" `a`
from `a` with the empty proof), and lets you concatenate proofs end to end. We write
`Derivable T a b` for "the theory `T` proves `b` from `a`."

This little dictionary — proof = path, theory = graph, atom = node — is the seed from
which everything grows. It is humble, but it is exactly faithful, and it lets us import
the entire arsenal of reachability mathematics into the study of proofs.

## The first pillar: more rules can only help

Here is the first of two structural facts that everything rests on, and it is so
obvious-sounding that its power is easy to miss.

> **Monotonicity.** If `T` is a theory and `T'` contains all of `T`'s rules and possibly
> more, then anything provable in `T` is provable in `T'`.

In symbols: if every arrow of `T` is also an arrow of `T'`, then `Derivable T a b`
implies `Derivable T' a b`. Adding rules never destroys a proof you already had — you
just ignore the new rules. The old path is still there.

Trivial? Yes. Indispensable? Absolutely. Monotonicity is the precise property that makes
a *threshold* possible. Imagine sprinkling rules into your theory at random, one by one,
and watching the proposition "`a` is provable from `b`." Because of monotonicity, this
proposition is a one-way switch: once it flips from false to true, it can never flip
back. A quantity that only ever increases as you add ingredients is exactly the kind of
quantity that can have a sharp critical point. In the theory of random structures,
monotone events are the events that obey sharp-threshold theorems. So monotonicity is
not a footnote — it is the *license* to even ask, "Where is the phase transition?"

## The second pillar: how to prove that something is impossible

Monotonicity tells you that proofs, once available, stay available. But the heart of a
phase transition is the *other* side: the regime where things are **not** provable. How
do you ever certify that no proof exists? You cannot try infinitely many proofs and
report that they all failed.

The answer is a beautifully simple device that mathematicians rediscover in a hundred
guises — the *invariant*, the *conserved quantity*, the *cut*. Here we call it a
**barrier**.

> **The barrier method.** Suppose you can find a set `S` of atoms with two properties:
> (1) your starting fact `a` is inside `S`, and (2) `S` is *closed* under the rules —
> whenever an atom in `S` has a rule pointing out of it, the target also lands back
> inside `S`. Then **every** fact provable from `a` is also inside `S`.

The proof is a one-line induction: you start inside `S`, and every legal step keeps you
inside `S`, so you can never escape. The consequence is a universal certificate of
impossibility: if your target `b` lies *outside* `S`, then `b` is unreachable — no proof
of `b` from `a` can exist, ever. The set `S` is a wall that proofs cannot climb over.

This is the same idea as proving you can't get from one room to another because there's a
locked door between them, or that a chess knight can never reach a square of the wrong
color. Find the right invariant — the right "color" — and impossibility becomes
self-evident.

Together, **monotonicity** and **barriers** are the two load-bearing columns of the
entire edifice. One governs the "provable" world; the other governs the "unprovable"
world; and the phase transition is the knife-edge between them.

## The simplest possible world: chains

To see both pillars in action, consider the leanest theory that can prove anything
interesting: the **chain**. Its atoms are the natural numbers `0, 1, 2, …`, and its only
rules are `0 → 1`, `1 → 2`, `2 → 3`, and so on — each number points to its successor and
nowhere else. This is the minimal theory that lets `0` reach a distant number `n`.

Two clean facts pin it down completely.

First, a **sharp boundary**: in the chain theory, `a` proves `b` **if and only if**
`a ≤ b`. The "if" direction is the path `a → a+1 → ⋯ → b`. The "only if" direction is a
perfect little barrier argument: take `S` to be the set of all numbers `≥ a`. Every rule
only ever *increases* a number, so `S` is closed, `a` is in it, and therefore every
provable target is `≥ a`. You simply cannot prove your way backward down the chain. One
invariant — "the number can't decrease" — settles every impossibility question at once.

Second, **criticality**. The chain is so lean that it has no redundancy: every single
rule is essential. Delete just one arrow, say `m → m+1`, and the chain shatters. Now the
set `S` of all numbers `≤ m` is closed (the only rule that could have escaped it was the
one you deleted), so nothing beyond `m` is reachable from `0`. Concretely, `0` can no
longer prove any `n > m`. Restore the arrow and the proof returns. Every rule has what
we call **criticality index 1**: removing any one of them, by itself, breaks the proof.

This is the proof-theoretic version of a *backbone* — the set of constraints so essential
that the whole structure depends on each of them individually. And notice how it was
proved: the deleted theory is a sub-theory of the full one (that's monotonicity), and the
prefix `{0, 1, …, m}` is exactly the barrier the deletion creates (that's the barrier
method). The two pillars, working together, give the first fully rigorous "criticality
index 1" statement.

## How long is the proof? A second, sneakier threshold

There is more to a proof than whether it exists; there is also *how long it is*. In the
chain, the proof of `n` from `0` is the path `0 → 1 → 2 → ⋯ → n`, and it has length
exactly `n` — one step per arrow, matching the diameter of the graph. There is no
shortcut, because the chain offers no alternative routes.

This rigidity is the cleanest possible anchor for a far richer question that physicists
of computation care about deeply: as you add rules to a random theory, does the *length*
of the shortest proof undergo its own phase transition? Below the existence threshold,
the shortest proof has infinite length (there is none); above it, proofs not only appear
but rapidly become short, their length collapsing toward the logarithm of the number of
atoms — the same way the diameter of a random graph collapses once it becomes connected.
The chain's rigid "the proof length is exactly the distance" is the deterministic
bedrock on which that random story is built. And crucially, length-graded monotonicity
holds too: adding rules can only make the shortest proof *shorter*, never longer.

## The leap to many premises

So far every rule has had a single premise: one fact in, one fact out. But real
reasoning is rarely so tidy. We constantly use rules with *several* premises at once:
"if it is raining **and** I have no umbrella, then I will get wet." In the language of
logic, these are rules of the form

> `(a₁ and a₂ and … and aₖ) → b`,

and a theory made of them is no longer a directed graph but a directed **hypergraph** —
a structure where an arrow can gather up many sources before it fires. This is precisely
the world of constraint-satisfaction and `k`-SAT problems, the proving grounds where the
most famous phase transitions of computer science live.

The natural worry is that our two beautiful pillars were a fluke of the single-premise
world and will crumble here. The remarkable answer is that they do not. The entire
framework lifts, almost word for word, to multi-premise rules.

We model a **hypertheory** `R` as a set of rules, each a pair `(premises, conclusion)`
where `premises` is a list of atoms. Starting from a set `S` of assumed facts, we define
**hypergraph derivability** `HDeriv R S a` as the smallest collection of atoms that
(1) contains all of `S`, and (2) is closed under firing any rule *all* of whose premises
have already been derived. It is the natural "forward closure": keep applying rules whose
prerequisites are met until nothing new appears.

With that single definition in place, both pillars come back to life — now in fact
*stronger* than before, because there are two things to be monotone in:

> **Rule monotonicity.** Enlarging the hypertheory enlarges the closure: if `R ⊆ R'`,
> then anything derivable using `R` is derivable using `R'`. (More rules, more proofs —
> exactly as before.)

> **Assumption monotonicity.** Enlarging the set of starting assumptions enlarges the
> closure: if `S ⊆ S'`, then anything derivable from `S` is derivable from `S'`. (More
> givens, more conclusions.)

And the barrier method survives *verbatim*, completely indifferent to how many premises a
rule consumes:

> **The hypergraph barrier.** If a set `C` contains all the assumptions `S`, and is
> closed under every rule *all* of whose premises lie in `C`, then `C` contains the
> entire closure.

This is the punchline the whole program was reaching for. The barrier — the conserved
set, the wall — has *exactly the same shape* whether your rules have one premise or one
hundred. A rule with many premises is even *easier* to wall off, because it only fires
when *all* its premises are already inside the wall. The certificate format does not
change with the number of premises. The very same `{numbers ≤ m}`-style cuts that prove
impossibility for simple chains will prove impossibility for sprawling random hypergraphs.

## The bridge home

A generalization is only trustworthy if the original lives inside it unscathed. So we
check: take an ordinary single-premise theory `T` with its arrows `a → b`, and turn each
arrow into the one-premise hypergraph rule `([a], b)`. Does hypergraph derivability from
the single assumption `{a}` agree with plain old reachability?

It does — **exactly**. We prove that `HDeriv` over these one-premise rules, started from
`{a}`, holds for `b` if and only if `Derivable T a b` holds in the original graph sense.
The single-premise world is recovered as a perfect slice of the multi-premise world. The
generalization is *conservative*: it adds power without disturbing anything that came
before. The chain, its sharp boundary, and its criticality all sit untouched inside the
larger theory as the "one premise" special case.

## Why this matters

Step back and look at the shape of what we have. We took the act of proving — something
that feels singular, creative, human — and revealed it as a structure governed by the
same two principles that govern percolating fluids, connecting networks, and freezing
crystals: a quantity that only grows (monotonicity), and a wall that cannot be crossed
(a barrier). The phase transition between "unprovable" and "provable" is the boundary
those two principles carve out.

The payoff is twofold. First, it turns a metaphor into mathematics. People have long
spoken loosely of a "proof phase transition" — a density of axioms below which a theory
is impotent and above which it suddenly becomes powerful. The monotonicity pillar is
exactly the hypothesis the sharp-threshold theorems of probability demand, so that loose
talk can now become a theorem: random implicational theories really do have a critical
density, expected to sit near `(log n)/n` for `n` atoms, just like the connectivity
threshold of a random graph.

Second, it builds a bridge. By lifting the framework to multi-premise hypergraph rules
without losing either pillar, we connect formal proof theory directly to the random
`k`-SAT problem — perhaps the single most studied phase transition in all of theoretical
computer science. The same barrier certificates, the same criticality backbones, the same
monotone-event machinery now span both fields. A locked door in a chain of natural
numbers and an unsatisfiable cluster in a random Boolean formula turn out to be the same
phenomenon wearing different clothes.

Ice and water; isolated towns and a connected continent; an unprovable conjecture and a
one-line proof. The lesson, again and again, is that nature — and logic — likes to change
its mind all at once. We have found one more place where it does, and named the two
pillars that hold the doorway open.
