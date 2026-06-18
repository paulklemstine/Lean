# Quantum Berggren Superposition: When Ancient Geometry Meets the Quantum Future

---

In 1800 BCE, a Babylonian scribe pressed a stylus into wet clay and recorded a table of numbers: 3, 4, 5. Then 5, 12, 13. Then 8, 15, 17. The tablet—now known as Plimpton 322—is one of humanity's oldest mathematical artifacts, a catalog of right triangles whose sides form whole numbers. Nearly four millennia later, these same numbers have reappeared in an entirely unexpected place: the foundations of quantum computing.

## THE MATHEMATICAL HEART

Imagine a spinning coin frozen mid-air. In quantum mechanics, this coin doesn't have to be heads *or* tails—it can be both at once, in a *superposition*. Physicists describe this by two numbers, call them α and β, that measure "how much heads" and "how much tails" the coin is. There's one iron rule: α² + β² must equal exactly 1. The state lives on a circle.

Now here's the surprise. Every Pythagorean triple—every set of whole numbers (a, b, c) where a² + b² = c²—gives you exactly such a quantum state. Just divide: α = a/c, β = b/c. The Pythagorean equation *is* the quantum normalization condition. The ancient geometry of right triangles secretly encodes the algebra of quantum superposition.

But the story gets richer. In 1934, the Swedish mathematician B. Berggren discovered that *every* primitive Pythagorean triple (one where the numbers share no common factor) can be generated from a single root—(3, 4, 5)—by repeatedly applying just three simple matrix operations, called B₁, B₂, and B₃. These matrices produce an infinite ternary tree, with (3, 4, 5) at the root and every primitive triple appearing exactly once as a node.

In the quantum interpretation, these three Berggren matrices become *quantum gates*—the basic operations of a quantum computer. Applying B₁ to the state encoded by (3, 4, 5) produces the state encoded by (5, 12, 13). Apply B₂ instead and you get (21, 20, 29). The entire Berggren tree becomes a quantum circuit diagram, each path from root to leaf representing a specific sequence of gate operations.

And the coprimality condition—the requirement that the triple's numbers share no common factor—takes on a new meaning. In quantum mechanics, a state that cannot be decomposed into simpler parts is called *irreducible*. A primitive triple, where gcd(a, b) = 1, corresponds to an irreducible quantum state. A non-primitive triple like (6, 8, 10) = 2 × (3, 4, 5) is *reducible*—it factors through a common divisor, much like a composite quantum system that separates into independent parts.

## WHY IT MATTERS

This connection is not merely poetic. It opens doors in at least three directions.

**Exact quantum computing.** Standard quantum gates operate over the complex numbers, which means real hardware must approximate ideal operations. The Berggren gates, by contrast, are *integer* matrices. They produce exact transformations with no rounding error. This could inspire new architectures for quantum processors where certain computations are performed with perfect arithmetic precision.

**Quantum error correction.** The coprimality constraint that defines primitive triples is essentially a parity check—a condition that detects when something has gone wrong. Error-correcting codes in quantum computing work on similar principles, using algebraic constraints to detect and fix bit flips. The Berggren tree's built-in coprimality structure might provide a natural framework for designing new error-correcting codes, potentially ones rooted in number theory rather than the usual linear algebra.

**Algorithmic number theory.** Quantum computers already excel at problems with hidden algebraic structure—Shor's algorithm for factoring is the famous example. The Berggren tree's group-theoretic structure (the matrices generate an infinite group of integer transformations) is precisely the kind of hidden symmetry that quantum algorithms exploit. Could there be a "quantum Berggren algorithm" that traverses the tree exponentially faster than classical methods?

## THE BEAUTY

What makes this result beautiful is its economy. The Pythagorean theorem is arguably the most fundamental equation in all of mathematics. Quantum superposition is arguably the most fundamental principle in all of physics. The Berggren tree connects them through nothing more than three 3×3 integer matrices—objects so concrete you could compute with them on the back of an envelope.

There is a deep aesthetic satisfaction in finding that structures separated by four millennia and entirely different intellectual traditions—Babylonian geometry and twentieth-century quantum mechanics—are secretly the same object viewed from different angles. The Pythagorean triple (3, 4, 5) is simultaneously a right triangle, a rational point on the unit circle, and a quantum state. The Berggren matrices are simultaneously number-theoretic generators, geometric symmetries, and quantum gates.

The formal verification adds another layer. The theorem has been machine-checked in Lean 4, a proof assistant that reduces mathematical arguments to their logical atoms. Every step—from the definition of the Berggren matrices to their invertibility to the well-typedness of the quantum construction—has been verified by computer. In an age when mathematical proofs grow ever more complex and human error ever more likely, this kind of machine-certified certainty is increasingly valuable.

## LOOKING AHEAD

The Berggren-quantum bridge is a doorway, not a destination. Several tantalizing questions remain open.

First: *universality*. In quantum computing, a set of gates is "universal" if any quantum operation can be approximated by composing them. The Solovay-Kitaev theorem guarantees this for certain gate sets over the complex numbers. Are the Berggren gates universal in any analogous sense? They generate an infinite discrete group, but does this group's closure in the appropriate topology cover all of quantum state space?

Second: *entanglement*. The current framework treats single qubits—states on the circle S¹. But quantum computing's real power comes from *entangled* multi-qubit states. Can the Berggren tree be extended to higher-dimensional Pythagorean equations (a² + b² + c² = d², and beyond) to encode multi-qubit entanglement? The higher-dimensional analogs of Pythagorean triples are well-studied in number theory, and they might yield multi-qubit Berggren trees.

Third: *tropical limits*. In recent years, mathematicians have developed "tropical geometry," where you replace addition with maximum and multiplication with addition—a kind of algebraic degeneration that turns curved shapes into straight-line diagrams. The Berggren matrices can be tropicalized, and the resulting tropical transformations might describe what happens when a quantum system is *measured*—the moment superposition collapses to a definite outcome. This would give a rigorous mathematical model of quantum measurement rooted in combinatorics rather than wave-function collapse.

## CLOSING

Mathematics has a way of revealing that things we thought were different are actually the same. The integers and the rationals. Geometry and algebra. Waves and particles.

Now, it seems, ancient triangles and quantum states.

The Babylonian scribe who cataloged Pythagorean triples on Plimpton 322 could not have imagined quantum computers. And the physicists who formalized quantum mechanics in the 1920s did not have Pythagorean triples in mind. Yet the same equation—a² + b² = c²—governs both. The same matrices—Berggren's three generators—serve as both number-theoretic tools and quantum gates. The same condition—coprimality—means both "primitive" and "irreducible."

Perhaps this is what Eugene Wigner meant by the "unreasonable effectiveness of mathematics." Or perhaps it is something deeper: a hint that the physical world and the world of numbers are not merely analogous, but genuinely, structurally, the same. We are only beginning to learn how to read the correspondence. The Berggren tree, rooted in the simplest of all right triangles, may be pointing toward a mathematics we have not yet imagined.

---

*The theorem `berggren_quantum_state` has been formally verified in Lean 4 with the Mathlib library. The Berggren matrix infrastructure, including invertibility proofs, is available in the companion formalization.*
