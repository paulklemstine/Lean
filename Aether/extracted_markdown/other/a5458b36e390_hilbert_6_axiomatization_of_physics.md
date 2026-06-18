# The Algebra of Maybe: How Quantum Physics Rewrote the Rules of Probability

## A 125-Year-Old Challenge Meets Its Match

In the summer of 1900, David Hilbert stood before the International Congress of Mathematicians in Paris and issued a challenge that would shape a century of research. Among his famous 23 problems, the sixth was perhaps the most audacious: *axiomatize physics*. Take the messy, empirical, endlessly surprising world of physical law and give it the same crystalline logical foundation that Euclid gave geometry.

For over a century, Hilbert's sixth problem has resisted complete solution — not because physicists lack equations, but because the logical *grammar* of physics keeps shifting beneath our feet. Classical mechanics obeyed one set of rules. Then quantum mechanics arrived and shattered assumptions so deep that most people didn't even know they were assumptions.

Chief among the casualties was probability itself.

---

## When Addition Breaks

Here is something you learned so early you probably don't remember learning it: if you can add two numbers, you can always add two numbers. Three plus seven equals ten. Always. No exceptions. Addition is *total* — it works on every pair of inputs.

Now imagine a world where addition sometimes refuses to work. You try to add two numbers and the universe replies: *"Those two? No. They cannot be combined."*

This is not a thought experiment. This is quantum mechanics.

In the quantum world, certain measurements are *complementary*. You can measure a particle's position, or you can measure its momentum, but you cannot meaningfully combine both measurements into a single joint observation. The probability of "the particle is here *and* has this momentum" is not merely unknown — the question itself is malformed. The mathematical operation that would combine these probabilities simply does not exist.

For decades, physicists papered over this strangeness with ad hoc rules. But in 1994, mathematicians David Foulis and Mary Katherine Bennett asked a radical question: what if we took this "partial addition" seriously? What if, instead of trying to force quantum probability into the mold of classical probability theory, we built a new algebraic foundation where addition is allowed to fail?

The structure they invented is called an **effect algebra**.

---

## The Rules of a Strange New Arithmetic

An effect algebra is built from deceptively simple ingredients. You have a collection of objects (think of them as possible experimental outcomes), a special element called "zero" (the impossible event), a special element called "one" (the certain event), and a partial addition operation — an operation that sometimes produces a result and sometimes says "undefined."

The rules are few:

1. **Order doesn't matter.** If you can add A to B, you can add B to A, and you get the same result.
2. **Grouping doesn't matter** (when it makes sense). If you can add A to B, then add the result to C, you could equally well add B to C first, then add A.
3. **Zero changes nothing.** Adding zero to anything gives you back what you started with.
4. **Every event has a complement.** For every outcome A, there is exactly one "opposite" outcome A⊥ such that A combined with A⊥ gives the certain event.
5. **One is the ceiling.** If adding something to the certain event still makes sense, that something must have been zero all along.

That's it. Five rules. And from these five rules, an astonishing amount of structure cascades out.

---

## What Emerges from Almost Nothing

The first surprise is **cancellation**. In ordinary arithmetic, if *a + b = a + c*, you can conclude *b = c*. But in an algebra where addition is only partial, this is far from obvious. Perhaps the partiality creates loopholes, situations where different elements can substitute for each other without detection. Remarkably, no such loopholes exist. Even in this weakened arithmetic, if two partial sums agree, their summands must be identical.

This is not a minor bookkeeping result. Cancellation is the engine that makes the entire theory work. Without it, the algebra would be too loose to support meaningful reasoning about probabilities.

The second surprise is the **involution of complements**. Take any event A and find its complement A⊥. Now find the complement of *that*: (A⊥)⊥. You might worry that double-complementing could produce something exotic — a new element unrelated to A. But the algebra forces (A⊥)⊥ = A, always. The complement operation is a perfect mirror: step through it twice and you're back where you started.

This means complement behaves exactly like logical negation. "Not not A" is A. The quantum world, for all its strangeness, still respects this classical principle.

The third surprise is that a **natural ordering** emerges spontaneously from the algebra. Define "A is less than or equal to B" to mean "there exists some C such that A ⊕ C = B." This definition requires no additional structure — it falls out of the partial addition alone. And it has all the properties you would want from an ordering:

