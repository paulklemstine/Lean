# Quantum Berggren Superposition: When Ancient Geometry Meets the Quantum Future

*How a 4,000-year-old equation about triangles might hold the key to building better quantum computers*

---

## The Hook

Imagine you are an ancient Babylonian scribe, pressing wedge-shaped marks into a clay tablet. You are recording something remarkable: a list of numbers — 3, 4, 5; then 5, 12, 13; then 8, 15, 17 — each triple satisfying a beautiful relationship. The square of the largest equals the sum of squares of the other two. These are Pythagorean triples, and your tablet (which archaeologists will one day call Plimpton 322) is one of the oldest mathematical documents in human history.

Now fast-forward four millennia. In a laboratory cooled to temperatures colder than outer space, a quantum computer manipulates individual atoms, encoding information not as definite zeros and ones, but as ghostly superpositions — states that are simultaneously both and neither. The physicist programming this machine faces a peculiar challenge: she needs to specify exact amplitudes for her quantum states, and those amplitudes must satisfy a normalization condition that looks suspiciously familiar.

It is the Pythagorean theorem.

This is not a coincidence. A new result, formalized and verified by computer in the Lean theorem prover, reveals that the ancient family of Pythagorean triples and the modern theory of quantum superposition are, in a precise mathematical sense, the same thing.

## The Mathematical Heart

Think of a quantum bit — a qubit — as an arrow pointing somewhere on the surface of a sphere. Unlike a classical bit, which can only point straight up (representing 1) or straight down (representing 0), a qubit can point anywhere. The direction of the arrow determines the probabilities of measuring 0 or 1. But there is a constraint: the probabilities must add up to exactly 1. Geometrically, this means the arrow must have exactly unit length. It must touch the surface of the sphere.

Now picture a right triangle. Its sides satisfy the Pythagorean theorem: the square of the hypotenuse equals the sum of squares of the other two sides. If you divide each side by the hypotenuse, you get two numbers whose squares sum to 1 — exactly the normalization condition for a qubit.

Every Pythagorean triple, in other words, is a quantum state in disguise.

But where do all the Pythagorean triples come from? In 1934, the Swedish mathematician Berggren discovered something astonishing: every primitive Pythagorean triple — one where the three numbers share no common factor — can be generated from the single "seed" triple (3, 4, 5) by repeatedly applying just three matrix transformations. The result is an infinite ternary tree, with (3, 4, 5) at the root and every primitive triple appearing exactly once as a node.

In quantum language, each of Berggren's three matrices acts like a quantum gate — a fundamental operation that transforms one valid quantum state into another. The tree itself becomes a quantum circuit architecture: start with a single qubit state and apply sequences of three basic gates to reach any desired target state with rational amplitudes.

The coprimality condition — the requirement that the three numbers share no common factor — takes on quantum significance too. A primitive triple corresponds to an irreducible quantum state, one that cannot be expressed as a scaled-down version of something simpler. It is, in a sense, a quantum state that carries maximum information.

## Why It Matters

The practical implications ripple across quantum computing, cryptography, and fundamental physics.

**Quantum circuit synthesis.** One of the central challenges in building quantum computers is compiling abstract quantum operations into sequences of physical gates. Current approaches use the Solovay–Kitaev theorem, which guarantees that any quantum gate can be approximated by a sequence of gates from a finite set — but the approximation introduces errors. Pythagorean triples offer an alternative: quantum states with *exact* rational amplitudes, no approximation needed. The Berggren tree provides a systematic catalog of all such states, organized in a computationally natural tree structure.

**Cryptographic applications.** The arithmetic properties of Pythagorean triples — particularly their connection to the Gaussian integers and algebraic number theory — suggest new approaches to lattice-based cryptography. The tree structure of the Berggren family might encode hardness assumptions useful for post-quantum cryptographic schemes.

**Foundational physics.** The correspondence hints at something deeper: that the mathematical structure of quantum mechanics may be more intimately connected to number theory than previously appreciated. If quantum amplitudes naturally "want" to be ratios of sides of right triangles, this could constrain the space of possible physical theories in unexpected ways.

## The Beauty

What makes this result beautiful is its unexpectedness. Number theory and quantum mechanics developed independently, separated by millennia and motivated by completely different questions. The Babylonians cared about surveying land and constructing buildings. Quantum physicists care about the behavior of subatomic particles. Yet the same equation — $a^2 + b^2 = c^2$ — lies at the heart of both.

There is also an aesthetic pleasure in the economy of the correspondence. Three matrices. One seed triple. An infinite tree. Every rational point on the unit circle. Every qubit state with exact rational amplitudes. The entire construction is generated by the simplest possible means — a ternary branching from a single root — yet it produces the richest possible output: a dense subset of all quantum states.

The formal verification in Lean adds another layer. Mathematics has always aspired to certainty, but human proofs are fallible. By encoding the result in a formal language checked by computer, we achieve a level of confidence that no informal argument can match. The theorem is not merely believed to be true — it is *verified* to be true, down to the last logical step.

## Looking Ahead

This result opens doors in several directions.

First, can the correspondence be extended to higher dimensions? Pythagorean quadruples — four numbers satisfying $a^2 + b^2 + c^2 = d^2$ — might encode two-qubit quantum states. The higher-dimensional Berggren trees (which exist, though they are less well-studied) could provide exact gate sets for multi-qubit systems.

Second, what about the dynamics? The Berggren tree has a natural notion of "time" — depth in the tree — and the three matrices define a discrete dynamical system on the space of Pythagorean triples. Does this dynamics have a quantum mechanical interpretation? Could it describe the evolution of a quantum system?

Third, and most speculatively: the Berggren tree is intimately connected to the modular group $\mathrm{PSL}(2, \mathbb{Z})$, which also appears in conformal field theory, string theory, and the theory of modular forms. These connections suggest that the quantum–Pythagorean correspondence might be a shadow of a much larger structure — one that connects quantum computation to the deepest currents in modern mathematics and theoretical physics.

The next century of mathematics may well be shaped by discoveries at the intersection of computation, number theory, and quantum physics. The quantum Berggren superposition — a theorem linking 4,000-year-old arithmetic to 21st-century technology — is a signpost pointing the way.

## A Closing Thought

There is a philosophical puzzle at the heart of mathematics: why does abstract reasoning about numbers and shapes turn out to describe the physical world? Eugene Wigner famously called this "the unreasonable effectiveness of mathematics." The quantum Berggren superposition adds a new chapter to this mystery. An equation discovered by ancient civilizations for the purpose of measuring fields and building pyramids turns out to encode the rules governing the smallest constituents of matter.

Perhaps the real lesson is humility. We do not invent mathematics; we discover it. And sometimes, what we discover is that ideas separated by four thousand years of history were, all along, reflections of the same deep truth — a truth written not in any human language, but in the universal language of mathematical structure itself.

---

*The theorem `berggren_quantum_state` was formally verified in Lean 4 using the Mathlib library, ensuring machine-checked certainty of the result.*
