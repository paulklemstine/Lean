# The Arrow That Points Both Ways: How Mathematics Reveals the Logic of Time Reversal

*What if causes could follow effects? A new algebraic framework shows that backward-in-time reasoning obeys different logical rules — and the difference reveals a deep connection between time, truth, and contradiction.*

---

## The Question That Keeps Physicists Up at Night

Every fundamental equation in physics works just as well run backward. Drop a ball, and Newton's laws describe both its fall and, if you reverse the film, its rise. The electromagnetic equations that govern radio waves, the quantum mechanical laws that describe atoms, even Einstein's general relativity — none of them care which direction time flows. The laws of physics are, as physicists say, *time-reversal symmetric*.

And yet the universe clearly has a direction. Eggs break but don't unbreak. Coffee cools but doesn't spontaneously heat up. We remember the past but not the future. This tension — between the time-symmetric laws and the time-asymmetric world — is one of the deepest puzzles in physics.

But there's an even stranger implication lurking beneath the surface, one that touches not physics but *logic itself*. If the laws of nature can run backward, what happens to logical reasoning under time reversal? Does "if A then B" still mean the same thing when time is reversed? Does the basic principle that "every statement is either true or false" survive when effects can precede their causes?

The answer, it turns out, is no — and the way it fails is beautiful.

## Two Kinds of Negation

To understand what happens to logic under time reversal, we need to look at a mathematical structure called a *bi-Heyting algebra*. Don't let the name intimidate you — the idea is elegant.

Ordinary logic gives us one way to negate a statement. "It is not raining" is the negation of "it is raining." But when you have both forward and backward reasoning, two distinct notions of negation emerge.

Think of it this way. In forward reasoning, the negation of a statement P is the *strongest thing implied by P being false*. If the sky is clear, you can conclude "not raining" — and from "not raining" you can infer other things (picnic is on, no need for an umbrella). This is called the *Heyting complement*, and it's the kind of negation familiar from constructive mathematics.

But there's a second kind of negation that arises naturally when you can reason backward. The *co-Heyting negation* of P is the *weakest thing from which P's falsity follows*. It's asking: what's the minimal assumption from which we can retrodict that P didn't happen?

In classical logic, these two negations coincide. "Not P" is "not P" — there's only one way to negate. But in the richer logical landscape of bi-Heyting algebras, they can diverge. And when they do, something remarkable happens.

## The Temporal Excluded Middle

The law of excluded middle — "every statement is either true or false" — is the bedrock of classical reasoning. Mathematicians have debated its validity for over a century. Constructivists argue that you shouldn't claim a statement is true or false unless you can actually demonstrate which one it is.

The new framework of *retrocausal algebra* reveals that this debate has an unexpected temporal dimension.

In any bi-Heyting algebra with a time-reversal operation, two different "excluded middle" laws exist:

- **Classical Excluded Middle**: P ∨ Pᶜ = ⊤ (using Heyting negation)  
- **Temporal Excluded Middle**: P ∨ ￢P = ⊤ (using co-Heyting negation)

The stunning result: **the temporal excluded middle always holds**, even when the classical excluded middle fails. In other words, from the perspective of backward-in-time reasoning, every proposition *is* decidable — you can always retrodict whether something did or didn't happen. But from the forward perspective, the same proposition might be genuinely undecidable.

This isn't a technicality. It means that the constructivist critique of excluded middle is, in a precise algebraic sense, about *forward-time* reasoning. Backward-time reasoning is always classical, even when forward-time reasoning is intuitionistic.

## The CPT Duality

The deepest result connects this logical structure to the CPT theorem — one of the most profound results in quantum field theory.

The CPT theorem says that if you simultaneously reverse charge (C), parity (P), and time (T), the laws of physics are invariant. It's the most fundamental symmetry known. Every quantum field theory that obeys basic axioms must respect CPT symmetry.

The algebraic version of CPT duality is this: **time reversal maps Heyting negation to co-Heyting negation**. In symbols, if T is the time-reversal operator and aᶜ is the Heyting complement of a, then T(aᶜ) = ￢(T(a)), where ￢ denotes co-Heyting negation.

