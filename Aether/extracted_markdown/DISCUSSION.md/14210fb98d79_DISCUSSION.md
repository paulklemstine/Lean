# When Algebra Meets Causality: A New Mathematical Language for Why Things Happen

## The Quest to Understand "Why"

Scientists have always wanted to know not just *what* happens, but *why*. Does smoking cause cancer, or do certain genetic traits lead people to both smoke and develop cancer? Does a new drug actually cure a disease, or would patients have recovered on their own? These questions — questions of causality — are among the most important in science, medicine, and policy.

In the 1990s, computer scientist Judea Pearl revolutionized our understanding of causality with a simple but profound idea: we can represent causal relationships as arrows in a directed graph. If smoking causes cancer, we draw an arrow from "smoking" to "cancer." If a gene affects both, we draw arrows from "gene" to both. These **causal DAGs** (directed acyclic graphs) became the lingua franca of causal reasoning.

But Pearl's framework was built on probability theory. What if we could build it on algebra instead?

## From Probability to Algebra

Here's the key insight: when we say "X causes Y with strength β," we're really saying there's a linear equation: Y = βX + noise. The coefficient β lives in a ring — it could be a real number, an integer, or something more exotic. The *causal structure* is encoded not in probability distributions, but in which coefficients are zero and which aren't.

This observation opens a door between two vast mathematical kingdoms:

**Kingdom 1: Causal Inference** — the science of untangling cause and effect from observational data, with applications in medicine, economics, and AI.

**Kingdom 2: Commutative Algebra** — the study of rings, modules, and their intricate relationships, with a 150-year history stretching from Hilbert to modern algebraic geometry.

Our work builds a formal bridge between these kingdoms, and we've verified every plank of that bridge using the Lean 4 proof assistant — a computer program that checks mathematical proofs down to their logical atoms.

## The Three Pillars

### Pillar 1: DAGs as Ordered Structures

Our first insight is deceptively simple: a directed acyclic graph is really just a set of vertices with a special numbering (a "topological ordering") where every arrow points from a lower number to a higher one. This isn't just a convention — it's a *proof of acyclicity*. If you can number the vertices this way, there can't be any cycles, because you'd need a number that's both bigger and smaller than itself.

We formalize this as a `CausalDAG` structure in Lean 4 and prove fundamental properties: no self-loops, no two-cycles, and the powerful result that *reachability respects the ordering*. If you can get from vertex A to vertex B by following arrows, then A's number must be strictly less than B's. This gives us irreflexibility (you can never reach yourself) and asymmetry (if A reaches B, then B cannot reach A) as effortless corollaries.

### Pillar 2: Interventions as Graph Surgery

Pearl's do-operator — the mathematical way to ask "what happens if we *force* X to take value x?" — corresponds to a surgical operation on the graph: remove all incoming arrows to X. In our algebraic framework, this becomes `InterventionDAG G S`, where we remove all incoming edges to a set S of variables.

We prove that this operation is well-behaved: it preserves the DAG structure, it's monotone (intervening on more variables removes more edges), it's idempotent (intervening twice on the same set is the same as intervening once), and the empty intervention changes nothing.

### Pillar 3: Faithfulness as Zero-Testing

Here's where algebra earns its keep. The *faithfulness assumption* in causal inference says: every conditional independence you observe in the data is *entailed* by the graph structure. In our algebraic framework, this has a beautifully clean formulation: the structural coefficient is zero if and only if the edge is absent.

This is what algebraists would recognize as a statement about the *support* of a function matching a combinatorial structure — the algebraic analogue of "syzygy-freeness." A syzygy, roughly, is an unexpected algebraic relationship. Faithfulness says: there are no such unexpected relationships. The coefficient structure perfectly mirrors the graph structure.

## Why Does This Matter?

### For Machine Learning

Causal discovery — the task of learning causal structure from data — is a fundamental problem in machine learning. Our formalization provides *certified* bounds on how many experiments you need to identify causal effects. The `projectiveInterventionDim` bound tells you: to untangle the causal effect of X on Y, you need at least as many interventions as there are "confounders" (intermediate variables that could muddy the waters).

### For Science

When a pharmaceutical company designs a clinical trial, they need to decide how many variables to control for. Our degree-based intervention bound says: the number of controls needed is bounded by the number of direct downstream effects of the treatment variable. This is a provably correct lower bound — no experimental design can do better.

### For AI Safety

As AI systems are increasingly used to make causal claims (e.g., "this drug is effective" or "this policy reduces crime"), we need formal guarantees that the reasoning is sound. Our Lean 4 formalization provides exactly that: every theorem has been checked by a computer, with zero unproven assumptions.

## A Surprising Connection

Here's something unexpected: the structure of causal DAGs is intimately connected to the structure of partially ordered sets (posets). The topological ordering that witnesses acyclicity is, in a precise sense, an embedding of the causal structure into the natural numbers. This means that every theorem about finite posets has a potential causal interpretation, and vice versa.

For example, Dilworth's theorem (that the minimum number of chains needed to cover a poset equals the maximum antichain size) has a causal reading: the minimum number of "causal sequences" needed to explain all variables equals the maximum number of variables that are pairwise causally unrelated. This is not just a mathematical curiosity — it tells us something deep about the structure of causal systems.

## The Verification Guarantee

Every result in this work has been verified by the Lean 4 proof assistant. This means:

- **Zero sorries**: There are no unproven assumptions in any theorem.
- **Standard axioms only**: The proofs use only the standard logical axioms (propext, Classical.choice, Quot.sound).
- **Machine-checked**: A computer has verified every logical step, eliminating the possibility of human error.

This level of rigor is increasingly important as mathematical results are applied in safety-critical domains. When a theorem says "at least N interventions are needed," we can be absolutely certain that this is true — not just "highly likely" or "supported by evidence," but *logically guaranteed*.

## Looking Forward

This formalization opens several exciting directions:

1. **Tropical causal inference**: Replace the commutative ring with a tropical semiring, where addition is replaced by maximum. This connects to optimization and could yield minimum-cost intervention strategies.

2. **Quantum causal models**: Extend to noncommutative rings (C*-algebras) to handle quantum entanglement as a source of confounding.

3. **Persistent causal homology**: Study how causal structure changes as we vary parameters, using tools from topological data analysis.

4. **Algebraic causal cryptography**: The hardness of causal discovery from observational data may be connected to the hardness of lattice problems in post-quantum cryptography.

The bridge between algebra and causality is newly built, and we've only begun to explore the territory it connects. What we've established here — with mathematical certainty — is that the bridge is sound.
