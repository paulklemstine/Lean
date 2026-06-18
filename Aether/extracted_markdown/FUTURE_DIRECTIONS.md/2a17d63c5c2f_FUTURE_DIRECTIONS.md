# Future Directions

## Synthesis

This research cycle established the **Invariant Spectrum** as a novel mathematical structure for reasoning about graded classification systems. The key discovery is that the classical K(G,1) theorem — the fundamental group is a complete invariant for aspherical spaces — admits a purely algebraic formulation that separates the topological content from the algebraic content. The Aspherical Completeness Transfer Theorem shows that for any graded invariant system where higher levels are trivial, level 1 completeness transfers to all higher cumulative levels and vice versa. This opens a systematic approach to classification problems across mathematics.

The most promising cross-domain connection is to the existing catalog results on invariant completeness: the `tropical_profile_complete_for_bounded_architecture_congruence` and `betaEq_complete_nerode_invariant` theorems are both instances of our CompleteInvariant structure, and could be embedded as specific levels of InvariantSpectra for their respective domains. The bridge from graded invariant theory to tropical/operadic classification is the highest-potential direction for the next cycle.

A secondary but important direction is formalizing the *quantitative* aspects: the confusion count, its monotone decrease, and the zero-confusion characterization of completeness. These were defined but their proofs require decidability instances that are natural in finite settings but need careful construction in Lean 4.

---

### Direction 1: Categorical Invariant Spectra — Functorial Classification Theory

**Conjecture**: The Invariant Spectrum framework generalizes to a categorical setting where sound invariants become functors F : C → D between categories, complete invariants become faithful functors, and the K(G,1) theorem becomes: if a tower of functors F₀, F₁, F₂, ... has Fₙ naturally isomorphic to a constant functor for all n > 1, then F₁ faithful implies the product F₀ × F₁ is faithful.

**Test**: Define a `CategoricalSpectrum` structure in Lean 4 using Mathlib's category theory library. State and prove the categorical K(G,1) theorem. Test whether the categorical version implies the setoid version as a special case (viewing setoids as thin categories).

**Impact**: If true, this unifies classification theory across algebra (classifying groups by invariants), topology (classifying spaces by homotopy groups), and representation theory (classifying representations by characters). If false, the failure point reveals which aspects of classification are inherently non-categorical.

**Catalog References**: `Bridges/InvariantSpectrum.lean` (InvariantSpectrum, aspherical_one_complete_iff)

**Proof Strategy**: Use Mathlib's `CategoryTheory.Functor`, define faithful towers, prove that natural isomorphism to a constant functor makes higher levels redundant. The key step is showing that faithfulness of the product functor F₀ × F₁ follows from faithfulness of F₁ alone when F₂, F₃, ... are constant.

**Domain Bridges**: Algebraic Topology <-> Category Theory <-> Model Theory (classification of structures)

**Lineage**: Builds on InvariantSpectrum and aspherical_one_complete_iff from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Tropical Invariant Spectra — Graded Tropical Classification

**Conjecture**: The tropical profile invariant from `OperadicTropicalization` can be embedded as level 1 of an Invariant Spectrum for operad architectures, where level 0 is the arity profile and level 2 is a "tropical curvature" invariant measuring the deviation from linearity in the min-plus algebra. The resulting spectrum should have essential dimension ≤ 2 for bounded architectures.

**Test**: Construct the explicit InvariantSpectrum for operad architectures. Define "tropical curvature" as a numerical invariant. Verify that the existing `tropical_profile_complete_for_bounded_architecture_congruence` theorem corresponds to level 1 completeness. Compute essential dimension for small examples.

**Impact**: If the essential dimension is exactly 1 (not 2), it proves the tropical profile captures ALL relevant information and curvature is redundant — strengthening the existing theorem. If the essential dimension is 2, tropical curvature is a genuinely new invariant with classification power beyond the profile.

**Catalog References**: `Bridges/OperadicTropicalization.lean` (tropical_profile_complete_for_bounded_architecture_congruence), `Bridges/InvariantSpectrum.lean` (InvariantSpectrum, essentialDim)

**Proof Strategy**: Define ArchitectureSpectrum : InvariantSpectrum OperadArch where level 0 = arity, level 1 = tropical profile, level 2 = tropical curvature. Use the existing completeness theorem to establish level 1 completeness for bounded architectures. Then either prove asphericity (showing level 2 is trivial) or construct a confusion pair at level 1 in the unbounded case.

**Domain Bridges**: Tropical Geometry <-> Invariant Spectrum Theory <-> Operadic Algebra

**Lineage**: Builds on tropical_profile_complete_for_bounded_architecture_congruence and InvariantSpectrum.

**Ambition**: extension

---

### Direction 3: Confusion Algebra — The Quantitative Theory of Incomplete Classification

