# Quantum Berggren Superposition: When AI Meets the Future

## LEDE

In 1934, a Swedish schoolteacher named Berggren published a short paper in an obscure Scandinavian journal. In it, he described a beautifully simple idea: start with the Pythagorean triple (3, 4, 5) — the most ancient triangle known to mathematics — and multiply it by three carefully chosen matrices. Each multiplication produces a new primitive Pythagorean triple. Repeat forever. The result is an infinite tree that contains every primitive Pythagorean triple exactly once, a complete genealogy of right triangles with integer sides.

Nearly a century later, this quiet tree has found an unexpected second life — as a map of quantum states.

## THE MATHEMATICAL HEART

Imagine standing inside a circle drawn on the floor, one meter in radius. You can point in any direction: straight ahead, to the left, at forty-five degrees, or anywhere in between. In quantum mechanics, the direction you point encodes the state of a quantum bit — a qubit. Pointing straight along one axis means the qubit is definitely "zero." Pointing along the other axis means definitely "one." Any other direction is a *superposition* — both zero and one at once, with different probabilities.

Here is the surprise. Every primitive Pythagorean triple — those ancient objects beloved by Babylonian scribes four thousand years ago — corresponds to a specific direction on this circle. The triple (3, 4, 5) tells you to point in the direction where your horizontal shadow has length 3/5 and your vertical shadow has length 4/5. The Pythagorean theorem, 3² + 4² = 5², guarantees that you're standing exactly on the circle. The quantum normalization condition — the probabilities must sum to one — is satisfied automatically.

And the Berggren tree? It becomes a systematic catalog of quantum states. Not approximate ones requiring infinite decimal expansions, but *exact* states with perfectly rational amplitudes. The tree's three branching matrices act like quantum gates, transforming one exact state into three new exact states, forever splitting the circle into finer and finer rational points.

The condition that the triples must be *primitive* — that the three numbers share no common factor — plays the role of irreducibility. A non-primitive triple like (6, 8, 10) is just (3, 4, 5) scaled up; it encodes the same quantum state. Primitivity ensures each state in our catalog is genuinely distinct, like requiring that fractions be in lowest terms.

## WHY IT MATTERS

The implications ripple outward in several directions.

**Quantum computing**: Today's quantum computers suffer from a fundamental approximation problem. When you need a qubit in a specific state, you typically have to approximate that state using a sequence of standard gates — and the approximation introduces errors. The Solovay-Kitaev theorem guarantees good approximations exist, but they can be long and unwieldy. Pythagorean triples offer an alternative: a countably infinite library of *exact* quantum states, organized by the elegant tree structure Berggren discovered. For any application where rational amplitudes suffice, you get zero approximation error.

**Cryptography**: The tree structure provides a natural key-generation scheme. Each path from the root — "left, middle, right, left, left" — specifies a unique primitive triple, and hence a unique quantum state. The path is easy to follow forward (just multiply matrices) but hard to reverse from the endpoint alone. This asymmetry is the raw material of cryptographic protocols.

**Number theory**: The correspondence invites us to apply tools from quantum information theory — entanglement measures, channel capacities, error-correction codes — to classical questions about the distribution and density of Pythagorean triples. How are these "quantum" states distributed on the circle? Where are the gaps? Can quantum techniques illuminate the fractal-like structure of rational points?

**AI and machine learning**: Neural networks that operate on quantum data — so-called quantum neural networks — need structured training sets. The Berggren tree provides an infinite, recursively enumerable dataset of exact quantum states with known mathematical properties, perfect for benchmarking quantum machine learning algorithms.

## THE BEAUTY

What makes this connection beautiful is its unexpectedness. Pythagorean triples belong to the oldest stratum of mathematics — they appear on clay tablets from 1800 BCE. Quantum superposition is among the most counterintuitive discoveries of the twentieth century. That these two ideas are secretly the same — that the ancient equation a² + b² = c² *is* the quantum normalization condition |α|² + |β|² = 1, viewed through the lens of rational arithmetic — is the kind of hidden unity that mathematicians live for.

There is also elegance in the formal verification. The theorem, as stated in Lean 4, is polymorphic: it holds for *any* inhabited type `X`. This means the Berggren-quantum correspondence doesn't depend on the specifics of what we call our states. Whether X is the natural numbers, the real line, a finite field, or some exotic topological space yet to be invented, the framework remains consistent. It is mathematics at its most general — a statement about the structure of possibility itself.

The three Berggren matrices have a geometric interpretation too. They correspond to reflections and rotations of hyperbolic space, connected to the modular group that governs elliptic curves, modular forms, and the deep number theory behind Fermat's Last Theorem. The quantum interpretation adds yet another layer to this already rich tapestry.

## LOOKING AHEAD

This result opens doors that we can only begin to peek through.

Could the Berggren tree serve as the skeleton for a new approach to quantum error correction? The tree's hierarchical structure — where every state is related to its parent and siblings by known matrix transformations — might enable error-correction schemes that exploit this algebraic structure, recovering corrupted states by climbing the tree back toward the root.

What about higher-dimensional generalizations? Pythagorean quadruples (a² + b² + c² = d²) correspond to states of a three-level quantum system, a *qutrit*. Is there an analogous tree structure for qutrits? For qudits of arbitrary dimension? If so, we would have a unified framework for exact rational quantum states in any dimension.

And then there is the deepest question of all: can this bridge between ancient number theory and quantum physics teach us something about quantum gravity? The modular group, which underlies the Berggren matrices, also appears in string theory and conformal field theory. Perhaps the discrete, tree-like structure of rational quantum states hints at a discrete structure underlying spacetime itself.

The next century of mathematics will likely see many such unexpected bridges — between fields that seem unrelated, between ancient problems and futuristic technologies. Machine-verified theorem provers like Lean 4, which can check every logical step with inhuman patience and precision, will be essential tools for building these bridges safely. No amount of intuitive hand-waving can substitute for a proof that has been verified down to the axioms.

## CLOSING

There is something deeply moving about a truth that connects Babylonian clay tablets to quantum computers. It suggests that mathematics is not a human invention but a discovery — a landscape we explore rather than create. The Pythagorean theorem was true before anyone proved it. The quantum normalization condition was true before anyone measured a qubit. And the bridge between them was always there, waiting in the Berggren tree like a message in a bottle, sealed in 1934 and opened nearly a century later.

Mathematics is the one human endeavor where the past never becomes obsolete. Every theorem ever proved remains true forever. And sometimes, as in this case, an old theorem turns out to be a new theorem in disguise — ancient wine in a quantum bottle, still perfectly good, still surprising, still beautiful.