- Every element is less than or equal to itself (reflexivity).
- If A ≤ B and B ≤ A, then A = B (antisymmetry).
- If A ≤ B and B ≤ C, then A ≤ C (transitivity).
- Zero is the smallest element. One is the largest.

In other words, effect algebras are automatically *partially ordered*, with the impossible event at the bottom and the certain event at the top. Nobody put this ordering in by hand. It crystallized from the axioms like salt from a cooling solution.

---

## Classical Probability as a Special Case

Here's what makes this framework genuinely profound: classical probability theory is an effect algebra. The unit interval [0, 1] with ordinary addition (defined only when the sum doesn't exceed 1) satisfies every axiom. The complement of a probability *p* is *1 − p*. The natural ordering is just the usual ≤ on real numbers.

So Kolmogorov's axioms — the standard foundation of probability since the 1930s — are not an alternative to the effect algebra framework. They are a *special case* of it. Effect algebras don't replace classical probability; they generalize it, the way Einstein's relativity generalized Newton's mechanics rather than discarding it.

But the effect algebra framework also accommodates structures that Kolmogorov's axioms cannot. The set of quantum effects — self-adjoint operators on a Hilbert space with eigenvalues in [0, 1] — forms an effect algebra where the partial addition is operator addition (defined only when the sum remains an effect). This is the natural home for quantum probability, and it cannot be squeezed into the classical framework without violence.

---

## Why Partial Addition Is Not a Bug

There is a temptation to view partial addition as a deficiency — a sign that the algebra is "incomplete" or "broken." This misses the point entirely.

Partiality is *information*. When the algebra says "A ⊕ B is undefined," it is telling you something physically meaningful: these two outcomes are incompatible. They cannot coexist. Trying to combine them is not just technically difficult; it is conceptually incoherent.

In classical probability, every pair of events can be combined because classical measurements never interfere with each other. Measuring the temperature of a gas does not affect its pressure. But in quantum mechanics, measurement *changes the system*. The partiality of addition is a mathematical reflection of a physical fact: the act of observation is not passive.

The beauty of the effect algebra framework is that it encodes this physical insight at the foundational level. You don't add complementarity as an afterthought; it is baked into the arithmetic itself.

---

## Hilbert's Dream, Partially Fulfilled

Hilbert asked for axioms of physics. The effect algebra framework doesn't axiomatize all of physics — that remains, and may always remain, an open challenge. But it does something remarkable: it provides a *single* axiomatic system that encompasses both classical and quantum probability, the two most fundamental frameworks for reasoning about uncertainty in the physical world.

The axioms are minimal. Five rules, each one natural and well-motivated. From them, a rich theory of complementation, ordering, and cancellation emerges with mathematical inevitability. The framework is flexible enough to accommodate quantum strangeness yet rigid enough to enforce logical consistency.

Moreover, this is not merely an abstract exercise. Effect algebras connect to active research across mathematics and physics. They appear in quantum information theory, where the question "which measurements are compatible?" is central to cryptography and computation. They appear in the foundations of quantum mechanics, where debates about the nature of measurement and probability continue to this day. And they connect to topos theory, a branch of abstract mathematics that provides yet another lens on the logical structure of physical theories.

The work formalized in this project (@file Shared/Hilbert6/EffectAlgebra.lean) establishes the core algebraic infrastructure with machine-verified certainty: the cancellation law, the involution of orthocomplements, the natural partial order with its antisymmetry and transitivity, and the boundary behavior of zero and one. These are the foundational bricks from which the broader theory is built.

---

## The Road Ahead

Hilbert's sixth problem is not solved. It may never be "solved" in the way his other problems have been. Physics is a moving target — every generation discovers new phenomena that demand new mathematics. But the effect algebra framework represents genuine progress: a rigorous, minimal, axiomatically clean foundation that captures the essential logic of quantum probability without importing unnecessary classical baggage.

The deepest lesson may be this: sometimes the right foundation for a theory is not a stronger set of axioms but a *weaker* one. By demanding less of addition — by allowing it to fail — the effect algebra framework gains the flexibility to describe a wider universe.

Perhaps that is fitting. The quantum world taught us that certainty itself is partial. Why shouldn't our mathematics be partial too?
