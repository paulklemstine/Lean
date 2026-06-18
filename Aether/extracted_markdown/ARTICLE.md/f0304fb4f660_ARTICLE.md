# When Proofs Suddenly Become Possible: The Hidden Tipping Points of Logic

## A puzzle about rules and conclusions

Imagine you are handed a heap of rules of a single simple kind. Each rule says: *if you
have A, you may conclude B.* Nothing more. No "and", no "or", no exceptions. Just a one-way
street from one fact to another. Logicians call such a rule an **implication**, and a pile
of them an **implicational theory**.

Now play a game. Pick two facts, a starting point and a destination. Using only your rules,
and chaining them together, can you get from start to finish? If the rules are
"A → B", "B → C", "C → D", then yes — you can travel from A all the way to D by hopping
along the chain. But if you are missing even one link, the journey may be impossible.

This little game looks like a toy. It is, in fact, a doorway into one of the most beautiful
phenomena in modern mathematics: **phase transitions**. The same abrupt switch that turns
water into ice, or a scattered crowd into a stampede, governs whether logical conclusions
can be reached at all. Add rules one at a time to a random collection, and for a long while
your destination stays stubbornly unreachable. Then, almost without warning, it becomes
reachable — and the switch happens over a vanishingly thin window. Proof, it turns out, has
a freezing point.

This article tells the story of the mathematical scaffolding that makes this idea precise.
It is built from five clean, fully verified structural facts about implicational theories.
Together they reveal why "can I prove this?" is, at heart, a question about graphs, about
monotonicity, and about tipping points.

## Rules are arrows; proofs are paths

The first move is the one that makes everything else fall into place. Forget logic for a
moment and think about a map. Draw a dot for every fact. For every rule "A → B", draw an
arrow from dot A to dot B. What you get is a **directed graph** — a network of one-way
streets.

In this picture, a proof is nothing more than a *route*. To prove that A leads to B, you
trace a path of arrows from A to B. The "destination is reachable" question becomes the
utterly concrete "is there a path from here to there?"

We can say this formally. An implicational theory `T` is just a relation: `T a b` means the
rule "a → b" is in your pile. **Derivability** — written `Derivable T a b` — is defined as
the *reflexive–transitive closure* of `T`. That phrase has a friendly meaning:

- *Reflexive*: every fact proves itself, with the empty proof. `Derivable T a a` always holds.
- *Transitive*: if you can get from a to b and from b to c, you can get from a to c by
  splicing the two journeys. `Derivable T a b` and `Derivable T b c` give `Derivable T a c`.
- And a single rule is a single step: if `T a b`, then `Derivable T a b`.

That is the whole definition of proof in this world: start where you are, take rule-steps,
and reflexive–transitive closure is the mathematician's exact name for "all the places you
can walk to." Proof equals reachability. This identification is the seed from which the
entire phase-transition story grows.

## Pillar one: more rules can only help

Here is something that feels obvious but turns out to be the crucial technical hinge.
Suppose you have a theory `T`, and a richer theory `T'` that contains every rule of `T` and
maybe more. Anything you could prove with `T`, you can still prove with `T'`. Adding rules
never destroys a proof; it can only create new ones.

In our verified development this is the theorem **`theory_extension_monotone`**: if every
axiom of `T` is also an axiom of `T'`, then `Derivable T a b` implies `Derivable T' a b`.
Said another way, the map that takes a theory and returns the truth value of "a derives b"
is **monotone** — it can only flip from *false* to *true* as you add rules, never back. We
call this companion fact **`derivable_monotone`**.

Why does such a modest statement matter so much? Because monotonicity is the magic
ingredient behind sharp thresholds. A property of a random network that only ever "turns
on" as you add edges — never off — is exactly the kind of property that, by a celebrated
result of Ehud Friedgut, must switch from "almost never true" to "almost always true"
across a knife-thin window. Monotonicity is the admission ticket to the phase-transition
theater, and derivability has one.

## Pillar two: the barrier method, or how to prove that a proof is impossible

It is one thing to find a proof; you just exhibit the path. It is far subtler to prove that
*no* proof exists — that no matter how cleverly you chain your rules, the destination stays
out of reach. How could you ever be sure you have not simply missed a route?

The answer is one of the most elegant tricks in the subject, and it is captured by a single
short lemma we call the **barrier method** (`refl_trans_gen_closed`). The idea: find a
"safe zone" — a set `S` of facts — with two properties.

1. Your starting fact lives inside `S`.
2. `S` is *closed* under the rules: every arrow that starts inside `S` also lands inside `S`.

If such an `S` exists, then every fact you can ever reach from your start must also lie in
`S`. The reason is a clean induction: you begin in `S`, every step keeps you in `S`, so you
can never escape. Consequently, *anything outside `S` is unprovable.*

This is the logical cousin of a conservation law in physics. To show a ball can never roll
uphill past a certain height, you point to energy. To show a proof can never reach a certain
fact, you point to a barrier set it can never cross. Non-derivability, which sounds like a
statement about infinitely many failed attempts, collapses into the finite act of
exhibiting one invariant cut.

## Pillar three: the chain, where everything is exactly computable

To see all of this in its sharpest form, we study the simplest interesting theory of all:
the **chain**. Its facts are the natural numbers 0, 1, 2, 3, …, and its only rules are
"k → k+1." You can step from any number to the very next one, and that is all.

For this theory we prove a complete, decidable description of provability — the theorem
**`chain_derivable_iff`**:

