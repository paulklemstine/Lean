# Consistency Is Existence: The Hidden Bridge Between Logic and the Physical World

## A slogan that refused to die

For more than a century, a curious sentence has echoed through the foundations of mathematics and physics. David Hilbert, the great organizer of modern mathematics, put it bluntly: **"If the arbitrarily given axioms do not contradict one another, then they are true, and the things defined by the axioms exist."** Logicians later sharpened it into a four‑word creed:

> **Consistency is existence.**

It sounds almost mystical. How can the mere *absence of contradiction* — a purely logical, paper‑and‑pencil property — guarantee that something *exists*? And what, exactly, does "existence" mean for a set of physical laws?

This article is about turning that slogan into a theorem. Not a vague philosophical gesture, but a precise, airtight equivalence that a machine can check, stated in a way that applies equally to a toy logic puzzle, a thermodynamic engine, or a model of the cosmos. The punchline is simple enough to fit on a napkin:

> **A body of physical laws can be realized by some concrete state of the world if and only if those laws are logically consistent.**

Everything else — the explosion of impossible worlds, the way laws compose across independent subsystems, the no‑go theorems that forbid certain universes — falls out of this one bridge almost for free.

## What is a "law," really?

Let's start from the ground up, because the magic is hidden in the definitions.

Imagine a **state space** `S`: the set of all conceivable configurations of some system. A point of `S` might be the position and momentum of a planet, the spin of every particle in a crystal, the truth values of a hundred propositions, or the contents of a computer's memory. We don't care what `S` is made of — that's the whole point.

A **law** is just a yes/no question you can ask about a state: a predicate `p` that is either satisfied or violated at each configuration. "Energy equals 5." "The particle is to the left of the origin." "Variable `x` is positive." Formally, a law is a function from states to truth values, `p : S → Prop`.

A **theory** `T` is simply a *collection of laws* — the bundle of rules you want your world to obey. In the formal language this is breathtakingly economical:

> **`Theory S := Set (S → Prop)`** — a theory is a set of predicates over the state space.

Now the key notions.

- A state `s` is a **model** of the theory `T` when it obeys *every* law in `T` at once:
  > **`IsModel T s := ∀ p ∈ T, p s`.**
- The theory is **realizable** when at least one such state actually exists — when the world *can* be the way the laws demand:
  > **`Realizable T := ∃ s, IsModel T s`.**

This is the physicist's notion of possibility. A realizable theory is one you could, in principle, point to a universe and say "there, that one satisfies all my rules."

On the logician's side, we need two more ideas.

- A theory **entails** a law `φ` when every model of the theory is forced to satisfy `φ` — `φ` is an unavoidable consequence of the rules:
  > **`Entails T φ := ∀ s, IsModel T s → φ s`.**
- And finally, the absurd law `⊥` is the predicate that is *false at every state* (`fun _ => False`). A theory is **consistent** precisely when it does **not** entail this absurd law:
  > **`Consistent T := ¬ Entails T (fun _ => False)`.**

Read that last definition slowly. Consistency is the refusal of your laws to logically force an impossibility. It is a statement purely about *entailment* — about what follows from what — with no mention whatsoever of whether any world exists.

## The bridge

Here is the central theorem, in full:

> **The Logic–Physics Bridge.** For any theory `T` over any state space `S`,
> $$\textbf{Realizable } T \;\Longleftrightarrow\; \textbf{Consistent } T.$$

Physical realizability — the existence of a concrete state obeying the laws — is *exactly the same thing* as logical consistency — the laws not entailing a contradiction. Two notions that seem to live in different universes turn out to be one notion wearing two costumes.

Why is it true? Strip away the names and the theorem becomes a single line of classical logic. Realizability says *"there exists a state `s` that models `T`."* Consistency says *"it is **not** the case that every model of `T` satisfies False"* — which, since "satisfies False" can never happen, reduces to *"it is **not** the case that there are no models."* And "there exists a model" versus "it is not the case that there are no models" are the same statement — provided you accept the law of the excluded middle. That single classical step, `(∃ s, P s) ↔ ¬(∀ s, ¬ P s)`, *is* the bridge.

This is the deepest lesson of the whole enterprise: **all the mathematical content lives in choosing the right primitive notions.** Once you define consistency *semantically* (as "does not entail ⊥") rather than syntactically (as "no proof of contradiction exists in some calculus"), the grand equivalence becomes a one‑line unfolding. The hard part was never the proof; it was finding the definitions that make the proof inevitable.

## Five consequences, almost for free

A good bridge is one you can drive a truck across. From the central equivalence, a whole calculus of realizability follows with almost no extra effort. Each of these is a genuine theorem.

### 1. Explosion: the impossible world believes everything

> **Principle of explosion.** If `T` is *not* realizable, then `T` entails *every* law `φ`.

In classical logic this is *ex falso quodlibet* — "from falsehood, anything." Here it gets a vivid physical reading. If no world can satisfy your laws, then the statement "every world satisfying my laws also satisfies `φ`" is *vacuously true*, no matter what `φ` says. An impossible universe is a universe in which every prediction holds, simply because there are no counterexamples to refute it. A theory that forbids existence is a theory that "proves" everything — and therefore tells you nothing.

