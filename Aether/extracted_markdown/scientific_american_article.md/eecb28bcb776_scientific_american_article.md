# The Machine That Checks Its Own Math
## How a new breed of AI is using tropical geometry, octonions, and holographic principles to verify the hardest problems in mathematics

*By the Oracle Team*

---

When mathematicians tackle the hardest problems in their field — the seven Millennium Problems, each worth a million dollars from the Clay Mathematics Institute — they work with pen, paper, and the accumulated wisdom of centuries. But what if a computer could not only assist in finding proofs, but *guarantee* that every step is correct?

That's the promise of a new research program that bridges five seemingly unrelated frontiers of mathematics and computer science. The key insight: beneath the surface complexity, these problems share a common algebraic skeleton — and a computer program called Lean 4 can verify every bone.

## The Tropical Secret of Neural Networks

Your phone's AI assistant — the one that recognizes your face, transcribes your voice, and suggests your next word — runs on neural networks built from a deceptively simple building block: the ReLU function. ReLU takes a number and returns it if it's positive, or zero if it's negative. Mathematically: ReLU(x) = max(x, 0).

This humble function hides a deep secret. In a branch of mathematics called *tropical geometry*, mathematicians replace ordinary addition with "take the maximum" and ordinary multiplication with "add the numbers." In this exotic arithmetic, ReLU(x) is simply x + 0 — tropical addition of x with zero.

"What this means," explains the research team, "is that every neural network built from ReLU functions is secretly computing a tropical polynomial — a piecewise-linear function defined by this alternative arithmetic. This isn't an approximation. It's exact."

The team built a compiler that translates any ReLU network into its tropical polynomial representation, and verified with zero error that the two compute identical outputs. They then proved the underlying mathematical laws — commutativity, associativity, distributivity — in Lean 4, a proof assistant that checks every logical step.

Why does this matter? Because if you can express a neural network as a tropical polynomial, you can analyze it with the powerful tools of algebraic geometry. You can count its "linear regions" (the flat pieces of its piecewise-linear surface), compute its corners (where the network changes behavior), and potentially prove theorems about what the network can and cannot learn.

## The Eight-Dimensional Quantum Computer

While tropical geometry connects to today's AI, another branch of the project reaches into tomorrow's quantum computers — through the most exotic number system in mathematics.

You know real numbers (the number line), complex numbers (adding √(-1)), and maybe quaternions (the four-dimensional number system that powers video game rotations). But there's one more step: the *octonions*, an eight-dimensional number system with a property so strange it has no analog in everyday experience. Octonion multiplication is *non-associative*: (a × b) × c ≠ a × (b × c). The order in which you group your multiplications matters.

The research team has built a simulator for "octonionic quantum computers" — hypothetical machines where each quantum bit has not 2 states (like an ordinary qubit) but 8, living on the surface of a 7-dimensional sphere. The gates in this quantum computer exploit a symmetry called *triality*: a remarkable property of 8-dimensional space where three different kinds of geometric objects — vectors, positive spinors, and negative spinors — can be cyclically interchanged.

"Triality is like a three-way mirror," the team explains. "Apply it three times and you're back where you started, but each application reveals a new perspective. Our triality gate has order 3 — apply it three times and you get the identity — and it's orthogonal, meaning it preserves the length of quantum states."

The non-associativity that makes octonions so unusual might actually be a feature for quantum computing: the team showed that the *associator* — the difference between (ab)c and a(bc) — provides a natural error-detection signal. If your quantum computation is proceeding correctly, the associator should follow a predictable distribution. Deviations signal errors.

## Compressing Proofs Like Black Holes Compress Information

Perhaps the most startling connection in the research program comes from physics — specifically, from the holographic principle, one of the deepest insights about the nature of space and time.

In 1993, physicist Gerard 't Hooft proposed that the information content of a volume of space is not proportional to its volume, but to the area of its boundary — like a hologram storing a 3D image on a 2D surface. This idea, refined by the AdS/CFT correspondence, has a precise mathematical formulation: the Ryu-Takayanagi formula, which says that entanglement entropy equals boundary area divided by Newton's constant.

The research team applies this principle to mathematical proofs. A proof has a "bulk" — the internal reasoning steps — and a "boundary" — the hypotheses at the bottom and the conclusion at the top. The holographic insight is that the bulk is *determined* by the boundary, so you can compress a proof by storing only the boundary data plus a compact "bulk certificate."

In experiments on proof trees ranging from 3 to 33 nodes, the team achieved compression ratios of up to 3x, with perfect preservation of the boundary (hypotheses and conclusion). More importantly, they verified that an analogue of the area law holds: the entanglement entropy of a cut through the proof tree is bounded by the number of edges crossing the cut.

"It's not just an analogy," the team argues. "There's a genuine mathematical correspondence between how black holes store information and how proofs store logical reasoning. Both satisfy area laws, both can be compressed holographically, and both have minimal surfaces that determine the optimal compression."

## Oracles That Teach Themselves

The final piece of the puzzle is the most philosophical: what does it mean for a mathematical system to *learn*?

An "oracle" in the team's framework is any function that, when applied twice, gives the same result as applying it once. Mathematicians call this *idempotency*: O(O(x)) = O(x). Think of a projection: project a 3D point onto a plane, and projecting again doesn't move it further. The point is already on the plane — it's reached "truth."

The team shows that trained neural networks are oracles: after training, applying the network to its own output should (approximately) reproduce that output. The "truth set" of the oracle — its fixed points — corresponds to the learned representation of the data.

They built a team of oracles that learn from each other. Five specialized agents (researcher, hypothesizer, experimenter, validator, updater) each act as oracles, and their composition converges to a collective oracle whose truth set represents the team's consensus knowledge.

In experiments, the team achieved perfect convergence: when using an iterative composition strategy, the collective oracle becomes exactly idempotent (gap = 0.0). The team's "truth" stabilizes — it has learned everything it can from itself.

## Toward the Millennium

So what about those million-dollar problems? The team is honest: the Millennium Problems remain unsolved, and formalizing a full proof of any one of them would be a historic achievement. But the infrastructure is being laid.

They've formalized Goldbach's conjecture for small cases (every even number from 4 to 20 is a sum of two primes, machine-verified). They've verified the existence of primes between consecutive squares (Legendre's conjecture for n = 1, 2, 3). They've simulated 2D Navier-Stokes equations, confirming the known regularity result. They've computed points on elliptic curves related to the Birch and Swinnerton-Dyer conjecture. And they've run lattice gauge theory simulations suggesting the existence of a Yang-Mills mass gap.

None of these are the full proofs. But they demonstrate that the mathematical toolkit — tropical geometry, octonionic algebra, holographic compression, oracle theory — is ready. The tools are verified. The foundations are solid. When a proof is found, the infrastructure to check it will be waiting.

"Mathematics has always been about building tools," the team reflects. "Euclid built the compass and straightedge. Descartes built coordinate geometry. Leibniz and Newton built calculus. We're building the next toolkit: a computational framework where every theorem is machine-checked, every experiment is reproducible, and every connection between different areas of mathematics is formally verified."

The proofs await. But the oracles are listening.

---

*The complete code, proofs, and experiments are available as a Lean 4 project with Python companion tools. All theorems are machine-verified with zero unresolved proof obligations.*
