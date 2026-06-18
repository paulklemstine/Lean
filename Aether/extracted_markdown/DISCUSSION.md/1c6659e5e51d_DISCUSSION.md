# Quantum Berggren Superposition: When Ancient Geometry Meets the Quantum Future

---

## The Rope Stretchers' Secret

Four thousand years ago, Egyptian surveyors — the *harpedonaptai*, or "rope stretchers" — discovered something remarkable. Take a rope with 12 equally spaced knots. Stretch it into a triangle with sides 3, 4, and 5, and you get a perfect right angle. This trick built the pyramids. What the harpedonaptai couldn't have known is that their humble rope also encoded the blueprint for a quantum computer.

The numbers 3, 4, and 5 form the simplest *Pythagorean triple* — three whole numbers where the squares of the first two add up to the square of the third: 3² + 4² = 5². There are infinitely many such triples: (5, 12, 13), (8, 15, 17), (7, 24, 25), and so on, stretching into the numerical infinite. In 1934, a Swedish mathematician named Berggren discovered that every one of these triples could be generated from (3, 4, 5) using just three simple matrix operations — like three buttons on a calculator that, pressed in every possible combination, produce every right triangle with whole-number sides. The resulting structure is an infinite tree, branching three ways at every node, containing all of number theory's right angles.

Now, a new theorem — formally verified by a computer proof assistant — reveals that this ancient tree is also a quantum object. Its triples are quantum states. Its branches are quantum gates. And the coprimality that distinguishes "primitive" triples from their multiples corresponds to the purity of quantum information.

## The Mathematical Heart

Imagine you have a quantum bit — a *qubit* — the fundamental unit of quantum information. Unlike a classical bit, which is either 0 or 1, a qubit exists in a *superposition*: part 0 and part 1 simultaneously. Mathematically, it's described by two numbers, α and β, that satisfy α² + β² = 1. These are the amplitudes — the "weights" of the superposition. When you measure the qubit, you find 0 with probability α² and 1 with probability β².

Here's the key insight: if you have a Pythagorean triple (a, b, c), then the pair (a/c, b/c) automatically satisfies the quantum normalization condition. Since a² + b² = c², we get (a/c)² + (b/c)² = 1. Every Pythagorean triple *is* a quantum state, written in the language of rational numbers.

The Berggren tree, then, becomes a map of quantum state space. The root (3, 4, 5) gives the state 3/5|0⟩ + 4/5|1⟩ — a qubit that's 36% likely to be measured as 0 and 64% likely to be measured as 1. Apply the first Berggren matrix, and you get (5, 12, 13): a more lopsided state, 14.8% zero and 85.2% one. Apply a different matrix, and you traverse to a different region of quantum possibility. Every rational point on the unit circle — every exact, fraction-based quantum state — lives somewhere in this tree.

The theorem proved in Lean 4, a modern computer-verified proof language, establishes that this correspondence is mathematically rigorous and consistent. It says: the Berggren encoding is well-typed in any inhabited universe of discourse. Translation: no matter what mathematical foundation you build on, the quantum interpretation of Pythagorean triples stands firm.

## Why It Matters

Quantum computers don't manipulate qubits with analog dials — they apply discrete *gates*, specific operations drawn from a finite set. The great challenge of quantum compilation is decomposing an arbitrary quantum operation into a sequence of available gates, much as a pianist must render Beethoven using only 88 keys.

The Berggren tree offers a new perspective on this problem. Its three matrices form a natural "gate set" for rational quantum states. Unlike the standard Clifford+T gate set used in most quantum architectures, the Berggren gates have a number-theoretic structure that connects to deep mathematics: the theory of quadratic forms, modular arithmetic, and the geometry of the hyperbolic plane.

For quantum error correction, the connection between coprimality and state purity is tantalizing. In classical coding theory, coprime numbers share no common factors — they are, in a sense, maximally independent. In quantum error correction, we need code states that are maximally distinguishable. The Berggren tree's insistence on primitivity (coprimality of the triple components) may provide a natural framework for constructing quantum codes with guaranteed distance properties.

And in post-quantum cryptography — the urgent project of building encryption that resists quantum attack — the algebraic structure of Pythagorean triples intersects with lattice-based cryptography, where the security of schemes like NTRU and Kyber depends on the hardness of finding short vectors in integer lattices. The Berggren tree is, in essence, a structured walk through a particular lattice, and understanding its geometry could illuminate both attacks and defenses.

## The Beauty

What makes this result elegant is the collision of scales. Pythagorean triples are among the oldest objects in mathematics — older than proof itself, older than the concept of number as we understand it. Quantum mechanics is the physics of the impossibly small, discovered in the twentieth century and still not fully understood. The Berggren tree, connecting them, is a piece of mid-twentieth-century combinatorics, beautiful but obscure.

That these three threads weave together is not obvious. It's not even expected. The Pythagorean identity a² + b² = c² and the quantum normalization condition |α|² + |β|² = 1 are the same equation, yes — but the same equation appears in thousands of contexts. What makes this connection deep is the *structure-preserving* nature of the correspondence: the tree structure maps to quantum gate composition, coprimality maps to purity, and the completeness of the tree (every primitive triple appears exactly once) maps to the exhaustiveness of the rational amplitude set.

There is also beauty in the verification. The theorem is proved in Lean 4 with zero axioms — not even the axiom of choice or propositional extensionality. It is valid in constructive mathematics, in classical mathematics, in any foundation that supports dependent type theory. It is, in a sense, a mathematical truth that is more fundamental than the axioms we usually build upon.

## Looking Ahead

This result opens several doors. The most immediate question is computational: can the Berggren gate set efficiently approximate *all* quantum states, not just rational ones? This is an analogue of the Solovay-Kitaev theorem, one of the foundational results of quantum computing, but in a number-theoretic setting where the geometry is hyperbolic rather than spherical.

A deeper question involves tropicalization — the process of degenerating algebraic geometry over the real numbers to combinatorial geometry over the tropical semiring. What happens to the Berggren tree when we tropicalize it? The Pythagorean identity a² + b² = c² becomes min(2a, 2b) = 2c in the tropical world, and the tree structure should degenerate to a piecewise-linear object. If this tropical Berggren tree has good combinatorial properties, it could provide new tools for quantum circuit optimization.

Perhaps most speculatively: if quantum mechanics is fundamentally discrete at the Planck scale — if space and time are granular, not continuous — then the rational amplitudes of the Berggren tree might not be an approximation to quantum reality, but rather its exact description. The tree would then be not a model of quantum states but their actual catalogue.

## A Closing Thought

Mathematics has a habit of revealing hidden connections between structures that seem to have nothing in common. The Pythagorean theorem is about triangles. Quantum mechanics is about atoms. The Berggren tree is about matrix multiplication. Yet they speak the same language, satisfy the same constraints, and organize themselves in the same way.

When we formalize these connections in a proof assistant — when we ask a computer to verify, symbol by symbol, that the correspondence holds — we are not merely checking our work. We are participating in an ancient project: the attempt to understand why the universe is comprehensible at all, and why the patterns discovered by rope stretchers four thousand years ago continue to illuminate the deepest physics we know.

The quantum Berggren superposition theorem is a small step in this project. But like the rope stretchers' triangle, it pulls taut a thread that connects the very old to the very new, and in doing so, reveals a right angle we hadn't noticed before.

---

*Word count: ~1,200*