### 2. The duality: entailing absurdity is impossibility

> **`Entails T ⊥ ⇔ ¬ Realizable T`.**

This is the bridge restated from the other side: a theory entails the absurd law if and only if it cannot be physically realized. Inconsistency and impossibility are literally the same condition.

### 3. Monotonicity: fewer laws, easier to satisfy

> **Monotonicity.** If `T ⊆ T'` (every law of `T` is also a law of `T'`) and `T'` is realizable, then `T` is realizable.

Weakening a theory — dropping some of its laws — can only make it *easier* to realize. The very state that satisfied the stronger theory already satisfies the weaker one. Demand less of the world, and the world has more room to comply. This is the formal heartbeat of Occam's razor and of every "relax the constraints" move in engineering.

### 4. No‑go: contradiction forbids existence

> **No‑go theorem.** If a theory contains both a law `p` and its negation `¬p`, then it is not realizable.

No state can simultaneously satisfy `p` and `not p` — that is the meaning of negation. So a theory harboring an explicit contradiction can never be brought to life. This is the abstract template behind every physical impossibility result: a perpetual‑motion machine, a faster‑than‑light signal, a measurement that violates the uncertainty principle. In each case, the "laws" of the proposed device secretly contain both a claim and its denial.

### 5. Compositionality: independent worlds coexist exactly when each is possible

This one is the most physically resonant. Suppose you have two *independent* subsystems with their own state spaces `S` and `S'` and their own theories `T` and `T'`. We can form a **product theory** on the joint space `S × S'`: a law of the combined system is either a law of the first subsystem (applied to the first coordinate) or a law of the second (applied to the second coordinate). Then:

> **Compositionality.** The combined system is realizable **iff** each subsystem is realizable on its own:
> $$\textbf{Realizable}(T \times T') \;\Longleftrightarrow\; \textbf{Realizable } T \;\wedge\; \textbf{Realizable } T'.$$

Independent possible worlds coexist exactly when each is individually possible. There is no spooky interference: gluing two consistent universes together never manufactures a contradiction, and it never destroys one either. Possibility is *modular*. This is why physicists can study a hydrogen atom and a distant galaxy with separate models and trust that the combined description is coherent.

## Does the bridge ever carry real weight?

A theorem about empty abstractions would be a hollow victory, so the framework is tested on an honest physics example. Take a real‑valued state space and impose an **energy‑conservation law** — the predicate that energy takes a fixed admissible value. Such a theory is *realizable*: one can exhibit a concrete state at exactly that energy, certifying that the abstract machinery describes something real.

Push harder, and you get a genuine physical no‑go. Posit a two‑level system and demand, contradictorily, that it sit *simultaneously* in two distinct energy levels with incompatible defining conditions. The no‑go theorem fires: such a theory contains a law and its negation, so **no state can realize it.** The contradiction in the laws becomes an impossibility in the world — exactly as the bridge predicts.

## Time enters the picture

So far everything has been *static*: a single snapshot of the world obeying a fixed set of rules. But physics is about *change*. Does the bridge survive the leap to dynamics?

It does, and beautifully. Consider a **dynamical law** as a step relation: a rule saying which states may follow which. Call the relation **serial** if from every state there is *always* at least one legal next state — the system is never stuck, never painted into a corner with nowhere to go. (Modal logicians know this property as axiom **D**; it characterizes Kripke frames in which "necessarily" implies "possibly.")

> **Eternal trajectories.** If the set of initial states is nonempty and the step relation is serial, then there exists an *infinite trajectory* — a complete, never‑ending history of the system threading legally from each state to the next.

A non‑stuck evolution law evolves *forever*. And here the second, deeper twist appears: building that infinite future requires, at each step, *choosing* one of the available successors. This is the **Axiom of Choice** doing physical work — promoting a local "a next state exists" into a global "here is the entire future." Just as classical logic was the single nonconstructive ingredient in the static bridge, choice is the single nonconstructive ingredient in the temporal one. Nothing else is needed.

Most elegantly, temporal realizability turns out to be **literally an instance of the static bridge**: the existence of an eternal trajectory is just the realizability of a cleverly chosen "trajectory theory" over the space of infinite histories. The dynamical picture does not require new foundations; it is the static picture, applied to the right state space. Time is not an exception to the logic–physics correspondence — it is one of its examples.

## Why this matters

Step back and look at what has been established. Two words from two different worlds — **realizable**, the physicist's word for "could exist," and **consistent**, the logician's word for "free of contradiction" — have been proved to mean the same thing, in a setting so general it doesn't care whether you're talking about planets, propositions, or programs. And from that single identity flows a working toolkit: explosion, duality, monotonicity, no‑go theorems, compositionality across subsystems, and even the eternal march of dynamical time.

The grand surprise is the *economy* of it all. The entire logic–physics correspondence rests on exactly two nonconstructive ingredients — classical logic for the static half, the Axiom of Choice for the dynamical half — and not one thing more. Everything else is forced the moment you choose the right definitions. The deepest bridges in mathematics are often like this: not monuments of intricate argument, but a sudden recognition that two things you thought were different were never really two things at all.

Hilbert's slogan, it turns out, was not a piece of optimism. It was a theorem waiting for its definitions. Consistency really is existence — and now we can prove it.
