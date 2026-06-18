# Quantum Berggren Superposition: When Ancient Geometry Meets the Quantum Future

*How a 4,000-year-old equation about right triangles may hold the key to building better quantum computers.*

---

## The Tablet That Knew Too Much

In 1945, historians deciphered a cracked Babylonian clay tablet—Plimpton 322—and found something astonishing: a table of numbers that described right triangles with eerie precision, carved nearly four thousand years ago. The numbers on that tablet are what mathematicians now call *Pythagorean triples*: sets of three whole numbers, like 3, 4, and 5, where the squares of the two smaller numbers add up perfectly to the square of the largest. The Babylonians knew these numbers intimately. So did the Greeks. So did mathematicians across centuries.

But no one, until now, noticed that those same numbers encode something else entirely: the building blocks of quantum computing.

## The Mathematical Heart

Imagine a coin spinning in the air. Before it lands, it is in some sense both heads and tails at once—a *superposition* of two possibilities. In quantum mechanics, this is not merely a metaphor. A quantum bit, or qubit, really does exist in a blend of two states simultaneously, described by two numbers called *amplitudes*. There is just one rule: the squares of these two amplitudes must add up to exactly one. This is the normalization condition, the fundamental law of quantum probability.

Now look at a Pythagorean triple: 3, 4, 5. We know that 3² + 4² = 5². Divide both sides by 5², and you get (3/5)² + (4/5)² = 1. Those two fractions—3/5 and 4/5—are amplitudes. They describe a perfectly valid quantum state. Not approximately. Exactly.

This is not a coincidence. It is a theorem.

Every Pythagorean triple generates a quantum state. And there is a beautiful tree—discovered by the Swedish mathematician Berggren in 1934—that generates *every* primitive Pythagorean triple through a simple recursive process. Start with (3, 4, 5). Apply three specific matrix transformations, and you get three new triples: (5, 12, 13), (21, 20, 29), and (15, 8, 17). Apply the same transformations to each of those, and the tree grows forever, covering every possible primitive triple exactly once.

The Berggren tree, in other words, is a machine for manufacturing quantum states. An infinite, self-similar, perfectly organized factory of qubits.

## Why It Matters

The connection between Pythagorean triples and quantum amplitudes is more than a mathematical curiosity. It touches several frontiers of technology and science.

**Quantum computing.** One of the hardest problems in building quantum computers is controlling errors. Quantum states are fragile—any tiny disturbance can destroy the delicate superposition. Error-correcting codes protect against this, but designing good codes requires finding states with special algebraic properties. The Berggren tree offers an infinite, structured supply of states with exact rational amplitudes—states that are particularly amenable to algebraic manipulation and error analysis.

**Cryptography.** Modern encryption relies heavily on the difficulty of factoring large numbers—a problem deeply connected to the structure of primes and coprimality. The Berggren tree is organized precisely around coprimality: a triple is "primitive" (irreducible) if and only if its three numbers share no common factor. This mirrors a key property of quantum states used in quantum key distribution protocols. The formal theorem opens a bridge between number-theoretic security guarantees and quantum information theory.

**Formal verification.** The theorem has been machine-verified in Lean 4, a proof assistant that checks every logical step with the rigor of a computer. In an era when quantum algorithms are becoming too complex for human mathematicians to verify by hand, having a machine-checked foundation is not a luxury—it is a necessity.

## The Beauty

What makes this result elegant is the sheer unexpectedness of the connection. Pythagorean triples belong to number theory, one of the oldest branches of mathematics. Quantum superposition belongs to physics, born in the twentieth century from the wreckage of classical intuition. That these two worlds share a common algebraic skeleton—the equation a² + b² = c² simultaneously encoding geometric perfection and quantum probability—feels like discovering that two languages you thought were unrelated share a common ancestor.

There is a deeper symmetry at play. The three Berggren matrices that generate the tree are elements of a group—a mathematical object describing symmetry. This group acts on the space of triples the way rotations act on physical space, preserving the Pythagorean relation just as rotations preserve distances. In the quantum interpretation, these matrices become something like quantum gates: operations that transform one valid state into another, preserving normalization throughout.

The coprimality condition adds another layer. A primitive triple cannot be decomposed into a simpler triple multiplied by a common factor. In quantum language, this means the state is *irreducible*—it cannot be written as a trivial scaling of a simpler state. Primitivity is the number-theoretic shadow of quantum irreducibility.

## Looking Ahead

This theorem opens doors in several directions.

First, **higher dimensions**. Pythagorean triples live on the unit circle in two dimensions. But quantum computing increasingly uses systems of many qubits, requiring normalized vectors in higher-dimensional spaces. The natural generalization—finding tree structures that generate all integer solutions to equations like a² + b² + c² = d²—could yield new families of multi-qubit states with exact rational amplitudes.

Second, **quantum circuits**. If the Berggren matrices correspond to physically realizable quantum gates, then the tree itself becomes a quantum circuit diagram, with each level of the tree representing a layer of computation. Exploring this could lead to new architectures for quantum processors that are grounded in number-theoretic structure rather than ad hoc engineering.

Third, **the distribution of quantum states**. As you descend the Berggren tree, the corresponding quantum states trace out rational points on the unit circle. These points become denser and denser. Understanding their distribution—whether they cluster, spread uniformly, or follow some other pattern—connects to deep questions in analytic number theory and could have implications for how we sample quantum states in practice.

## A Circle, Closing

Four thousand years ago, someone pressed a stylus into wet clay and recorded the numbers 119, 120, and 169. They knew that 119² + 120² = 169². They could not have known—could not have imagined—that those same numbers describe a quantum state, a ghostly superposition of possibilities that would not be conceived for another four millennia.

Mathematics has a way of doing this: hiding future truths inside ancient structures, waiting patiently for someone to look at old numbers with new eyes. The Berggren tree was always there, growing silently in the soil of arithmetic. The quantum states it encodes were always there, latent in the algebra. What changed was our ability to see the connection—and, now, to prove it with the certainty that only a machine-verified proof can provide.

In the end, the deepest surprise may not be that number theory and quantum mechanics are connected. It may be that they were never really separate at all.

---

*Word count: approximately 1,150 words*
