# When Rules Catch Fire: The Hidden Geometry of Proof

Imagine a vast library of "if-then" rules. *If you know A, then you may conclude B.*
Each rule is tiny and local. But chain enough of them together and something
remarkable happens: starting from a single fact, you can suddenly reach an
enormous web of conclusions. Pile on a few more rules and the web can explode —
almost everything becomes provable from almost anything.

This is not a metaphor about human reasoning. It is a precise mathematical
phenomenon, and it behaves exactly like water freezing into ice or a fluid
becoming magnetic: there is a **threshold**. Below it, knowledge stays
fragmented into little islands. Above it, a single spark of information ignites
the whole structure. Mathematicians call such a sudden, sharp change a *phase
transition*, and the study of when a system of logical rules undergoes one is the
**proof phase transition** program.

This article tells the story of the mathematical bedrock underneath that program:
what it means for a fact to be derivable, why derivability is secretly a question
about reachability in a network, how to *certify* that something can never be
proved, why some rules are irreplaceable, how long the shortest proof must be,
and what changes when rules are allowed to combine several facts at once. Every
result below has been established with complete rigor; here we tell the ideas.

## Theories as networks

Start with the simplest possible kind of logical rule: a single premise and a
single conclusion. Write `a → b` for "from `a`, conclude `b`." A **theory** is
just a collection of such rules. If our facts are labelled by some set of *atoms*
(think of them as nodes), then a theory is nothing more than a set of arrows
between atoms — a directed graph.

Now ask the central question: given a theory `T`, when can we get from a starting
fact `a` to a target fact `b`? We are allowed to apply rules in sequence, and we
are allowed to "do nothing" (a fact always follows from itself). The set of facts
reachable this way is called **derivability**, written `a ⊢ b`.

Here is the first clean observation, and it sets the tone for everything:

> **Derivability is reachability.** `a ⊢ b` holds in theory `T` precisely when
> there is a directed path from `a` to `b` in the graph of rules. Formally,
> derivability is the *reflexive–transitive closure* of the rule relation.

This means three things hold automatically. Every fact derives itself (`a ⊢ a`,
the empty proof). Proofs concatenate: if `a ⊢ b` and `b ⊢ c`, then `a ⊢ c`. And a
single rule is a one-step proof. Logic, at this level, *is* graph theory.

## More rules, more proofs — and why that matters

The next fact sounds obvious but is the linchpin of the entire phase-transition
story:

> **Monotonicity.** If every rule of a theory `T` is also a rule of a larger
> theory `T'`, then everything derivable in `T` is still derivable in `T'`.
> Adding rules never destroys proofs.

Why does such a humble statement matter? Because phase transitions live and die by
monotonicity. Picture the rules as switches: each potential arrow between two
atoms can be "on" (present) or "off" (absent). The property "`a` derives `b`" is
then a function of these switches — and monotonicity says that function only ever
turns *more true* as you flip switches on. Functions with exactly this property
are the ones that exhibit sharp thresholds. This is the hypothesis behind the
celebrated theory of sharp thresholds for monotone properties: if you add random
rules one at a time, the moment derivability "switches on" tends to be abrupt, not
gradual. Monotonicity is the mathematical guarantee that a proof phase transition
*can* happen at all.

## How to prove that something is impossible

It is easy to demonstrate that a fact *is* derivable: just exhibit a chain of
rules. But how could you ever prove that a fact can **never** be derived, no
matter how cleverly you apply the rules? You cannot check infinitely many
attempted proofs.

The answer is one of the most elegant ideas in the subject — the **barrier
method**, a logical cousin of the conservation laws in physics.

> **The barrier lemma.** Suppose you can find a set `S` of atoms that (i) contains
> your starting fact `a`, and (ii) is *closed* under the rules: whenever a rule
> leads out of a member of `S`, it lands back inside `S`. Then every fact
> derivable from `a` lies in `S`. So if your target `b` is outside `S`, then
> `a ⊢ b` is impossible.

Think of `S` as a fortress. Your starting fact lives inside, and the closure
property says no rule can ever escape the walls. Anything outside the walls is
forever unreachable. To certify impossibility, you just exhibit the fortress.
This is the exact analogue of a conserved quantity: if some invariant is preserved
by every step, no sequence of steps can change it.

What makes this beautiful is that the barrier method is not merely a clever trick
that *sometimes* works. It is **complete**:

> **Completeness of the barrier method.** A fact `b` is derivable from `a` if and
> only if `b` belongs to *every* closed set that contains `a`. Equivalently,
> `a` fails to derive `b` if and only if there exists a closed barrier set holding
> `a` but excluding `b`.

In other words, *every* true impossibility has a witnessing fortress. There are no
"accidental" non-derivabilities that escape this method. The set of conclusions of
a fact is, precisely, the smallest fortress around it. This is the universal
property that mathematicians recognize as a **closure operator**: the derivability
closure is *extensive* (a set is contained in its closure), *monotone* (bigger
sets have bigger closures), and *idempotent* (closing twice is the same as closing
once). That last property, idempotence, is just transitivity of proof wearing a
different hat.

## The chain: the leanest possible theory

To understand a phenomenon, study its extreme cases. The leanest interesting
theory is the **chain**: atoms are the natural numbers `0, 1, 2, 3, …` and the
only rules are `k → k+1`. Each number points to its successor and nothing else.