**Conjecture**: For any Invariant Spectrum on a finite type of size n, the sequence of confusion counts C₀ ≥ C₁ ≥ C₂ ≥ ... satisfies: (a) C_k = 0 for some k ≤ n(n-1)/2 (the confusion count reaches zero within quadratically many levels), and (b) if C_k = C_{k+1} for some k, then C_j = C_k for all j ≥ k (the sequence stabilizes at its first repeated value).

**Test**: Enumerate all possible InvariantSpectra on types of size 3, 4, 5. Compute confusion count sequences. Check whether stabilization always occurs at the first repeated value. Implement this as a Python enumeration with exact arithmetic.

**Impact**: Part (a) gives a computable upper bound on essential dimension. Part (b) gives an early termination criterion for computing essential dimension. Together, they make the "invariant completeness problem" tractable for finite structures.

**Catalog References**: `Bridges/InvariantSpectrum.lean` (confusionCount, confusion_count_antitone [stated but unproved in this cycle])

**Proof Strategy**: For (a), note that C_k counts pairs in α × α, so C_0 ≤ n². The antitone property gives a strictly decreasing subsequence until C_k = 0. For (b), if C_k = C_{k+1}, the set of confusion pairs is unchanged by adding level k+1, so adding any further level also leaves it unchanged (by induction on the levels). This requires formalizing the "confusion set" as a subset of α × α and showing it's a chain under inclusion.

**Domain Bridges**: Combinatorics <-> Invariant Spectrum Theory <-> Information Theory (confusion as entropy)

**Lineage**: Builds on InvariantSpectrum and confusionCount definitions from this cycle.

**Ambition**: extension

---

### Direction 4: Homotopy Type as Essential Dimension — Connecting to Real Algebraic Topology

**Conjecture**: Define a formal "model homotopy spectrum" for finite simplicial complexes, where inv(n) computes a combinatorial analogue of πₙ (using the simplicial fundamental group for n=1 and simplicial homology groups as a proxy for higher homotopy groups for n ≥ 2). For finite graphs (1-dimensional simplicial complexes), this spectrum should be aspherical with essential dimension 1.

**Test**: Implement the simplicial fundamental group for finite graphs in Lean 4. Construct the model spectrum. Prove asphericity for 1-dimensional complexes (since πₙ = 0 for n ≥ 2 for any graph). Use the Aspherical Completeness Transfer Theorem to conclude that the fundamental group classifies graphs up to the induced homotopy equivalence.

**Impact**: This would be the first machine-verified proof that graphs are classified by their fundamental group — a classical result in algebraic topology that has never been formalized. It would also validate the Invariant Spectrum framework by showing it can recover genuine topological results.

**Catalog References**: `Bridges/InvariantSpectrum.lean`, `Bridges/ImpossibleObjectsTopology.lean` (fundamental_theorem_cycles)

**Proof Strategy**: Define SimplicialComplex as a structure with vertices and simplices. Define the edge-path group (fundamental group for graphs). Construct the InvariantSpectrum with level 1 = edge-path group. Prove asphericity by showing that for 1-dimensional complexes, the higher "homology invariants" are all trivial. Apply aspherical_one_complete_iff.

**Domain Bridges**: Algebraic Topology <-> Combinatorics (Graph Theory) <-> Invariant Spectrum Theory

**Lineage**: Builds on InvariantSpectrum, aspherical_one_complete_iff, and fundamental_theorem_cycles.

**Ambition**: grand_challenge

---

### Direction 5: Nerode Invariant Spectrum — Connecting to Automata Theory

**Conjecture**: The Nerode equivalence and β-equivalence from `BetaClassCanonicity` form a 2-level Invariant Spectrum for automata states, where level 0 = β-equivalence classes and level 1 = Nerode classes. The existing `betaEq_complete_nerode_invariant` theorem should correspond to level 0 completeness in this spectrum. Furthermore, this spectrum should be aspherical (level 1 adds no information beyond level 0), making essential dimension = 0.

**Test**: Construct the explicit InvariantSpectrum for automata states. Embed the existing completeness theorem. Prove or disprove asphericity. If aspherical, the essential dimension is 0 (β-equivalence alone classifies). If not, find a confusion pair at level 0 — two states with the same β-class but different Nerode classes.

**Impact**: If the spectrum is aspherical (essential dimension 0), this proves β-equivalence is strictly stronger than Nerode equivalence for classification — a result with implications for automaton minimization algorithms. If not aspherical, it identifies a new invariant (level 1) that provides additional classification power.

**Catalog References**: `Bridges/BetaClassCanonicity.lean` (betaEq_complete_nerode_invariant), `Bridges/InvariantSpectrum.lean`

**Proof Strategy**: Define AutomatonSpectrum where level 0 = β-class, level 1 = Nerode class. Use the existing completeness theorem to show level 0 is complete. This immediately implies asphericity is irrelevant (level 0 completeness implies cumulative 0-completeness, and monotonicity gives the rest).

**Domain Bridges**: Automata Theory <-> Invariant Spectrum Theory <-> Classification Theory

**Lineage**: Builds on betaEq_complete_nerode_invariant and InvariantSpectrum.

**Ambition**: extension
