# Future Directions: Reflective Type Theory

## Synthesis

This research cycle established the algebraic foundations of Reflective Type Theory (ReflTT), proving that modal nesting depth is a tropical semiring homomorphism from the formula algebra to (ℕ, max, +). The key results form an interconnected web: the substitution depth bound (Theorem 4.1) shows that the tropical filtration is stable under instantiation; the axiom depth hierarchy separates modal axioms into two clean levels corresponding to one-step vs. iterated reasoning; the depth-complexity gap demonstrates orthogonality between self-referential depth and propositional complexity; and the reflective fixed-point theorem provides a constructive "first passage" characterization.

The most promising cross-domain connection is the bridge between tropical algebra and provability logic. The Catalog contains tropical fixed-point theorems (`Tropical/TropicalSelfReasoning.lean:self_reasoning_fixed_point`, `Logic/TropicalGodelSentence.lean:tropical_diagonal_fixed_point`) that could potentially be composed with our depth homomorphism to produce new provability-theoretic results. The categorical infrastructure in the Catalog (`EML/CategoryTheorems.lean`) could formalize the depth filtration as a filtered category, enabling categorical proofs about provability.

The highest breakthrough potential lies in Direction 1 (First-Order Depth), which would extend the tropical framework from propositional to first-order provability logic, requiring a two-dimensional tropical structure (modal depth × quantifier depth). Direction 3 (Tropical Proof Complexity) is the most immediately testable, with concrete computational predictions about proof sizes. Direction 5 (Depth Spectrum Invariant) is the most novel, potentially defining a new topological invariant of modal formulas.

---

### Direction 1: Two-Dimensional Tropical Depth for First-Order Provability Logic

**Conjecture**: In first-order provability logic (extending GL with quantifiers ∀, ∃), the pair (modal_depth, quantifier_depth) forms a homomorphism to the product tropical semiring (ℕ × ℕ, max, +), where max and + operate componentwise. Furthermore, the interaction between quantifiers and the provability modality □ creates a non-trivial coupling: depth(□∀xA) involves both dimensions, and this coupling is governed by a specific tropical bilinear form.

**Test**: Define first-order modal formulas with both □ and ∀/∃. Compute the two-dimensional depth for standard first-order provability axioms (Barcan formula: ∀x□A → □∀xA, and its converse). Verify that the componentwise tropical homomorphism property holds. Check whether the Barcan formula and its converse live at different points in the 2D depth lattice.

**Impact**: If true, this would provide a systematic algebraic framework for first-order provability, where the existing propositional theory embeds as the "modal axis" of a 2D tropical plane. The 2D structure could reveal new axiom independence results by showing formulas live at incomparable lattice points. If false, the failure mode would identify where quantifier-modal interaction breaks tropical structure, pointing to a more complex (possibly non-commutative) algebraic framework.

**Catalog References**: `Logic/TropicalGodelSentence.lean`, `Tropical/TropicalTypeTheory.lean`, `Logic/HomotopyTypeTheory.lean`

**Proof Strategy**: Define `FOFormula` extending `MFormula` with ∀ and ∃ constructors. Define `modalDepth` and `quantifierDepth` separately, then `depth2D := (modalDepth, quantifierDepth)`. Prove componentwise tropical homomorphism. The key lemma is that `depth2D(□∀xA) = (modalDepth(A) + 1, quantifierDepth(A) + 1)` showing coupling. Use the substitution depth bound technique from this cycle, generalized to 2D.

**Domain Bridges**: Tropical geometry (product semirings) ↔ First-order provability logic ↔ Type theory (dependent types as first-order quantification)

**Lineage**: Builds on `depth_tropical_hom`, `depth_subst_bound`, and the `ReflectiveTypeSystem` abstraction from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Normalized Proof Terms and Strong Normalization for ReflTT

**Conjecture**: The proof term calculus defined in this cycle (with axK, axS, mp, nec constructors and congruence reduction) is strongly normalizing: every reduction sequence terminates. Furthermore, the normal forms have a canonical structure where all necessitation steps (nec) are pushed outward and all modus ponens steps (mp) are performed at the innermost level, yielding a "necessitation-normal form."

**Test**: Extend the reduction relation with β-reduction rules (SKK reduction). Define a measure on proof terms (e.g., term size, or a lexicographic measure combining depth and size). Prove that this measure strictly decreases under reduction. As a computational test: enumerate all proof terms of size ≤ 10, compute their normal forms, and verify termination.

**Impact**: Strong normalization would give decidability of type checking and a canonical form for proofs. The necessitation-normal form would separate the "modal" and "propositional" components of proofs, mirroring the depth filtration at the proof level. If false, finding a non-terminating reduction sequence would reveal that self-referential proof simplification can loop — a fundamental obstacle to computational proof theory.

**Catalog References**: `Logic/Confluence.lean`, `Logic/Completeness.lean`

**Proof Strategy**: Define a reducibility candidates interpretation. Map each formula A to a set of proof terms (the "reducible terms of type A"). Show that all constructors preserve reducibility. Key technical challenge: the nec constructor interacts with the modal depth, requiring a stratified induction on depth. Use the depth filtration as the well-founded order for the outer induction.

