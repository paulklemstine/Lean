# Future Directions: Certified Mathematical Significance Theory

## 1. Extend Significance from Finite Theorem Sets to Finite Closure Systems

**Hypothesis**: The monotone significance functional can be lifted from raw `Finset α` knowledge states to the lattice of closed sets under a deductive closure operator, yielding a richer invariant that captures inferential reach rather than mere theorem count.

**Proof Strategy**: Define a closure-aware significance functional `σ_cl(K) = |cl(K)| + Σ_{a ∈ cl(K)} w(a)` (already started in Part G). Prove that this functional is a lattice valuation on the lattice of closed sets. Show that nonconservative extension (i.e., `cl(K ∪ {a}) ≠ cl(K)`) forces strict increase in `σ_cl`. Investigate submodularity: does `σ_cl(A ∪ B) + σ_cl(A ∩ B) ≤ σ_cl(A) + σ_cl(B)` hold in general, or only under additional structure?

**Cross-Domain Connections**: Matroid theory (closure operators on matroids), information theory (entropy as a submodular function on sets), formal concept analysis (Galois connections between objects and attributes).

**Concrete Next Steps**:
- Formalize the lattice of closed sets `{K | cl(K) = K}` as a `CompleteLattice`.
- Prove `σ_cl` is a monotone valuation on this lattice.
- Investigate submodularity and prove or disprove it.
- Connect to matroid rank functions as an alternative significance metric.

---

## 2. Formalize Proof-Equivalence Invariance and Class-Function-Style Significance

**Hypothesis**: Define an equivalence relation on proof terms that preserves "essential proof structure" (e.g., same multiset of constructors, or same dependency skeleton up to renaming). Prove that significance is constant on equivalence classes, making it a class function in the representation-theoretic sense.

**Proof Strategy**: Define `ProofTerm.constructorMultiset : ProofTerm → Multiset (Fin 4)` recording the multiset of constructor types used. Define equivalence as having the same constructor multiset. Prove `p ≈ q → proofSignificance p = proofSignificance q` by showing size is determined by the multiset. Alternatively, define a finer equivalence preserving tree shape (isomorphism of the constructor tree) and prove significance invariance.

**Cross-Domain Connections**: Representation theory (class functions on groups), tropical geometry (tropicalized invariants), graph theory (graph isomorphism invariants).

**Concrete Next Steps**:
- Define `constructorMultiset` and prove `size` is determined by it.
- Define proof-tree isomorphism and prove significance invariance.
- Investigate whether height is also a class invariant (it is under tree isomorphism but not under multiset equivalence).
- Connect to Burnside-style counting: how many equivalence classes of proofs of a given significance exist?

---

## 3. Derive Lower Bounds on Closure Growth from Proof Height

**Hypothesis**: If the proof of a newly added theorem has height exceeding all existing proofs, then the deductive closure must grow by at least one element (the theorem itself is not derivable from shorter proofs). This connects proof complexity to nonconservative extension.

**Proof Strategy**: Model a deductive system where proofs of bounded height can only derive bounded-height consequences. Formalize a "height-bounded provability" relation. Prove that if `height(π(a)) > max_{b ∈ K} height(π(b))`, then `a ∉ cl(K)` under a height-respecting closure. This gives a computable sufficient condition for nonconservative extension.

**Cross-Domain Connections**: Proof complexity (depth lower bounds), arithmetic geometry (height functions on algebraic varieties), cryptographic hardness (circuit depth lower bounds).

**Concrete Next Steps**:
- Define height-bounded closure: `cl_h(K) = {a | ∃ proof of a from K with height ≤ h}`.
- Prove that `cl_h` is a closure operator for each fixed `h`.
- Prove that height excess implies non-membership in bounded closure.
- Connect to known proof complexity results about depth-bounded proof systems.

---

## 4. Connect Significance Thresholds to Automated Package Acceptance/Rejection