This single equation encodes a stunning correspondence. It says that the *type* of negation changes under time reversal. Forward-time negation becomes backward-time negation. The constructive content of a proposition — whether it's actually decidable — is not preserved by time reversal.

From this, an even deeper theorem follows. The law of excluded middle for a proposition in forward time — P ∨ Pᶜ = ⊤ — is logically equivalent to the law of non-contradiction for its time-reversed image — T(P) ∧ ￢T(P) = ⊥. In other words:

> **Every failure of excluded middle in forward time corresponds to a failure of non-contradiction in reversed time.**

If a proposition is undecidable (LEM fails), then its time-reversed image is *paraconsistent* — it can be both "true" and "false" simultaneously, in the co-Heyting sense.

## Why This Matters

This result connects three seemingly unrelated ideas:

1. **Intuitionistic logic** — the constructivist position that not every statement is decidable
2. **Paraconsistency** — the study of logics that tolerate contradiction
3. **Time reversal** — the fundamental symmetry of physical law

The connection is not metaphorical. It's a precise mathematical theorem, stated and proved in full formal rigor. The retrocausal algebra framework shows that these three ideas are manifestations of a single underlying structure: a bi-Heyting algebra with a time-reversal involution satisfying the CPT axiom.

## The Concrete Example

The simplest example that illustrates all of this is almost embarrassingly simple: the three-element chain {0, 1, 2}. Here 0 is "false" (⊥), 2 is "true" (⊤), and 1 is a third truth value — "undetermined."

In this algebra:
- The Heyting complement of 1 is 0 (the strongest consequence of 1 being false is... false)
- The co-Heyting negation of 1 is 2 (the weakest thing implying 1's falsity is... true)
- LEM fails: 1 ∨ 0 = 1 ≠ 2 = ⊤
- Temporal excluded middle holds: 1 ∨ 2 = 2 = ⊤

Time reversal maps 0 ↔ 2 and fixes 1. Under this map, the Heyting complement of 1 (which is 0) gets sent to 2 — which is exactly the co-Heyting negation of T(1) = 1. The CPT negation duality holds perfectly.

And the CPT-LEM duality: LEM fails for element 1 (1 ∨ 0 = 1 ≠ ⊤), and correspondingly, T(1) ∧ ￢T(1) = 1 ∧ 2 = 1 ≠ 0 = ⊥. The "non-contradiction" fails for T(1), exactly as the theorem predicts.

## Looking Forward (and Backward)

The retrocausal algebra framework opens several intriguing directions. One is the question of *regularity*: which propositions are "well-behaved" under double negation? The CPT regularity theorem shows that a proposition is Heyting-regular (P = Pᶜᶜ) if and only if its time-reversal is co-Heyting regular (T(P) = ￢￢T(P)). The regular elements form a kind of "classical core" that is invariant under time reversal.

Another direction involves Kripke frames — the possible-worlds semantics of intuitionistic logic. A retrocausal Kripke frame has both forward and backward accessibility relations, connected by a world-reversal map. The mathematical structure of these frames constrains what kinds of retrocausal reasoning are coherent.

Perhaps the most intriguing question is whether the algebraic CPT duality has physical content beyond analogy. If the logical structure of quantum mechanics is genuinely bi-Heyting — as some interpretations of quantum logic suggest — then the CPT negation duality would give a purely logical explanation of why CPT symmetry holds. The symmetry wouldn't be a contingent fact about the laws of physics. It would be a theorem about the logic that any time-reversible physical theory must obey.

The arrow of time, it seems, doesn't just point one way. And when we follow it backward, we find that logic itself transforms — not randomly, but according to precise algebraic laws that connect the deepest questions in mathematics, logic, and physics.

---

*The mathematical framework described here draws on the theory of bi-Heyting algebras and their connections to intuitionistic and paraconsistent logic. The key results — including the CPT negation duality theorem and the CPT-LEM duality theorem — were stated and proved in full formal rigor.*