**Domain Bridges**: Term rewriting theory ↔ Modal proof theory ↔ Type-theoretic normalization (Girard's reducibility candidates)

**Lineage**: Builds on `subject_reduction`, `HasType`, `Reduces` from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Tropical Proof Complexity Bounds

**Conjecture**: For formulas A of depth d and size s in GL, the minimum proof size (number of proof term nodes) is bounded below by Ω(d · log s) and above by O(s^d). More precisely, if A is provable in GL, then the smallest proof term t with t : A has size at least d · ⌈log₂(s)⌉ and at most s^(2d).

**Test**: Enumerate all provable formulas of depth ≤ 3 and size ≤ 20 in GL. For each, find the shortest proof and plot proof_size vs (depth × log(size)). Fit regression lines to test the conjectured lower and upper bounds. The lower bound is the more surprising claim — verify it holds for at least 100 examples.

**Impact**: If true, this would establish the first complexity-theoretic separation result using the tropical depth structure: it would mean that depth acts as a "complexity amplifier," multiplying the inherent difficulty of proving a formula. This connects provability logic to circuit complexity (where depth and size are the fundamental parameters). If the lower bound fails, it would mean depth can be "compiled away" — deep formulas have short proofs that avoid deep reasoning.

**Catalog References**: `Computation/PadicValuationDepth.lean`, `Computation/InfoEfficientAlgorithms.lean`

**Proof Strategy**: For the upper bound, construct proofs by induction on depth, using the substitution depth bound. Each depth level contributes a polynomial factor. For the lower bound, use a counting argument: the number of proof terms of size n is at most exponential in n, while the number of provable formulas of depth d and size s grows faster, forcing some proofs to be large. The key lemma is a combinatorial bound on the number of distinct formulas in DepthLevel(d) of size ≤ s.

**Domain Bridges**: Proof complexity ↔ Tropical algebra (depth as complexity parameter) ↔ Circuit complexity (depth-size tradeoffs)

**Lineage**: Builds on `depth_size_gap`, `depth_axiomK`, `depth_iterBox`, `DepthLevel` from this cycle.

**Ambition**: extension

---

### Direction 4: Categorical Depth Filtration and Graded Modal Categories

**Conjecture**: The depth filtration DepthLevel(0) ⊆ DepthLevel(1) ⊆ DepthLevel(2) ⊆ ... defines a filtered monoidal category where the objects at each level are formulas of bounded depth, morphisms are provability derivations, and the monoidal product is implication. The box operator □ is a monoidal endofunctor that shifts the filtration degree by exactly 1. This filtered category is equivalent (as a filtered category) to the category of graded modules over the tropical semiring ℕ.

**Test**: Define the category structure explicitly in Lean. Verify that composition of derivations (modus ponens) preserves filtration degree. Verify that necessitation shifts filtration degree by 1. Check the graded module equivalence for the first 3 filtration levels (d = 0, 1, 2).

**Impact**: If true, this would place provability logic within the framework of filtered/graded categories, enabling the import of powerful homological algebra tools (spectral sequences, derived functors) into provability theory. The graded module equivalence would make depth a genuine algebraic grading, not just a numerical invariant. If false, identifying where the categorical axioms fail would reveal structural asymmetries in provability reasoning.

**Catalog References**: `EML/CategoryTheorems.lean`, `Bridges/AlgebraEMLClosureComputation.lean`

**Proof Strategy**: Use Mathlib's category theory library. Define `DepthCat(d)` as the type of formulas of depth ≤ d. Define morphisms as GL derivations. Show that modus ponens preserves depth bounds (using `depthLevel_closed_imp`). Define the graded structure using the successive quotients DepthLevel(d+1)/DepthLevel(d). The box functor maps DepthCat(d) → DepthCat(d+1).

**Domain Bridges**: Category theory (filtered categories) ↔ Provability logic (depth filtration) ↔ Homological algebra (graded modules)

**Lineage**: Builds on `DepthLevel`, `depthLevel_mono`, `depthLevel_closed_imp`, `box_shifts_level` from this cycle.

**Ambition**: extension

---

### Direction 5: Depth Spectrum as a Topological Invariant

**Conjecture**: The depth spectrum (the multiset of depths of all □ occurrences in a formula) determines the formula up to "depth equivalence" — two formulas with the same depth spectrum have isomorphic depth filtration behavior. More precisely, define two formulas A, B as depth-equivalent if for every substitution σ, depth(A[σ]) = depth(B[σ]). Then depth-equivalence classes are determined by the sorted depth spectrum.

**Test**: Enumerate all formulas of size ≤ 8. Compute depth spectra. Group by sorted spectrum. For each group, verify that all members have the same depth under every substitution mapping variables to formulas of depth 0, 1, 2, 3. If any counterexample is found, the conjecture is false.

**Impact**: If true, the depth spectrum would be a complete invariant for the tropical structure of formulas, analogous to how the characteristic polynomial is a complete invariant for the eigenvalue structure of a matrix. This would reduce questions about depth behavior under substitution to combinatorial questions about multisets. If false, the counterexample would reveal "hidden" depth structure beyond what the spectrum captures — potentially a higher-order tropical invariant.

**Catalog References**: `Logic/SpectralProofSpace.lean`, `Tropical/TropicalStructure.lean`

**Proof Strategy**: Define depth equivalence as a relation. Show that the sorted depth spectrum is an invariant (this follows from the substitution depth bound). For completeness, construct formulas with distinct spectra and show they are depth-inequivalent by exhibiting a separating substitution. The key technical tool is the `depth_subst_bound` theorem, which bounds how substitution interacts with depth.

**Domain Bridges**: Invariant theory ↔ Tropical algebra (multiset invariants) ↔ Modal logic (formula classification)

**Lineage**: Builds on `depthSpectrum`, `boxCount_eq_spectrum_length`, `depth_subst_bound` from this cycle.

**Ambition**: extension
