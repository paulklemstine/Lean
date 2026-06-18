# Future Directions: Renormalization of Theorem Space

## Synthesis

This research cycle established the mathematical foundations for studying universality classes of formal proof structures via renormalization group flow. Three main pillars were erected: (1) **strict depth flows** with quantitative convergence bounds, (2) **flow morphisms** preserving universality under coarse-graining, and (3) the **Merging Principle** proving that coarse-graining can only merge universality classes. These build directly on the Catalog's `ClosureFlow` framework (`Bridges/RenormalizationUniversality.lean`) by adding depth-graded convergence and categorical morphism theory.

The most promising cross-domain connections lie at the intersection of computation and algebra. The strict depth flow framework is simultaneously a theorem about discrete dynamical systems (connecting to `Computation/InfoEfficientAlgorithms.lean`'s termination analysis), a statement about lattice-theoretic fixed points (connecting to `Bridges/QuantumTropicalCore.lean`'s `closure_has_least_fixed_point`), and a model for renormalization in physics (connecting to `Bridges/HolographicProofRenormalization.lean`). The flow morphism composition theorem shows these connections are functorial, not merely analogical.

The highest breakthrough potential lies in Direction 1 (Empirical Spectral Taxonomy), because it would transform the theoretical framework into a testable science, and in Direction 3 (Categorical Universality), because it would connect proof renormalization to the deep categorical structures already present in Mathlib. Direction 2 (Spectral Rigidity) is the most falsifiable and would be the most impactful single result if confirmed.

---

### Direction 1: Empirical Spectral Taxonomy of Formal Libraries

**Conjecture**: When the depth spectrum, reuse spectrum, and degree spectrum of Mathlib subtheories are computed and clustered, the number of distinct spectral clusters is at most logarithmic in the total number of declarations — specifically, fewer than 20 clusters account for over 90% of Mathlib's ~150,000 declarations, and these clusters correspond to recognizable mathematical domains (algebra, analysis, topology, combinatorics, etc.) with quantitative boundaries that outperform hand-assigned domain labels for predicting proof tactic effectiveness.

**Test**: Write a Python script that (1) parses Lean/Mathlib `.olean` files or the declaration index to extract the dependency hypergraph, (2) computes depth, reuse count, and out-degree for each declaration, (3) forms spectral signature vectors for each Mathlib submodule (e.g., `Mathlib.Algebra.Group`, `Mathlib.Topology.Basic`), (4) clusters these vectors using k-means or DBSCAN, (5) compares cluster assignments with hand-labeled domain categories, and (6) tests whether cluster membership predicts `aesop`/`simp`/`omega` tactic success rates better than domain labels. The conjecture is refuted if no clear clustering emerges, or if domain labels predict tactic success equally well.

**Impact**: If confirmed, this would be the first quantitative "phase diagram" of mathematics, immediately useful for automated theorem proving (prover strategy selection based on spectral cluster), for library organization (detecting misclassified declarations), and for pedagogy (identifying which theories are structurally most similar for learning transfer).

