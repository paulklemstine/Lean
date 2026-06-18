# Future Directions

## Synthesis

The confluence result for the tensor distributivity fragment opens a systematic pathway from ad hoc symbolic simplification to certified algebraic computation. The polynomial termination measure and critical pair analysis provide a template that can be extended to richer algebraic theories, connected to category-theoretic coherence, and applied to compiler optimization, quantum circuit rewriting, and algebraic statistics. The five directions below form a coherent research program: Direction 1 extends the algebraic fragment, Direction 2 connects to proof theory and coherence, Direction 3 applies to practical compiler optimization, Direction 4 bridges to quantum computing, and Direction 5 opens connections to algebraic statistics. Together, they chart a path from a single confluence result to a comprehensive theory of certified symbolic tensor computation.

---

## Direction 1: Full Semiring Coherence for Typed Tensor Algebra

**Conjecture**: The 9-rule distributivity fragment can be extended to a complete, confluent modulo AC rewrite system for the full equational theory of typed semiring-like tensor expressions, including commutativity of scalar multiplication, matrix transposition, and bilinearity of the dot product.

**The key insight is** that the polynomial interpretation technique generalizes: by carefully choosing the weight of each new constructor (transposition, trace, tensor product), one can maintain strict descent under an extended rule set. The "+1 overhead on additive nodes" pattern is a universal design principle for distributivity termination measures.

**Why now?** The formal verification infrastructure (Lean 4 with Mathlib) is mature enough to handle the case analysis required for the extended system. Previous attempts at full semiring coherence required manual proofs of hundreds of cases; modern proof automation makes this tractable.

**Test**: Extend the 9 rules with (1) commutativity of scalMul, (2) bilinearity of dot (right distribution over smulVec), (3) matrix transposition distribution. Check whether the polynomial interpretation can be extended, or whether a new measure is needed.

**Impact**: A complete confluent system for typed tensor algebra would be immediately applicable as a certified simplification backend for tensor compilers (TensorFlow, PyTorch, JAX).

**Catalog References**: `Catalog/Pythagorean/TensorConfluence.lean` (distPotential, Rewrite1), `Catalog/Pythagorean/TensorSortedRewrite.lean` (TensorRewrite, normStep).

**Proof Strategy**: Extend `distPotential` to new constructors, verify descent for new rules, enumerate critical pairs of the extended system, prove joinability.

**Domain Bridges**: Compiler optimization (tensor IR simplification), category theory (coherence for rig categories).

**Lineage**: Direct extension of the 9-rule confluence result.

**Ambition**: Grand challenge — would provide the first complete certified canonicalization for typed tensor algebra.

---

## Direction 2: Coherence Theorems via Rewriting for Monoidal-Distributive Categories

**Conjecture**: The confluence result is a concrete instance of a general coherence theorem for monoidal-distributive categories (rig categories), and there exists a systematic translation between confluence of oriented rewrite systems and coherence of categorical diagrams.

**The key insight is** that our 9 rules orient the distributivity axioms of a rig (ring without negation), and confluence modulo AC is precisely the statement that "all diagrams commute" in the free rig category on three generating objects. This connects term rewriting to categorical algebra in a precise, formally verifiable way.

