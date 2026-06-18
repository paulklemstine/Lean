# Future Directions: Semantic Quotient Extraction

## Synthesis

The theorems proved in this cycle establish that extraction correctness is fundamentally about **semantic quotient invariance**, not rewrite convergence. This opens five interconnected research directions: (1) extending the quotient principle to many-sorted and higher-order signatures, (2) quantifying the compression power of non-confluent extraction, (3) applying the principle to quantum circuit optimization, (4) building categorical infrastructure for functorial extraction, and (5) connecting to proof-theoretic methods for program equivalence. Each direction builds on the core theorem `eqvGen_semantics_preserved_of_step_sound` and its compositional extension `contextual_eqvGen_semantics_preserved`, and each can be tested either formally or computationally.

---

## Direction 1: Many-Sorted Semantic Quotient Extraction

**Conjecture.** For any many-sorted first-order signature Σ with a compositional denotation into a Σ-algebra A, and any sort-respecting rewrite relation R that preserves denotation at each step, extraction from `EqvGen R` preserves denotation at every sort.

**Test.** Formalize many-sorted terms and denotation in Lean 4. Define `ContextClosure` for many-sorted signatures (requiring sort-compatibility of substitutions). Prove the analogue of `contextual_eqvGen_semantics_preserved` for the many-sorted case. Computationally: generate 100 random 3-sorted signatures with 5 function symbols each, generate sound rewrite rules, and verify extraction soundness across 1000 terms per signature.

**Impact.** This would extend the theorem to cover real programming languages with multiple types, database query languages with table/column/value sorts, and multi-sorted algebraic specifications. It's the minimal generalization needed for practical compiler applications.

**Catalog References.**
- `Catalog/Pythagorean/SemanticQuotientExtraction.lean`: `eqvGen_semantics_preserved_of_step_sound`, `contextual_eqvGen_semantics_preserved`
- `Catalog/Pythagorean/EqualitySaturationExtraction.lean`: `extraction_semantics_preserved`

**Proof Strategy.** Generalize `Term` to a many-sorted inductive type indexed by sort. Define `ContextClosure` with sort constraints. The proof should follow the same structure: induction on `ContextClosure` for step soundness, then apply the abstract theorem.

**Domain Bridges.** Universal algebra, type theory, database optimization.

**Lineage.** Direct extension of Theorem 3 (`contextual_eqvGen_semantics_preserved`).

**Ambition.** Solid extension — the proof structure is clear, but the formalization requires careful handling of sort indices.

---

## Direction 2: Compression Ratio Bounds for Non-Confluent Extraction

**Conjecture (Cost-Invariant Semantic Compression).** For finite non-confluent sound rewrite systems with average branching factor b (average number of terms reachable in one step) and saturation depth d, the compression ratio (extracted size / original size) is bounded above by O(1/b^{d/2}) on average over random terms.

**Test.** Generate 200 finite rewrite systems with controlled branching factors (b ∈ {2, 3, 5, 8}). For each, generate 500 random terms, run bounded saturation to depths d ∈ {1, 2, 3, 4, 5}, extract cheapest, and measure compression ratios. Fit the data to the conjectured bound. A single family achieving compression worse than O(1/b^{d/4}) at all depths would weaken the conjecture.

**Impact.** This would provide the first quantitative theory of how much optimization equality saturation can achieve, enabling cost-benefit analysis for optimizer design. It would also connect to information-theoretic compression bounds.

**Catalog References.**
- `Catalog/Pythagorean/SemanticQuotientExtraction.lean`: `extraction_sound_of_eqvGen_sound`
- `Catalog/Pythagorean/EqualitySaturationExtraction.lean`: `cheapest_extraction_sound_and_optimal`

**Proof Strategy.** Model the rewrite graph as a random graph with branching factor b. Use probabilistic arguments to bound the expected minimum-size term reachable in d steps. The key technical challenge is handling the non-independence of rewrite paths.

**Domain Bridges.** Information theory, random graph theory, combinatorial optimization.

**Lineage.** Builds on Theorem 2 and the concrete non-confluent example.

**Ambition.** Grand challenge — the quantitative bound is speculative and would require novel probabilistic arguments.

---

## Direction 3: Quantum Circuit Optimization via Quotient Extraction

**Conjecture.** For the ZX-calculus (a graphical language for quantum circuits), every equation in the complete equational theory preserves the denotation of circuits as linear maps. Therefore, extraction from `EqvGen ZXStep` preserves circuit semantics, enabling sound optimization of quantum circuits without canonical forms.

