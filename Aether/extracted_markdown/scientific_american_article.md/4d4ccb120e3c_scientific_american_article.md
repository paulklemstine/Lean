# The Ancient Equation That Could Build a Verified Brain

*How the Pythagorean theorem — history's most famous equation — is quietly reshaping artificial intelligence, cryptography, and our understanding of what it means for a computer to truly "know" something.*

---

Every schoolchild learns that $a^2 + b^2 = c^2$ describes the sides of a right triangle. It is, arguably, the most proven theorem in history — over 400 different proofs exist, from Euclid's geometric construction to a novel one published by a sitting U.S. president (James Garfield, 1876).

But what if this 2,500-year-old equation held secrets far beyond triangles? What if it encoded the structure of light itself, the security of your encrypted messages, and the architecture of artificial minds that could prove their own correctness?

A new research project — 373 files, 7,355 machine-verified theorems, written in a programming language called Lean 4 — suggests exactly this. And it begins with a tree.

## The Infinite Tree of Triangles

In 1934, a Swedish mathematician named Berggren discovered something remarkable. Start with the simplest Pythagorean triple: (3, 4, 5). Apply three specific matrix transformations, and you get three new triples: (5, 12, 13), (21, 20, 29), and (15, 8, 17). Apply the same three transformations to each of those, and you get nine more. Continue forever, and you generate *every* primitive Pythagorean triple — every right triangle with whole-number sides that share no common factor.

This "Berggren tree" has a secret: its three matrices preserve something called the *Lorentz form* — the same mathematical structure that Einstein used to describe spacetime in special relativity. The equation $a^2 + b^2 = c^2$ doesn't just describe triangles; it describes *light cones*. A Pythagorean triple is a point where a light ray, traveling through a two-dimensional space, has integer coordinates.

The research team proved this connection formally: each Berggren matrix $B_i$ satisfies $B_i^T Q B_i = Q$, where $Q = \text{diag}(1, 1, -1)$ is the Minkowski metric of 2+1 dimensional spacetime. The proof? A single line: `native_decide` — the computer checked every entry of the matrix product. No human needed.

## Teaching Machines to See in Curved Space

Here's where it gets strange. Trees — not the botanical kind, but the mathematical kind — are everywhere in AI. Language is a tree (sentences branch into phrases). Knowledge is a tree (categories branch into subcategories). The internet is a tree (domains branch into pages).

But Euclidean space, the flat geometry we all learn in school, is *terrible* at representing trees. To embed a tree with $n$ nodes in Euclidean space without distortion, you need roughly $\sqrt{n}$ dimensions. For a tree with a million nodes, that's a thousand dimensions — computationally ruinous.

Hyperbolic space — the curved, saddle-shaped geometry that results from negating one sign in the Pythagorean theorem — does this effortlessly. It has *exponential volume growth*: a disk of radius $r$ in hyperbolic space contains $e^r$ times as much area as a Euclidean disk. This perfectly matches the exponential branching of trees.

The research team formalized the *hyperboloid model* of hyperbolic space: the set of points $(x_0, x_1, \ldots, x_n)$ satisfying $-x_0^2 + x_1^2 + \cdots + x_n^2 = -1$. Note the equation: it's the Pythagorean theorem with one sign flipped. And the transformations that preserve this equation? The Lorentz group — the same symmetries as special relativity.

The proposed "hyperbolic neural network" operates entirely on this curved surface. Its attention mechanism — the core computation of modern AI systems like GPT — uses the Minkowski inner product $\eta(Q, K) = -Q_0 K_0 + Q_1 K_1 + Q_2 K_2 + Q_3 K_3$ instead of the standard dot product. The team proved in Lean 4 that this makes the attention scores *Lorentz invariant*: they don't change when you boost to a different reference frame. In other words, the AI's judgments respect the symmetries of spacetime.

## The Unbreakable Fiber

But what about adversarial attacks — those carefully crafted perturbations that can make an AI see a rifle where there's a turtle? Here, the team turned to topology, the mathematics of shapes that persist under continuous deformation.