**Catalog References**: `Bridges/TheoremSpaceRenormalization.lean` (this cycle's depth spectrum and coarse-graining definitions), `Bridges/RenormalizationUniversality.lean` (ClosureFlow and AsymptoticCong), `Computation/InfoEfficientAlgorithms.lean` (algorithmic complexity framework).

**Proof Strategy**: This direction is primarily computational/empirical, not proof-theoretic. The main technical challenge is efficient extraction of Mathlib's dependency graph. Use `lake env printPaths` and the `.ilean` file format to extract imports, or use the Lean 4 API to traverse the environment. Clustering algorithms are standard. The key mathematical content would be formalizing the clustering criterion and proving that the spectral distance metric is well-defined and satisfies the triangle inequality.

**Domain Bridges**: Computation (dependency graph algorithms) ↔ Algebra (spectral theory of adjacency matrices) ↔ Machine Learning (clustering and classification)

**Lineage**: Builds on this cycle's `StrictDepthFlow`, `depthSpectrum`, and `maxDepth` definitions.

**Ambition**: grand_challenge

---

### Direction 2: Resolution of the Spectral Rigidity Conjecture

**Conjecture**: (Spectral Rigidity, restated precisely) For strict depth flows on finite types, the depth spectrum as a multiset determines the number of fixed points. That is, if two flows `(α, step_α, depth_α)` and `(β, step_β, depth_β)` have identical depth spectra (multisets of `{depth(x) | x ∈ α}` and `{depth(y) | y ∈ β}`), then `|Fix(step_α)| = |Fix(step_β)|` where `Fix(f) = {x | f(x) = x}`.

**Test**: Attempt to construct a counterexample by finding two strict depth flows on finite types (e.g., types with 6-10 elements) with identical depth spectra but different fixed-point counts. Enumerate all strict depth flows on `Fin n` for small n and check computationally whether the conjecture holds. If no counterexample is found for n ≤ 12, attempt a formal proof. Conversely, if a counterexample is found, formalize it as a disproof.

**Impact**: If true, the depth spectrum would be a *complete invariant* for universality class counting, dramatically simplifying the classification problem. If false, the counterexample would reveal exactly what additional information beyond depth is needed — which could lead to a refined invariant (e.g., depth spectrum + reuse spectrum) that is complete.

**Catalog References**: `Bridges/TheoremSpaceRenormalization.lean` (SpectralRigidityConjecture definition, fixedPointFinset, depthSpectrum), `Bridges/RenormalizationUniversality.lean` (finite_stabilization_or_periodic_bound).

**Proof Strategy**: Start with computational enumeration. For each function `f : Fin n → Fin n`, compute a valid depth function (if one exists making it a strict depth flow), record the depth spectrum and fixed-point count, and check for spectrum collisions with different fixed-point counts. If the conjecture appears true, the proof strategy would likely use the fact that depth-0 elements are exactly the fixed points, so the number of 0s in the depth spectrum equals the fixed-point count. This would make the conjecture trivially true — check this first! If the depth function isn't required to assign 0 exactly to fixed points, the conjecture is more subtle.

**Domain Bridges**: Combinatorics (enumeration of self-maps) ↔ Algebra (fixed-point theory) ↔ Logic (decidability of the invariant)

**Lineage**: Direct continuation of this cycle's `SpectralRigidityConjecture`.

**Ambition**: extension

---

### Direction 3: Categorical Structure of Flow Morphisms

**Conjecture**: The category **SDF** of strict depth flows and flow morphisms has all finite limits and colimits, and the forgetful functor to **Set** creates (not merely preserves) finite limits. Moreover, the "universality quotient" construction defines a functor **SDF** → **Set** that preserves finite coproducts but not finite products — reflecting the Merging Principle (coproduct = disjoint union preserves class counts, but product can merge classes).

**Test**: (1) Construct the product of two strict depth flows in Lean 4 and verify the universal property. (2) Construct the coproduct (disjoint union). (3) Construct the equalizer. (4) Show that the universality quotient functor preserves coproducts by proving that `|Classes(α ⊔ β)| = |Classes(α)| + |Classes(β)|`. (5) Find a counterexample to product preservation: two flows whose product has fewer universality classes than the product of their class counts.

**Impact**: Understanding the categorical structure of the flow category would enable systematic construction of new flows from old ones, and would connect the renormalization framework to the rich categorical machinery in Mathlib. The failure of product preservation would be a precise categorical encoding of the physical phenomenon of "emergent universality" — the appearance of new universality classes when systems interact.

**Catalog References**: `Bridges/TheoremSpaceRenormalization.lean` (FlowMorphism, CoarseGraining, flowMorphismComp), `Bridges/CategoricalBridges.lean`, `Bridges/RenormalizationUniversality.lean` (UniversalityQuotient).

**Proof Strategy**: Define `StrictDepthFlow.prod` as `(α × β, step_α × step_β, depth_α + depth_β)`. The depth function sum guarantees strict decrease. Products are straightforward. Coproducts use the sum type. Equalizers are subtype constructions. The key technical challenge is the depth function on equalizers: one needs `depth` to agree on elements where `f = g`, which requires choosing a compatible depth. For the universality quotient, the coproduct preservation follows from the fact that orbits in a disjoint union don't interact.

**Domain Bridges**: Category Theory (limits and colimits) ↔ Algebra (product structures) ↔ Physics (interacting vs non-interacting systems)

**Lineage**: Builds on this cycle's flow morphism composition theorem and the existing `ClosureFlowMonoid` algebraic structure.

**Ambition**: extension

---

### Direction 4: Tropical Renormalization and Proof Complexity

**Conjecture**: There exists a strict depth flow on the tropical semiring (ℝ ∪ {∞}, min, +) whose fixed points correspond to optimal proof strategies — specifically, the depth function equals the tropical polynomial degree, and the universality classes under this flow correspond to complexity classes of proof search (polynomial-depth proofs vs exponential-depth proofs form distinct universality classes separated by a phase transition at a critical reuse ratio).

**Test**: (1) Define a strict depth flow on tropical polynomials where the step function is tropical convolution (min-plus matrix multiplication on the coefficient vector). (2) Compute the depth spectrum for tropical polynomials of degree ≤ 20. (3) Check whether the fixed points have a clean algebraic characterization (e.g., idempotent tropical polynomials). (4) Test whether the universality classes correlate with proof complexity: encode known NP-hard proof search problems as tropical optimization and check whether they fall in a distinct class from polynomial-time problems.

**Impact**: This would connect the abstract renormalization framework to concrete proof complexity, potentially giving a new characterization of complexity classes via tropical RG fixed points. It would also bridge to the Catalog's existing tropical semiring work.

**Catalog References**: `Tropical/` (tropical semiring definitions and properties), `Algebra/Bridges.lean` (`TropicalContraction.has_fixed_point_approach`), `Bridges/AlgebraEMLTropicalPressure.lean`, `Computation/PadicValuationDepth.lean` (depth measures).

**Proof Strategy**: Start by defining the tropical strict depth flow using Mathlib's `Tropical` type. The step function should be tropical matrix-vector multiplication (min-plus). The depth function is the support size of the tropical polynomial. Key lemma: tropical convolution with a contraction matrix strictly reduces support size. This connects to the existing `TropicalContraction.has_fixed_point_approach` in the Catalog.

**Domain Bridges**: Tropical Geometry (min-plus algebra) ↔ Computation (complexity theory) ↔ Physics (free energy minimization as tropical RG)

**Lineage**: Builds on this cycle's `StrictDepthFlow` and the Catalog's tropical semiring infrastructure.

**Ambition**: grand_challenge

---

### Direction 5: Weighted Coarse-Graining and Information-Theoretic Depth

**Conjecture**: Replacing the ℕ-valued depth function with a Shannon entropy-weighted depth (where each node's depth includes a log-factor for the number of alternative proof paths) yields a strict depth flow whose convergence rate is information-theoretically optimal: the number of coarse-graining steps to fixed point equals the mutual information between the fine-grained and fixed-point descriptions, up to a universal constant.

**Test**: (1) Define an entropy-weighted depth function: `depth_H(x) = depth(x) + ⌈log₂(|{paths from axioms to x}|)⌉`. (2) Verify that this is still a valid depth function for the strict depth flow axioms (key: check that depth_H decreases strictly at non-fixed points). (3) Compare convergence times of ℕ-valued and entropy-weighted depths on synthetic hypergraphs with 100-1000 nodes. (4) Compute the mutual information `I(X; X_∞)` between initial and fixed-point states and check the conjectured relationship.

**Impact**: An information-theoretic characterization of convergence would connect proof renormalization to minimum description length (MDL) theory and Kolmogorov complexity, potentially explaining why some mathematical theories are "more compressible" than others. This bridges to the Catalog's MDL work.

**Catalog References**: `MachineLearning/QuantizedResidualMDL.lean` (`mdl_bound_via_fixed_point_transfer`), `Bridges/TheoremSpaceRenormalization.lean` (StrictDepthFlow, maxDepth), `EML/EMLv17Core.lean` (ensemble complexity).

**Proof Strategy**: The key mathematical step is proving that entropy-weighted depth still satisfies the strict decrease axiom. This requires showing that coarse-graining reduces the number of proof paths (or at least doesn't increase them faster than it reduces depth). The connection to MDL would formalize as: the fixed-point structure is a minimum-description-length encoding of the original theory.

**Domain Bridges**: Information Theory (entropy, mutual information) ↔ Machine Learning (MDL, compression) ↔ Physics (free energy as information)

**Lineage**: Builds on this cycle's `StrictDepthFlow` convergence theorem and the Catalog's MDL framework.

**Ambition**: extension