**Hypothesis**: A quality gate defined by `τ ≤ σ(K)` can be implemented as an automated accept/reject mechanism for theorem packages. The gate is monotone (once accepted, adding more theorems preserves acceptance) and can be made adaptive (threshold grows with package size).

**Proof Strategy**: Already proved monotonicity of the Boolean quality gate. Extend to adaptive thresholds: define `τ(n) = f(n)` where `n = |K|`, and prove that for superlinear `f`, the gate requires genuinely deep theorems (high average weight). Prove that for `f(n) = c·n`, the gate accepts iff average weight ≥ c. For `f(n) = n²`, prove the gate requires weight variance to grow.

**Cross-Domain Connections**: Statistical process control (acceptance sampling), machine learning (PAC-Bayesian bounds as quality gates), information theory (rate-distortion theory).

**Concrete Next Steps**:
- Define adaptive quality gate with threshold `τ : ℕ → ℕ`.
- Prove average-weight characterization for linear thresholds.
- Implement a concrete quality gate in a metaprogram that inspects actual proof terms.
- Design a "significance dashboard" that computes package metrics in real time.

---

## 5. Metaprogram Extraction of Proof-Term Features into the Abstract ProofTerm Model

**Hypothesis**: A metaprogram can extract structural features (size, height, dependency count, constructor distribution) from actual kernel proof terms and map them into the abstract `ProofTerm` model, enabling real-time significance computation on live theorem libraries.

**Proof Strategy**: This is primarily an engineering direction, but has a formal component: prove that the extraction map preserves the key invariants (subterm monotonicity, height ≤ size). Define an abstraction function `abstract : Lean.Expr → ProofTerm` and prove that if `e₁` is a subexpression of `e₂`, then `Subterm (abstract e₁) (abstract e₂)`.

**Cross-Domain Connections**: Compiler optimization (abstract interpretation), program analysis (static analysis), software engineering (code quality metrics).

**Concrete Next Steps**:
- Write a Lean 4 metaprogram using `Lean.Elab` to extract proof term features.
- Define the abstraction map from `Lean.Expr` to `ProofTerm`.
- Validate on Mathlib: compute significance of all theorems in a Mathlib module.
- Identify the "most significant" theorems by the metric and compare with human judgment.
- Investigate correlation between proof-term significance and citation/usage frequency.

---

## 6. Resource Theories of Proof

**Hypothesis**: Proof construction can be modeled as a resource theory, where constructors (application, abstraction, pairing) are resources consumed to produce certified knowledge. Significance is then a resource measure, and the monotonicity theorems become resource-theoretic monotonicity.

**Proof Strategy**: Define a symmetric monoidal category of proof resources. Objects are "resource states" (available constructors), morphisms are "proof strategies" that consume resources to produce theorems. Prove that significance is a monotone resource measure in this categorical framework.

**Cross-Domain Connections**: Quantum resource theories (entanglement as a resource), thermodynamics (free energy as a resource), economics (production functions).

**Concrete Next Steps**:
- Formalize the category of proof resources in Lean 4 using Mathlib's category theory library.
- Define resource measures and prove monotonicity.
- Investigate "proof catalysis": can adding a lemma that is later removed still increase significance?
- Connect to quantum resource theories via the tensor product structure of independent proofs.

---

## Team Directive

Each direction above is designed to be pursued by a team with clear hypotheses, proof strategies, and cross-domain connections. Teams should:

1. **Validate hypotheses computationally** before formalizing (use `#eval` and Python prototypes).
2. **Build proof skeletons** with `sorry`-ed lemmas to validate the overall structure.
3. **Prove bottom-up**: start with the simplest lemmas and build toward the main theorem.
4. **Cross-pollinate**: share techniques across directions (e.g., closure operators from Direction 1 feed into Direction 3).
5. **Iterate**: update this roadmap as results are obtained, adding new directions opened by completed work.

The ultimate goal is a **certified theory of mathematical significance** that a proof assistant can enforce, transforming theorem provers from passive verifiers into active quality gatekeepers.