> In the chain theory, `a` derives `b` **if and only if** `a ≤ b`.

Every reachable destination is exactly the set of numbers at least as large as where you
started. The two halves of this equivalence showcase the two halves of the whole subject.
The forward direction (`chain_derivable_le`) *constructs* a proof: if `a ≤ b`, walk
`a → a+1 → ⋯ → b`. The backward direction (`chain_barrier_closed`) *forbids* the impossible:
using the barrier method with the safe zone "all numbers ≥ a", we show no proof can ever
decrease a number. A clean corollary, `chain_no_backward`, records the punchline that 1 can
never prove 0. There are no shortcuts and no surprises — the chain is the perfectly
understood extreme against which the wild behavior of random theories can be measured.

## Pillar four: every rule in a minimal theory is irreplaceable

The chain is not just simple; it is *lean*. It contains no redundancy whatsoever. We make
this precise with the notion of a **critical** axiom — a rule whose removal breaks a proof.

Consider deleting a single rule "m → m+1" from the chain, leaving every other rule intact.
Our theorem **`chain_axiom_critical`** shows that this single deletion is catastrophic for
journeys that needed to cross that gap: with the rule "m → m+1" gone, you can no longer
derive m+1 from 0. The bridge is out, and there is no detour, because the chain offered only
one road. Yet — and this is the reassuring counterpart, **`chain_axiom_restorable`** — the
*full* theory, with the rule back in place, derives m+1 from 0 once more. Removing breaks it;
restoring fixes it.

This is the proof-theoretic version of a load-bearing wall. In a minimal structure, every
component carries weight. The "criticality index" of every chain axiom is exactly 1: it
takes the removal of just that one rule to sever a proof. This extremal tightness is what
makes the chain the natural yardstick for measuring how much *slack* a richer, random theory
carries — how many rules it could afford to lose and still prove what it needs.

## Pillar five: the proof you can hold in your hand

Existence proofs can feel like sleight of hand: *a route exists*, but where is it? For the
chain we leave nothing to the imagination. We build the explicit derivation
`0 → 1 → 2 → ⋯ → n` as a concrete list of steps and verify two things about it: that it is a
genuine chain of valid rule-applications (`chainPath_chain`), and that its length is exactly
`n` (`chainPath_length`).

This matters because **length is the currency of proof complexity**. A theorem may be
provable, but is its shortest proof short or astronomically long? The chain gives the cleanest
possible answer: to travel from 0 to n you must take exactly n steps, no more and no fewer.
The minimal theory yields the minimal proof, and we can point to it. This identity between
the "diameter" of the rule-graph and the length of the proof is the first rung on a ladder
that climbs toward one of the great questions of computer science: when are short proofs
guaranteed to exist, and when must every proof be hopelessly long?

## The bigger picture: proofs that freeze and thaw

Step back and assemble the five pillars. We have shown that derivability is graph
reachability; that it grows monotonically as rules are added; that impossibility is
certified by barriers; that the chain pins down the boundary exactly; that minimal theories
have no redundancy; and that proofs can be made fully explicit with measurable length.

Now imagine throwing rules in at random. Picture `n` facts, and for each possible arrow flip
a weighted coin: include it with probability `p`, leave it out otherwise. As you turn the dial
`p` up from 0 toward 1, you are slowly filling in the rule-graph. At first, your chosen
destination is almost surely unreachable — the graph is too sparse, too many barriers stand
in the way. But because reachability is *monotone* (pillar one), and because monotone
properties of random graphs obey sharp-threshold laws, there is a critical probability
`p*` at which the situation flips. Below it: almost surely no proof. Above it: almost surely
a proof. And the transition happens over a window so narrow it shrinks to nothing as `n`
grows.

This is the phase transition of proof itself. It is the same mathematics that explains why a
liquid does not gradually thicken into a solid but freezes at a definite temperature, and why
a sparse random network does not slowly accumulate connectivity but suddenly acquires a giant
connected component. The deep claim of this research program is that **whether a conclusion
can be proven** is a phase variable, with a critical point, a sharp threshold, and — once you
look closely — a whole thermodynamics of its own.

The everyday resonance is striking. Knowledge spreads through a community by exactly this kind
of chaining: each person who knows a fact can pass it to a neighbor. Whether an idea reaches
the far side of the network depends, abruptly, on how densely the connections are woven.
Diseases, rumors, financial contagion, the percolation of water through rock — all obey the
same arithmetic of tipping points. What this work adds is the realization that **logical
deduction belongs to the same family.** A proof is a journey, a theory is a landscape, and
somewhere out there is the freezing point where the impossible becomes inevitable.

## What has been nailed down, and what comes next

Everything above rests on a small set of completely verified structural theorems: proof as
reachability, monotonicity, the barrier method, the chain's sharp boundary, axiom
criticality, and the constructive minimal-length witness. These are not conjectures or
sketches; they are the load-bearing foundation.

The frontier is to formalize the probabilistic transition itself — to prove, with full rigor,
that random implicational theories have a sharp threshold via Friedgut's theorem; to study how
*long* proofs must be on either side of that threshold; to widen the lens from single-premise
rules to multi-premise rules (which turn graphs into hypergraphs and connect directly to the
famous k-SAT transition); and to map out the "thermodynamics" of the derivability order,
where a giant class of mutually-provable facts crystallizes out at criticality, just as a
giant component emerges in a random graph.

The toy game of arrows and paths, it turns out, was never a toy. It was a window onto the
moment when reasoning itself snaps into place.