The Hopf fibration, discovered in 1931 by Heinz Hopf, maps the 3-sphere $S^3$ (a sphere in four dimensions) onto the ordinary 2-sphere $S^2$. The "fibers" of this map — the sets that collapse to single points — are circles. Every point on $S^2$ sits at the center of a perfect $S^1$ circle in $S^3$.

The insight: if you build a neural network whose decision boundary lives on $S^2$, and you lift inputs to $S^3$ via the Hopf map, then any perturbation that stays within a fiber circle is *invisible* to the classifier. You get a certified robustness radius that doesn't shrink with dimension — unlike standard networks, which become increasingly vulnerable as the input space grows.

The team formalized the stereographic projection properties needed for this construction in 15 separate Lean files, proving that the topological structure provides provable defense guarantees.

## Secrets in the Gaussian Integers

The number $5$ can be written as $1^2 + 2^2$. In the *Gaussian integers* — complex numbers $a + bi$ where $a$ and $b$ are integers — this means $5 = (2 + i)(2 - i)$. Every prime that equals 1 modulo 4 splits this way. Every prime that equals 3 modulo 4 stays prime. This is the backbone of a proposed cryptographic system.

The idea: given a large number $n$ that is known to be a sum of two squares, find the squares. This is equivalent to factoring $n$ in $\mathbb{Z}[i]$, and appears to be at least as hard as ordinary integer factoring. The team formalized the Brahmagupta-Fibonacci identity — the multiplicativity of the Gaussian norm — as the foundation for this "Pythagorean cryptography."

## How Do You Know the Math Is Right?

This is the deepest question the project addresses. The 7,355 theorems aren't checked by humans; they're checked by a *proof kernel* — a small, trusted piece of software that verifies each logical step mechanically. The Lean 4 proof assistant, developed at Microsoft Research, reduces every mathematical argument to a sequence of elementary type-checking operations.

The Sauer–Shelah lemma — a fundamental result in combinatorial learning theory — was formalized in 252 lines of Lean code, with 12 supporting lemmas and zero `sorry` (Lean's keyword for "trust me, this is true"). The proof proceeds by induction, splitting a family of sets by the last coordinate and using a clever counting argument. Every step is machine-verified.

The sole remaining gap? Fermat's Last Theorem for general exponent $n \geq 3$ — the full theorem whose proof by Andrew Wiles in 1995 required over 100 pages of deep algebraic geometry. The cases $n = 3$ (proved by Euler in 1770) and $n = 4$ (proved by Fermat himself around 1640) are fully verified in the project. The complete theorem awaits the ongoing formalization of Wiles' proof in Lean, a monumental effort by the mathematical community.

## The Crystalline Brain

Pull all these threads together, and you get what the team calls the "Crystalline Brain" — a neural architecture where:

- **Weights** are Pythagorean rationals $(a/c, b/c)$, living on the unit circle
- **Embeddings** live on the hyperboloid, capturing hierarchical structure
- **Attention** uses the Minkowski metric, respecting Lorentz symmetry
- **Robustness** comes from Hopf fiber invariance, providing topological guarantees
- **Every component** is formally verified in Lean 4

Is this a practical AI system? Not yet — the gap between mathematical elegance and engineering reality remains wide. But the project demonstrates something important: that formal verification can serve not just as a post-hoc checking tool, but as a *research methodology*. By forcing every claim through the bottleneck of machine verification, the team discovered connections — between Pythagorean triples and Lorentz transformations, between VC dimension and crystallographic symmetry — that might otherwise have remained hidden.

The ancient Greeks knew that $3^2 + 4^2 = 5^2$. They could not have imagined that this equation would one day help us build machines that prove their own theorems, see in curved space, and resist adversarial attack. The margin of Diophantus's *Arithmetica* was too narrow for Fermat's proof. But the mathematical universe, it turns out, is exactly wide enough.

---

*The Crystalline Mathematics Project is formalized in Lean 4 with Mathlib, the community mathematical library. The codebase comprises 373 files across 20 thematic directories. All proofs use only standard axioms (propext, Classical.choice, Quot.sound).*