**Test.** Formalize a fragment of the ZX-calculus in Lean 4 (e.g., Clifford circuits). Define denotation into 2×2 complex matrices. Define the spider fusion and Hadamard rules as a rewrite relation. Prove step soundness. Apply `eqvGen_semantics_preserved_of_step_sound`. Computationally: generate 50 random ZX diagrams with ≤ 10 spiders, saturate with ZX rules, extract cheapest, and verify matrix equality.

**Impact.** Quantum circuit optimization is a critical bottleneck for near-term quantum computing. The ZX-calculus has a rich but highly non-confluent equational theory. Proving that extraction is sound without confluence would immediately justify practical optimizers like PyZX and Quizx.

**Catalog References.**
- `Catalog/Pythagorean/SemanticQuotientExtraction.lean`: `eqvGen_semantics_preserved_of_step_sound`, `sk_eqvGen_denote_preserved` (as template)

**Proof Strategy.** Follow the SK combinator template: define a `ZXModel` structure with the required algebraic laws, prove step soundness by cases on the rewrite rules, then apply the abstract theorem. The main challenge is formalizing matrix semantics.

**Domain Bridges.** Quantum computing, linear algebra, graphical calculi.

**Lineage.** Extends the SK combinator bridge (Theorem 4) to a physically meaningful domain.

**Ambition.** Grand challenge — ZX-calculus formalization in Lean is substantial, but the proof structure is clear from the SK case.

---

## Direction 4: Categorical Extraction as Functorial Section

**Conjecture.** The extraction theorem can be stated categorically: for any functor F : C → D that is constant on morphisms generated by a congruence E, the composite F ∘ s (where s is a section of the quotient C → C/E) equals F. This generalizes `extraction_sound_of_eqvGen_sound` to arbitrary categories.

**Test.** Formalize the categorical statement in Lean 4 using Mathlib's category theory library. Prove it for concrete categories: Set, Grp, Ring, and the category of finite-dimensional vector spaces. Show that instantiating to the term algebra recovers `extraction_sound_of_eqvGen_sound`.

**Impact.** This would place equality saturation firmly in the landscape of categorical algebra, enabling transfer of results across domains via functorial reasoning. It would also connect to the theory of Kan extensions and adjunctions.

**Catalog References.**
- `Catalog/Pythagorean/SemanticQuotientExtraction.lean`: `denoteLiftQuotient`, `quotientSoundExtractor_of_step_sound`

**Proof Strategy.** Use the universal property of coequalizers in Mathlib. The key insight is that `denote` factors through the coequalizer of `R`, and extraction is a section of the quotient map. The factorization gives `denote = denote_quotient ∘ π`, and `denote ∘ s = denote_quotient ∘ π ∘ s = denote_quotient`.

**Domain Bridges.** Category theory, topos theory, homological algebra.

**Lineage.** Deepens the quotient perspective introduced by `denoteLiftQuotient`.

**Ambition.** Solid extension — the categorical machinery exists in Mathlib, but connecting it to the concrete theorem requires care.

---

## Direction 5: Semantic Quotient Principle for Infinite Models

**Conjecture (Semantic Quotient Principle for Infinite Models).** For any countable first-order term language with denotation into a complete metric space (σ, d), if every rewrite step contracts d (i.e., d(denote a, denote b) = 0 whenever R a b), then extraction from EqvGen R is semantics-preserving. Moreover, for approximate step-soundness (d(denote a, denote b) ≤ ε for R a b), extraction from EqvGen R of depth n introduces error at most n·ε.

**Test.** Formalize the approximate version. For the exact case, it reduces to the existing theorem. For the approximate case: generate rewrite systems with approximate soundness (rules that change denotation by at most ε), saturate, extract, and measure the actual semantic error vs. the predicted n·ε bound. Test with 100 systems and ε ∈ {0.01, 0.1, 0.5}.

**Impact.** This would extend the theory to numerical optimization, where rewrite rules (e.g., floating-point identities) are only approximately sound. It could justify approximate equality saturation for numerical programs.

**Catalog References.**
- `Catalog/Pythagorean/SemanticQuotientExtraction.lean`: `eqvGen_semantics_preserved_of_step_sound` (exact case)

**Proof Strategy.** For the exact case: trivial specialization. For the approximate case: induction on `EqvGen` depth, accumulating ε at each `rel` step and 0 at `refl`/`symm`/`trans` steps (triangle inequality). The bound n·ε follows from the depth bound.

**Domain Bridges.** Numerical analysis, floating-point optimization, approximate computing.

**Lineage.** Quantitative refinement of Theorem 1.

**Ambition.** Solid extension with a speculative quantitative component — the exact case is trivial but the approximate case requires new definitions.