**Why now?** Recent work on formalization of category theory in proof assistants (Mathlib's category theory library) makes it possible to state and prove the categorical coherence theorem alongside the rewriting result, establishing the formal connection.

**Test**: (1) Define a free rig category in Lean 4. (2) Show that morphisms correspond to rewrite sequences. (3) Prove that the coherence theorem for the category is equivalent to confluence of the rewrite system.

**Impact**: Would unify two major branches of algebra (rewriting theory and categorical coherence) through formal verification, providing a computational proof of coherence for rig categories.

**Catalog References**: `Catalog/Pythagorean/TensorConfluence.lean` (ACEq, unique_normal_form_mod_AC).

**Proof Strategy**: Define a functor from the free rig category to the term algebra, show it reflects and preserves the relevant structure.

**Domain Bridges**: Category theory (coherence), type theory (categorical semantics of linear types), proof theory (cut elimination as confluence).

**Lineage**: Extends the confluence result to a categorical setting.

**Ambition**: Grand challenge — would establish a new bridge between rewriting theory and categorical algebra.

---

## Direction 3: Equality Saturation with Certified Extraction

**Conjecture**: The confluence result can be used to certify the extraction phase of equality saturation (e-graph) based tensor optimizers: if the e-graph represents all distributivity-equivalent forms, then any extraction produces a term whose normal form is the unique canonical representative.

**The key insight is** that confluence modulo AC provides a *post-hoc verification* mechanism for e-graph extraction. Rather than proving the extraction algorithm correct, one normalizes the extracted term and checks AC-equivalence with the canonical form. This decouples the complex optimization logic from the simple verification step.

**Why now?** Equality saturation tools (egg, egglog) are increasingly used in tensor compiler optimization. The missing piece is certified extraction — guaranteeing that the optimized code is semantically equivalent to the original. Our confluence result provides exactly this guarantee for the distributivity fragment.

**Test**: Implement an e-graph representation for tensor expressions, saturate with the 9 distributivity rules, extract a "smallest" term, and verify that its normal form is AC-equivalent to the normal form of the input.

**Impact**: Would enable formally verified tensor compiler optimization using equality saturation, a technology used by major deep learning frameworks.

**Catalog References**: `Catalog/Pythagorean/TensorConfluence.lean` (normalizeCanon, Rewrite1), `Catalog/Pythagorean/EqualitySaturationExtraction.lean`.

**Proof Strategy**: Show that the e-graph congruence closure is contained in the rewrite equivalence, then use confluence to certify extraction.

**Domain Bridges**: Compiler optimization (e-graphs, equality saturation), program verification (translation validation).

**Lineage**: Applies the confluence result to a practical optimization technique.

**Ambition**: Solid extension — directly builds on existing technology with clear practical impact.

---

## Direction 4: Quantum Circuit Rewriting with Distributive Gates

**Conjecture**: The tensor distributivity fragment, when specialized to 2×2 matrices, captures a significant fragment of quantum circuit optimization rules (distribution of controlled gates over superposition), and confluence modulo AC extends to a canonical form theorem for this fragment.

**The key insight is** that quantum circuits can be viewed as tensor expressions where matrices are unitary gates, vectors are quantum states, and scalar multiplication is global phase. The distributivity rules correspond to circuit identities like distributing a controlled gate over a superposition of basis states.

**Why now?** Quantum circuit optimization is a critical bottleneck in quantum computing. Existing optimizers use heuristic rule sets without formal confluence guarantees. Our framework provides a template for proving that quantum simplification rules produce canonical circuits.

**Test**: (1) Instantiate the tensor expression language with 2×2 complex matrices. (2) Identify which of the 9 rules correspond to valid quantum circuit identities. (3) Check whether additional quantum-specific rules (e.g., unitarity, self-adjointness) maintain confluence.

**Impact**: Would provide the first formally verified canonical simplification for a fragment of quantum circuit algebra.

**Catalog References**: `Catalog/Pythagorean/TensorConfluence.lean` (Rewrite1, distPotential), `Catalog/Pythagorean/BerggrenQuantumBridge.lean`.

**Proof Strategy**: Specialize the tensor framework to quantum circuits, extend the polynomial interpretation to handle unitarity constraints.

**Domain Bridges**: Quantum computing (circuit optimization), physics (quantum information theory).

**Lineage**: Specializes the general tensor result to the quantum domain.

**Ambition**: Solid extension with high impact potential in quantum computing.

---

## Direction 5: Algebraic Statistics via Tensor Normal Forms

**Conjecture**: The canonical tensor normal forms, when interpreted over polynomial rings, correspond to canonical representations of statistical models (exponential families), and confluence provides a normal form theorem for sufficient statistic computation.

**The key insight is** that sufficient statistics in exponential family models are computed by tensor contractions, and the distributivity rules correspond to algebraic simplifications of sufficient statistic formulas. A canonical normal form for these expressions would provide a decision procedure for testing whether two parameterizations of an exponential family are equivalent.

**Why now?** Algebraic statistics is a growing field connecting computational algebra with statistical inference. The tensor framework provides a natural bridge: tensor expressions represent multilinear statistics, and distributivity captures the algebraic structure of sufficiency.

**Test**: (1) Encode a parametric exponential family as a tensor expression. (2) Normalize the sufficient statistic formula. (3) Check whether two families with AC-equivalent normal forms are statistically equivalent.

**Impact**: Would connect rewriting theory to statistical model comparison, potentially automating a key step in Bayesian model selection.

**Catalog References**: `Catalog/Pythagorean/TensorConfluence.lean` (normalizeCanon, ACEq).

**Proof Strategy**: Define an interpretation of tensor expressions as polynomial functions, show that rewriting preserves the statistical model.

**Domain Bridges**: Statistics (exponential families, sufficient statistics), algebraic geometry (toric varieties).

**Lineage**: Novel cross-domain application of the confluence framework.

**Ambition**: Grand challenge — would open a new connection between rewriting theory and statistics.
