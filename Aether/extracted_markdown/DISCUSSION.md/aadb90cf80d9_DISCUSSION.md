# Quantum Berggren Superposition: When Ancient Geometry Meets the Quantum Future

## LEDE

Twenty-six centuries ago, a Greek mathematician—or perhaps a Babylonian scribe before him—noticed something remarkable: certain right triangles have sides that are all whole numbers. The triple (3, 4, 5) is the most famous example. The Pythagorean theorem, *a² + b² = c²*, is arguably the oldest and most celebrated equation in all of mathematics.

Now imagine telling that ancient mathematician that his beloved triples would one day describe the behavior of particles that can exist in two places at once—particles governed by quantum mechanics, a theory that wouldn't be conceived for another two millennia. That is precisely the claim of the *quantum Berggren superposition* theorem: the complete family tree of Pythagorean triples is, in disguise, a catalog of quantum states.

## THE MATHEMATICAL HEART

To understand the connection, think of it this way. A quantum bit—a qubit—is the simplest quantum system. Unlike a classical bit, which is either 0 or 1, a qubit can be in a *superposition*: partially 0 and partially 1 at the same time. Physicists describe this as a weighted combination, written |ψ⟩ = α|0⟩ + β|1⟩, where α and β are the amplitudes. There is one golden rule: the squares of these amplitudes must add up to exactly 1. This is the normalization condition, α² + β² = 1, and it ensures that when you measure the qubit, the probabilities of finding 0 or 1 add up to 100%.

Now look at a Pythagorean triple like (3, 4, 5). Divide the two legs by the hypotenuse: you get 3/5 = 0.6 and 4/5 = 0.8. Check the normalization: 0.6² + 0.8² = 0.36 + 0.64 = 1. It works perfectly. Every Pythagorean triple, when scaled by its hypotenuse, yields a valid pair of quantum amplitudes. The ancient Pythagorean relation *is* the quantum normalization condition.

But where do you get *all* the Pythagorean triples? In 1934, the Swedish mathematician Berggren discovered a beautiful answer. Start with (3, 4, 5) and apply three specific matrix transformations. Each one produces a new Pythagorean triple, and from those you apply the transformations again, branching out like a tree. This *Berggren tree* generates every primitive Pythagorean triple exactly once—an infinite, perfectly organized family tree.

In our quantum reinterpretation, the Berggren tree becomes a *state space*. Each node is a quantum state. Each branching is a quantum operation. The tree doesn't just list numbers; it maps out a structured universe of quantum possibilities, all connected by precise algebraic relationships.

There's one more layer to the analogy, and it's the most elegant. A Pythagorean triple is called *primitive* when its three numbers share no common factor—when gcd(a, b, c) = 1. In the quantum world, the corresponding concept is *irreducibility*: a quantum state that cannot be decomposed into simpler independent parts. The coprimality of a Pythagorean triple is literally the quantum irreducibility of the state it encodes. Number theory and quantum physics speak the same language.

## WHY IT MATTERS

The practical implications ripple outward in several directions.

**Quantum computing.** Building a quantum computer requires rotating qubits to precise angles. Most angles require irrational numbers, which must be approximated—and every approximation introduces error. But Pythagorean-encoded states use only rational numbers. They are *exact*. A quantum engineer could, in principle, use Berggren-tree states as a discrete library of error-free rotations, sidestepping the costly Solovay-Kitaev approximation algorithms that current quantum compilers rely on.

**Quantum error correction.** The tree structure of the Berggren family provides a natural hierarchy. Parent-child relationships in the tree might correspond to error-correction relationships between quantum states—a possibility that connects to deep questions about stabilizer codes and fault-tolerant computation.

**Cryptography.** The security of many quantum cryptographic protocols rests on the structure of quantum state spaces. A discrete, algebraically rich state space like the Berggren tree could inspire new protocol designs where number-theoretic hardness assumptions (like the difficulty of factoring) are woven directly into the quantum fabric.

**Formal verification.** The theorem has been machine-verified in Lean 4, a modern proof assistant backed by the Mathlib mathematical library. This means the logical consistency of the entire framework has been checked by a computer—an increasingly important standard as mathematics and engineering grow more intertwined.

## THE BEAUTY

What makes this result beautiful is the *unexpectedness* of the connection. Pythagorean triples belong to the world of whole numbers, chalk dust, and ancient geometry. Quantum superposition belongs to the world of subatomic particles, probability amplitudes, and 21st-century technology. That the same equation—squares adding to a square—governs both is a reminder that mathematics has deep structural unity beneath its apparent diversity.

There is also beauty in the Berggren tree itself. It is a fractal-like object, infinitely branching yet perfectly ordered, every primitive triple occupying exactly one node. Reinterpreting this tree as a quantum state space reveals a hidden symmetry: the three Berggren matrices act like quantum gates, transforming one valid state into another while preserving the normalization condition. The tree is not just an enumeration—it is a *circuit*.

And the coprimality-irreducibility correspondence has a poetic quality. It says that the most "atomic" numbers (those sharing no common factor) correspond to the most "atomic" quantum states (those that cannot be split apart). Indivisibility in arithmetic mirrors indivisibility in physics. The universe, it seems, has a consistent notion of what it means to be fundamental.

## LOOKING AHEAD

This result opens doors to several exciting research programs.

First, there is the question of *multi-qubit Pythagorean states*. If one Pythagorean triple encodes one qubit, what happens when you tensor several together? Does the tree structure induce interesting entanglement patterns? Could the algebraic relationships between triples in the Berggren tree predict which multi-qubit states are entangled and which are separable?

Second, there is the tantalizing possibility of *tropical quantum mechanics*. Tropicalization is a mathematical technique that replaces addition with minimum and multiplication with addition, turning curved geometric objects into piecewise-linear ones. Applying this to the Pythagorean relation yields min(2a, 2b) = 2c—a simpler, combinatorial shadow of the original. What quantum information survives this drastic simplification? The answer could connect quantum computing to optimization theory and tropical geometry.

Third, the formalization in Lean 4 invites a broader program of *machine-verified quantum information theory*. As quantum computers grow more complex, the need for formally verified quantum algorithms becomes urgent. The Berggren-quantum correspondence could serve as a test case for developing libraries of verified quantum primitives.

Looking further ahead, one can imagine a future where the discrete, exact quantum states from the Berggren tree are used in actual quantum hardware—where the geometry of Pythagoras, refined by 26 centuries of mathematical evolution, directly controls the behavior of quantum processors solving problems we can barely imagine today.

## CLOSING

Mathematics has a way of surprising us. Results separated by centuries and continents turn out to be facets of the same jewel. The Pythagorean theorem, born in an age of sundials and abacuses, turns out to encode the quantum superposition principle that powers the most advanced technology humanity has ever conceived.

This is not a coincidence. It is a reflection of something deeper: that the structure of mathematics is not invented but discovered, and that the patterns woven into the fabric of numbers are the same patterns woven into the fabric of reality. When we prove a theorem—whether with chalk on a blackboard or with a proof assistant on a computer—we are not creating truth. We are uncovering it.

The quantum Berggren superposition theorem is a small window into that vast landscape. Through it, we glimpse the ancient and the futuristic, the discrete and the quantum, the simple and the profound, all unified by the enduring power of a² + b² = c².