The chain is so rigid that everything about it can be computed exactly:

> **The chain boundary.** In the chain theory, `a ⊢ b` holds if and only if
> `a ≤ b`. You can climb upward but never descend. In particular, `1` can never
> derive `0`.

The "never descend" half is a one-line application of the barrier method: take the
fortress to be all numbers `≥ a`. Every rule `k → k+1` keeps you inside, so you can
never reach anything below where you started.

The chain also reveals what it means for a rule to be **essential**. Delete a
single rule, say `m → m+1`, and watch a proof collapse:

> **Criticality.** Remove the one rule `m → m+1` from the chain, and suddenly `0`
> can no longer derive any number `n > m` — the path is severed at `m`. Restore the
> rule and the proof returns. Every rule in the chain is *critical*: each one is a
> single point of failure.

The proof is, once again, a fortress: with the rule `m → m+1` gone, the set
`{0, 1, …, m}` becomes closed, trapping everything below `m+1`. Criticality is the
microscopic origin of phase transitions — it identifies the exact rules whose
presence or absence flips the system.

## How long must a proof be?

Knowing that a proof *exists* is one thing; knowing how *long* it must be is
another, deeper thing. So we refine derivability with a counter: write
`a ⊢ₖ b` to mean "there is a proof of `b` from `a` using exactly `k` rule
applications." Existence of a proof is just "`a ⊢ₖ b` for some `k`."

For the chain, the length is not merely bounded — it is **uniquely determined**:

> **Zero proof slack.** In the chain theory, a `k`-step proof of `b` from `a`
> exists if and only if `b = a + k`. There is exactly one possible proof length,
> namely the gap `b − a`. The chain has no shortcuts and no detours.

Define the **proof distance** `d(a, b)` to be the length of the *shortest* proof
from `a` to `b`. Then for the chain:

> **The diameter theorem.** The shortest proof of `n` from `0` has length exactly
> `n` — the graph distance. The chain realizes the worst case: its proofs are as
> long as the network is wide.

And because adding rules can only ever provide *shortcuts*, never detours, we get a
companion principle that feels almost moral:

> **Proofs only get shorter.** Enlarging a theory can never lengthen the shortest
> proof of any fact. More knowledge means faster reasoning.

This proof distance is the seed of a genuine *geometry of proof*. It is reflexive
(`d(a,a) = 0`), it obeys a directed triangle inequality
(`d(a,c) ≤ d(a,b) + d(b,c)` — going via a waypoint is never faster), and on the
chain the triangle inequality becomes an equality, making the chain a perfect
*geodesic*: a straight line in the space of proofs. The lengths of closed proofs
of the form `a ⊢ a` even form an algebraic object — an additive monoid of natural
numbers — which opens an unexpected door to the theory of numerical semigroups and
their famous "Frobenius numbers." Below a certain rule density a fact has no
nontrivial self-proofs; above it, it acquires a rich cyclic structure. That, in a
phrase, is what a *proof-length* phase transition would look like.

## When rules combine: hypergraphs

So far every rule has had a single premise. Real reasoning is rarely so simple:
modus ponens itself needs *two* facts (`A` and `A → B`) to produce one (`B`). So we
generalize. A **multi-premise rule** has the form `(a₁ and a₂ and … and aₘ) → b`:
you may conclude `b` only once *all* the premises are in hand. A theory of such
rules is a *directed hypergraph*, and derivability becomes a forward closure —
repeatedly fire any rule whose entire premise set is already known.

The miracle is that the two pillars of the whole edifice survive this jump in
generality, essentially word for word:

> **Monotonicity, twice over.** The hypergraph closure grows both when you add
> rules and when you add starting assumptions.

> **The hypergraph barrier method.** If a set `C` contains your assumptions and is
> closed under every rule whose premises *all* lie in `C`, then `C` contains the
> entire closure. The fortress argument does not care how many premises a rule
> consumes.

This last point is the quiet punchline. The conserved-quantity certificate — the
fortress — is *premise-arity-agnostic*. The very same kind of barrier that proves
impossibility for simple chains will prove impossibility for arbitrarily
complicated multi-premise systems. And to confirm that nothing is lost in
translation, there is a bridge:

> **The single-premise bridge.** If every rule happens to have just one premise,
> hypergraph derivability collapses *exactly* onto ordinary graph reachability. The
> simple theory is the one-premise slice of the rich one.

## Why this is a foundation, not a footnote

Each result here is modest on its own. Their power is cumulative. Together they say
that a body of logical rules is simultaneously three things: a **network** (whose
reachability is derivability), an **order** (a preorder with a closure operator),
and a **geometry** (with a proof distance, triangle inequalities, and geodesics).
The barrier method gives a *complete* language for impossibility; monotonicity
guarantees that thresholds can be sharp; criticality pinpoints the rules that
trigger them; proof length turns "can it be done" into "how fast"; and the
hypergraph generalization shows the whole story is robust.

What does it buy us? A vocabulary for asking — and answering — questions like:
*As random rules are added to a system, at what density does it tip from "almost
nothing is provable" to "almost everything is"? How sharp is that tip? When it
happens, how do proof lengths behave — do they stay long like a chain, or collapse
to near-instant?* These are the questions of automated reasoning, of the spread of
information through networks, of the robustness of knowledge to the loss of a
single fact. The thermodynamics of proof is no longer a slogan. It has a
foundation — and this is it.
