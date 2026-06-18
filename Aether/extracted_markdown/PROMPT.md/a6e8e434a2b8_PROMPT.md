            ## Assignment: Tropical valuation functor as an order-preserving semiring bridge from algebraic coefficients to tropical convexity

            Fill ALL sorry placeholders. Do NOT change theorem statements.

            ## Research Cycle: Explore → Pattern → Hypothesize → Validate → Upgrade → Repeat

            You are part of an autonomous research system that runs continuously.
            Each cycle's output feeds the next cycle's input in a positive feedback loop.
            Your FUTURE_DIRECTIONS.md determines what the next cycle investigates.
            The quality of your directions determines the quality of future research.

            Follow this cycle model:
            1. **Explore** — Survey what exists, find gaps, identify anomalies.
            2. **Pattern** — Detect structures, connections, and regularities.
            3. **Hypothesize** — Propose falsifiable conjectures bold enough to matter
               and specific enough to fail. "Study X further" is not a hypothesis.
            4. **Validate** — Prove or disprove. Failures teach as much as successes.
            5. **Upgrade** — Integrate what you learned into the knowledge base.
            6. **Repeat** — Your FUTURE_DIRECTIONS.md prescribes the next cycle's
               best, most fruitful research directions.

            The Aristotle prompt drives the research directions, which drive results,
            which drive the next Aristotle prompt — a positive, self-aware, intelligent
            feedback loop. Make each cycle count.

            ## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`,
   `norm_num`, or `rfl` unless the statement itself is genuinely important.
   If the only proof tactic is enumeration, the theorem is not worth formalizing.

2. **At least 3 theorems that demonstrate genuine mathematical insight**:
   Your file must contain at least 3 theorems where removing any key step
   would cause the proof to fail. Depth is measured by insight, not tactic count.

3. **Novel definitions**: Define at least one new mathematical structure or concept
   that does not already exist in the Catalog. Check the catalog references to
   confirm novelty.

4. **Conjecture with testable prediction**: State at least one falsifiable
   conjecture with a clear computational test that could disprove it.


            ### Research Direction
            The key insight is that the existing tropical-certificate machinery can be upgraded from isolated instances into a genuine functorial bridge: a valuation-like map from ordered semirings/rings into the tropical semiring that preserves addition and multiplication in the min-plus sense up to the precise inequalities needed to transport algebraic linear combinations into tropical convexity statements. Why now: the catalog already contains a near-complete sorry target in Speculative/AutoResearch/Bridges/TropicalValuationFunctor.lean, substantial Tropical infrastructure, and strong closure/semimodule bridge patterns in Bridges/AlgebraEMLClosureComputation.lean, so this is tractable as a real theorem pipeline rather than a speculative framework. Concretely, formalize a certificate-valued tropical valuation on integers/naturals/reals, prove monotonicity and subadditivity/multiplicativity laws, then use it to show that the image of an algebraic affine combination with coefficientwise valuation bounds lies in the tropical convex hull of the images of the generators. The endpoint should be a falsifiable bridge theorem: if coefficients satisfy a valuation normalization condition, then valuation of an algebraic linear combination yields a point in tropConvexHull of the valuation images. This would connect Algebra <-> Tropical through an actual transport theorem, not just shared vocabulary, and would give an algorithmic pipeline for producing tropical halfspace certificates from classical coefficient data.

            ### Mathematical Framing
            Define a structure ValuationToTrop on a coefficient semiring R with map v : R -> TropicalSemiringCertificate (or an equivalent tropical scalar type) satisfying: v 0 = top/infinity, v 1 = 0, v (a * b) = v a ⊗ v b, and v (a + b) >= v a ⊕ v b in the tropical order. First complete and strengthen the foundational lemmas around int_tropical_certificate, nat_tropical_certificate, real_tropical_certificate, and tropical_min_comm. Next formulate tropical affine combinations of finitely many vectors and a notion of coefficient normalization compatible with tropical projectivization. Then prove a bridge theorem of the form: for vectors x_i in R^n and coefficients c_i with tropical normalization, the coordinatewise valuation of Σ c_i x_i belongs to tropConvexHull of the valuation images v(x_i), under hypotheses preventing exact cancellation or using inequality-form membership in tropical halfspaces. A second theorem should extract a finite tropical halfspace certificate from valuation bounds on a 

### Lean 4 Sketch
Complete the sorry in Speculative/AutoResearch/Bridges/TropicalValuationFunctor.lean, then move stabilized results into a new Bridges file importing Tropical convexity primitives. Likely use finite-indexed families (Fin n -> R) and coordinatewise maps. The core manageable target is an inequality-based membership theorem rather than full surjective representation of tropical hulls.


            ### Existing Verified Theorems
            Existing theorems you can build on:
  1. `tropical_plus_distributes_over_min_real` : theorem tropical_plus_distributes_over_min_real (a b c : ℝ) :
     (file: Bridges/DynamicProgramming.lean)
  2. `tropical_plus_distributes_over_min_real` : theorem tropical_plus_distributes_over_min_real (a b c : ℝ) :
     (file: FINAL/Bridges/DynamicProgramming.lean)
  3. `tropical_profile_complete_for_bounded_architecture_congruence` : theorem tropical_profile_complete_for_bounded_architecture_congruence
     (file: Bridges/OperadicTropicalization.lean)
  4. `tropical_profile_complete_for_bounded_architecture_congruence` : theorem tropical_profile_complete_for_bounded_architecture_congruence
     (file: FINAL/Bridges/OperadicTropicalization.lean)
  5. `affine_map_lipschitz_from_height` : theorem affine_map_lipschitz_from_height
     (file: Bridges/ArithmeticLearningTheory/Core.lean)
  6. `tropical_semimodule_laws` : theorem tropical_semimodule_laws :
     (file: Bridges/ClosureRateDistortionDuality.lean)
  7. `tropical_kantorovich_closure_bridge` : theorem tropical_kantorovich_closure_bridge {α : Type*}
     (file: Bridges/KantorovichLawvereDuality.lean)
  8. `tropical_plus_distributes_over_min` : theorem tropical_plus_distributes_over_min (a b c : ℝ) :
     (file: Bridges/MinPlusVerificationCore.lean)
  9. `tropical_plus_distributes_over_min'` : theorem tropical_plus_distributes_over_min' (a b c : ℝ) :
     (file: Bridges/TropicalPhylogenetics.lean)
  10. `tropical_plus_distributes_over_min` : theorem tropical_plus_distributes_over_min (a b c : ℕ) :
     (file: Bridges/TropicalRadonGraphDuality.lean)
  11. `tropical_plus_distributes_over_min` : theorem tropical_plus_distributes_over_min (a b c : ℝ) :
     (file: Bridges/TropicalScatteringOneWayDuality.lean)
  12. `tropical_semimodule_laws` : theorem tropical_semimodule_laws :
     (file: FINAL/Bridges/ClosureRateDistortionDuality.lean)
  13. `tropical_kantorovich_closure_bridge` : theorem tropical_kantorovich_closure_bridge {α : Type*}
     (file: FINAL/Bridges/KantorovichLawvereDuality.lean)
  14. `tropical_plus_distributes_over_min` : theorem tropical_plus_distributes_over_min (a b c : ℝ) :
     (file: FINAL/Bridges/MinPlusVerificationCore.lean)
  15. `tropical_plus_distributes_over_min'` : theorem tropical_plus_distributes_over_min' (a b c : ℝ) :
     (file: FINAL/Bridges/TropicalPhylogenetics.lean)

### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


### Catalog Reference Files (Catalog/FINAL/ = vetted, high-quality)

(File paths starting with FINAL/ are vetted, high-quality catalog entries.)
@Speculative/AutoResearch/Bridges/TropicalValuationFunctor.lean
```lean
/-
  # Tropical Valuation Functor:
  # The Bridge Between Multiplicative Algebra, p-Adic Analysis,
  # and Post-Quantum Lattice Security

  ## Domain Bridge: Tropical Geometry ↔ p-Adic Analysis ↔ Lattice Cryptography ↔ Neural Network Robustness

  The central discovery: The p-adic valuation is a *functor* from multiplicative
  algebra to tropical (min-plus) algebra that preserves exactly the structure needed for:
  - Post-quantum lattice security reductions (hardness amplification)
  - Lipschitz-certified neural network robustness (composition bounds)
  - Algorithmic complexity classification (tropical circuit complexity)

  The valuation map v_p : (ℤ_p \ {0}, ×) → (ℤ, +) sends:
  - multiplication ↦ addition
  - divisibility ↦ order
  - gcd ↦ min (tropical multiplication)

  ## Main Results (35+ theorems, zero sorry)

  ## Structures (8 novel types)

  - `TropicalSemiringCertificate` — certified min-plus algebraic structure
  - `ValuationDepthMeasure` — complexity measure via p-adic depth
  - `LipschitzCompositionChain` — chain of Lipschitz maps with certified bound
  - `SpectralAmplificationCertificate` — spectral gap amplification bounds
  - `CertifiedRobustnessWitness` — end-to-end adversarial robustness certificate
  - `TropicalSecurityParameter` — post-quantum security from tropical rank
  - `TropicalHashFunction` — hash function with tropical collision resistance
  - `TropicalDistanceMetric` — tropical metric structure
-/

import Mathlib

open Finset BigOperators

noncomputable section

namespace TropicalValuationFunctor

/-! ## §1. Tropical Arithmetic Infrastructure

The tropical semiring (ℝ ∪ {+∞}, ⊕, ⊗) where:
  a ⊕ b = min(a, b)     (tropical addition)
  a ⊗ b = a + b          (tropical multiplication) -/

set_option checkBinderAnnotations false in
/-- **TropicalSemiringCertificate**: A certificate that a linearly ordered
    additive type carries tropical semiring structure.
    Bridge: connects abstract algebra to quantitative crypto bounds.
    Impact: post_quantum_security, lattice_crypto. -/
structure TropicalSemiringCertificate (α : Type*) [LinearOrder α] [Add α] where
  /-- Tropical addition (min) is commutative -/
  tropAdd_comm : ∀ a b : α, min a b = min b a
  /-- Tropical addition (min) is associative -/
  tropAdd_assoc : ∀ a b c : α, min (min a b) c = min a (min b c)
  /-- Tropical multiplication (add) is commutative -/
  tropMul_comm : ∀ a b : α, a + b = b + a
  /-- Tropical multiplication distributes over tropical addition -/
  tropDistrib : ∀ a b c : α, a + min b c = min (a + b) (a + c)
-- ... (truncated, full file has 531 lines)
```

@Speculative/AutoResearch/TropicalHelly.lean
```lean
/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Tropical Helly's Theorem — From Convexity to Optimization Duality

This file formalizes the foundations of tropical convexity in the max-plus semiring
and proves the tropical Helly theorem along with related results including
tropical Farkas-type lemmas and cross-domain connections.

## Main Definitions

* `IsTropConvex` — Tropical convexity in the max-plus semiring.
* `tropConvexHull` — The tropical convex hull: smallest tropically convex superset.
* `TropHalfspace` — A tropical halfspace: the max-plus analogue of a linear inequality.
* `TropicalNerve` — The nerve complex of a family of tropical convex sets.
* `TropicalFractionalHellyProp` — Falsifiable conjecture for tropical fractional Helly.

## Main Results

* `IsTropConvex.univ`, `.empty`, `.singleton` — Basic examples.
* `IsTropConvex.inter`, `.sInter`, `.iInter` — Closure under intersections.
* `tropConvexHull_isTropConvex`, `tropConvexHull_eq_self` — Hull properties.
* `tropHalfspace_isTropConvex` — Halfspaces are tropically convex.
* `tropConvex_dim1_interval` — Tropical convex sets in ℝ¹ are intervals.
* `tropLift_injective`, `tropLift_combination_bound` — Lifting to classical geometry.
* `tropical_farkas_weak` — Tropical Farkas lemma (weak form).
* `TropicalNerve.downward_closed` — Nerve is a simplicial complex.
* `tropical_helly` — The tropical Helly theorem (the main result).

## References

* Develin, M. and Sturmfels, B., "Tropical Convexity", 2004.
* Gaubert, S. and Katz, R.D., "The tropical analogue of polar cones", 2009.
-/

noncomputable section

open Set Finset BigOperators Classical

/-! ## Part 1: Tropical Convexity Foundations -/

/-- **Tropical convexity in the max-plus semiring.**
    A set S ⊆ ℝⁿ is tropically convex if for all x, y ∈ S and
    all coefficients s, t with max(s, t) = 0, the tropical combination
    i ↦ max(s + xᵢ, t + yᵢ) lies in S.

    The condition max(s, t) = 0 normalizes the tropical coefficients,
    analogous to requiring s + t = 1 in classical convex combinations. -/
def IsTropConvex {n : ℕ} (S : Set (Fin n → ℝ)) : Prop :=
  ∀ ⦃x y : Fin n → ℝ⦄, x ∈ S → y ∈ S →
    ∀ s t : ℝ, max s t = 0 → (fun i => max (s + x i) (t + y i)) ∈ S

/-- **The tropical convex hull**: intersection of all tropically convex supersets. -/
def tropConvexHull {n : ℕ} (T : Set (Fin n → ℝ)) : Set (Fin n → ℝ) :=
  ⋂₀ {S : Set (Fin n → ℝ) | IsTropConvex S ∧ T ⊆ S}

-- ... (truncated, full file has 431 lines)
```

@Bridges/AlgebraEMLClosureComputation.lean
```lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Algebra–EML Turing–Myhill Reconstruction via Closure Semimodule Dynamics

This file formalizes a Myhill–Nerode-style minimal quotient reconstruction from
semiring-valued closure observables.

## Central Bridge

- **Automata theory / intrinsic computation**: closure-driven weighted transition semantics
- **Semiring-linear dynamics / Koopman-style closure evolution**: probe observables
- **Thermodynamic / quantum / cryptographic interpretations**: indistinguishability
-/

import Mathlib

universe u v w

/-! ## §1 Core Definitions -/

/-- A closure semimodule system: a deterministic transition system equipped with
a closure operator on state sets and a semiring-valued output function.

Bridge: connects automata theory to Koopman dynamics and semiring-linear algebra
via closure-enriched observational semantics. -/
structure ClosureSemimoduleSystem
    (σ : Type u) (α : Type v) (K : Type w)
    [Semiring K] where
  step : σ → α → σ
  output : σ → K
  closure : Set σ → Set σ
  closure_extensive : ∀ S : Set σ, S ⊆ closure S
  closure_mono : ∀ ⦃S T : Set σ⦄, S ⊆ T → closure S ⊆ closure T
  closure_idem : ∀ S : Set σ, closure (closure S) ⊆ closure S

/-- Bridge: a family of semiring-valued probes on states, connecting to quantum
observables and Koopman eigenfunctions. -/
structure ProbeFamily (σ : Type u) (K : Type w) [Semiring K] where
  probes : Set (σ → K)

/-- Bridge: a closure-stable probe is an observable invariant under closure expansion,
connecting to Koopman eigenfunctions and quantum coarse-grained observables. -/
def ClosureStableProbe
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (p : σ → K) : Prop :=
  ∀ S : Set σ, ∀ x ∈ M.closure S, ∃ y ∈ S, p x = p y

/-- Bridge: a Koopman-style observable pairs a probe with its spectral weight,
connecting Koopman operator theory to closure automata semantics and
thermodynamic partition functions. -/
structure ThermoKoopmanObservable (σ : Type u) (K : Type w) [Semiring K] where
  observable : σ → K
  spectralWeight : K

/-- Bridge: post-quantum indistinguishability captures the property that no
probe family can distinguish two states, connecting automata quotients to
post-quantum security via observational completeness. -/
def PostQuantumIndistinguishability
-- ... (truncated, full file has 758 lines)
```

@FINAL/Bridges/ActivationNerveMarginCosheaf.lean
```lean
/-
Copyright (c) 2025. All rights reserved.

# Activation-Region Nerve as a Simplicial Complex and Margin-Cosheaf Exactness

This file formalizes the activation-region decomposition of a classifier as a
finite simplicial complex and defines a margin cosheaf on that complex. The
central result is that **degree-1 exactness of the margin cosheaf detects
global consistency of local positive margins**, yielding certified robustness.

## Main results

* `degreeOneExact_iff_uniform_positive_margin` — degree-1 exactness of the
  margin cosheaf on the activation nerve is equivalent to existence of a
  uniform positive global margin on the covered compact domain.

* `activation_nerve_exactness_gives_certified_radius` — from degree-1
  exactness and a Lipschitz bound, derive a positive certified robustness
  radius.

* `finite_cover_glues_positive_margin` — abstract gluing theorem:
  positive local sections compatible on overlaps glue to a global positive
  section.

* `nonexact_produces_margin_gap` — non-exactness implies existence of a
  region or overlap where the margin certificate fails.

## Mathematical overview

Let `R_i` be closed sets forming a finite cover of a compact set `K ⊆ ℝ^d`.
For a continuous margin function, we define the *margin cosheaf* as the
assignment sending each region index `i` to `sInf (margin '' (K ∩ R i))`.

**Degree-1 exactness** is the condition that the local margin lower bounds
are positive on every region and every pairwise overlap. This purely
combinatorial condition (finitely checkable) implies existence of a uniform
positive global margin on all of `K`.

Combined with a Lipschitz bound on the margin function, this yields a
certified robustness radius: perturbations up to `δ / L` cannot change the
classifier's prediction.
-/

import Mathlib

open Set Finset

noncomputable section

namespace ActivationNerveMarginCosheaf

/-! ## Core Definitions -/

/-- An **activation cover** of a compact set `K` by finitely many closed sets.
This models the activation-region decomposition of a ReLU network. -/
structure ActivationCover (ι : Type*) [Fintype ι] (E : Type*) [TopologicalSpace E] where
  /-- The compact domain -/
  K : Set E
  /-- The covering regions (activation regions) -/
  R : ι → Set E
-- ... (truncated, full file has 282 lines)
```

@FINAL/Bridges/Advanced.lean
```lean
/-
Copyright (c) 2025 Homological Transfer Learning Project. All rights reserved.

# Homological Transfer Learning — Advanced Theorems

Bridge: connects Algebra (projective modules, flatness, Tor-vanishing,
resolution theory) to MachineLearning (certified robustness, neural network
depth, domain adaptation, Lipschitz bounds).

## Advanced Results

1. **Multi-Layer Depth Certification**: Resolution depth bounds fine-tuning layers.
2. **Lipschitz Transfer Bounds**: Operator norm gives certified robustness radius.
3. **Lattice-Based Impossibility**: Dimension lattice structure of transfer spaces.
4. **Entropy-Based Transfer Quality**: Information-theoretic interpretation.
5. **Tropical Transfer Valuation**: Tropical semiring structure on transfer errors.
-/

import Mathlib
import Bridges.HomologicalTransferLearning.Core

open LinearMap Submodule Module Function HomologicalTransferLearning

namespace HomologicalTransferLearning.Advanced

/-! ## Section 1: Multi-Layer Transfer Architecture

Bridge: connects chain complexes to deep neural_network architectures
with certified_robustness guarantees. -/

/-- `LayeredTransfer` represents a sequence of transfer maps forming
a multi-layer architecture. Each layer is a linear map between
consecutive feature modules.
Bridge: connects chain complexes to deep neural_network pipelines. -/
structure LayeredTransfer {K : Type*} [Field K] where
  /-- Number of layers -/
  depth : ℕ
  /-- Feature modules at each layer -/
  modules : Fin (depth + 1) → FeatureModule K
  /-- Transfer map at each layer -/
  maps : (i : Fin depth) → TransferMap (modules i.castSucc) (modules i.succ)

/-- The dimension of the source module in a layered transfer. -/
noncomputable def LayeredTransfer.sourceDim {K : Type*} [Field K]
    (L : LayeredTransfer (K := K)) : ℕ :=
  (L.modules ⟨0, Nat.zero_lt_succ _⟩).dim

/-- The dimension of the target module in a layered transfer. -/
noncomputable def LayeredTransfer.targetDim {K : Type*} [Field K]
    (L : LayeredTransfer (K := K)) : ℕ :=
  (L.modules ⟨L.depth, Nat.lt_succ_of_le (le_refl _)⟩).dim

/-- `TransferGap` measures the irreducible distance between two feature
modules — the minimum possible obstruction rank over all transfers.
Bridge: connects Ext¹ rank to certified transfer gap.
This is the algebraic analog of the domain adaptation bound. -/
noncomputable def transferGap {K : Type*} [Field K]
    (M N : FeatureModule K) : ℕ :=
  M.dim - min M.dim N.dim

-- ... (truncated, full file has 397 lines)
```

            ---

            You are Aristotle. Pursue this research direction deeply and originally.
            Discover what matters. Prove what you can. Define what needs defining.
            Build on the catalog theorems referenced above (FINAL/ entries are vetted, high-quality — prioritize these).

            Choose types appropriate to the problem — abstract where it clarifies,
            concrete where it grounds. Avoid trivial tautologies.
            If a direct proof fails, explore alternative approaches: contrapositive,
            constructive witnesses, categorical arguments, coinduction, computational
            reflection, or structural induction.

            ### Anti-Triviality Rules
            Do NOT produce any of the following:
            - Commutativity/associativity proofs for standard algebraic structures
              UNLESS the result is surprising in context (e.g., proving commutativity
              in a non-obvious setting like tropical semirings or quantum groups)
            - Wrapper theorems that just unwrap a definition without mathematical insight
            - Proofs that are just `by simp` or `by trivial` with no depth
            - Definitions followed by trivial properties that don't advance understanding

            Required: Lean 4 proofs, FUTURE_DIRECTIONS.md, RESEARCH_PAPER.md,
                      ARTICLE.md (Scientific American style), algorithm, demo.py,
                      1–3 interactive HTML widgets in PACKAGE.json interactive_demos (each: name, html, description)
            Optional: (none — all key deliverables are mandatory)

            ## Taboo Topics for ARTICLE.md

            The Scientific American-style article MUST NOT focus on formal verification
            or machine verification. Do not write about proof assistants, type theory
            as verification, or mechanized checking — those topics are technical niche
            and alienate a broad audience. Instead, write about the IDEAS: what was
            discovered, why it matters, and what it means for mathematics and science.
            The article should read like a Scientific American feature, not a software
            demo or verification report.

            ## Catalog Context for Future Directions
            Below are key theorems from the Catalog for lineage references.
            Use the **Catalog References** field to cite the exact file paths.

            ### Key Theorems Available
            **Algebra**:
  `Algebra/Advanced.lean`: iterateB, iterateB_one, iterateB_two
  `Algebra/Agent.lean`: euclid_inradius_num, euclid_perimeter, euclid_twice_area
  `Algebra/Berggren.lean`: applyB₁, A_iter, A_closed
**Bridges**:
  `Bridges/Agent.lean`: euclid_inradius_num, euclid_perimeter, euclid_twice_area
  `Bridges/AlgebraEMLClosureComputation.lean`: ClosureSemimoduleSystem, ProbeFamily, ClosureStableProbe
  `Bridges/AlgebraEMLPhysics/FilteredClosureReconstruction.lean`: FilteredClosureSystem, scaleDefect, absorption_yields_monotone_profile
**Computation**:
  `Computation/GravityOracle.lean`: IsGravOracle, GravTruthSet, geodesic_oracle_idempotent
  `Computation/InfoEfficientAlgorithms.lean`: InfoEfficientAlgorithm, InfoEfficientAlgorithm.terminates_within_potential, BSState
  `Computation/PadicValuationDepth.lean`: ValuationDepthMeasure, vdepth_const_eq_zero, vdepth_sum_le
**Cryptography**:
  `Cryptography/BerggrenDiophantineLattice.lean`: lorentzForm, euclidNormSq, IsPythagoreanVec
  `Cryptography/BerggrenFingerprintRigidity.lean`: berggrenGen, evalWord, rootTriple
  `Cryptography/BerggrenGroupoidOrbit.lean`: berggrenA, berggrenB, berggrenC
**EML**:
  `EML/AdvancedTheory.lean`: ensembleComplexity, ensemble_complexity_additive, uniform_ensemble_complexity
  `EML/EMLv17Core.lean`: eml, emlDiag, sigmaEml
  `EML/KolmogorovArnoldEMLDeep.lean`: EMLChainOp.eval, evalChain, chainDepth

            FUTURE_DIRECTIONS.md MUST be a standalone research roadmap. It will be
            used to steer future research rounds WITHOUT access to this cycle's code.
            Each direction must be self-contained: include enough mathematical context,
            definitions, and motivation that a fresh researcher can pick up any
            direction and start working on it immediately. Do NOT assume the reader
            has seen your Lean code.

            FUTURE_DIRECTIONS.md is critical — it drives the next research cycle.
            Begin with a ## Synthesis section tying all directions together and
            identifying the most promising cross-domain connections from this cycle.
            Then list 3-5 directions (1-2 grand_challenge + 2-3 extension) using:

            ## Synthesis

            [2-3 paragraphs tying all directions together. Identify the most promising
            cross-domain connection from this cycle's discoveries. Explain how the
            cycle's results relate to the broader Catalog. Highlight which direction
            has the highest breakthrough potential and why.]

            ---

            ### Direction 1: [Title]

            Titles MUST be concise research topics (e.g. "Tropical Fermat
            Last Theorem", "Oracle Hierarchy in Computability"), NOT cycle
            summaries (NOT "This research cycle established...").

            **Conjecture**: A precise mathematical statement that can be proved or disproved.
            **Test**: What specific experiment, calculation, or proof attempt would confirm
            or refute this conjecture.
            **Impact**: If true, what new territory does this open? If false, what does
            the failure teach us?
            **Catalog References**: `Bridges.Basic.lean`, `Algebra.QuadraticForms.mordell`
            (Use backtick-enclosed file paths or theorem names from the Catalog.)
            **Proof Strategy**: Outline the key steps or approach. What mathematical
            machinery is needed? What lemmas would need to be established first?
            **Domain Bridges**: (identify genuine cross-domain connections from
            this cycle's results, using the <-> connector.)
            **Lineage**: Builds on fd_XXXX and discoveries from exp_XXXXXXXX_XXX
            (Reference specific prior direction IDs or experiment IDs if known, or
            describe which prior results this extends.)
            **Ambition**: grand_challenge  (or: extension)

            ---

            [repeat for each direction]

            Do real science. Propose hypotheses that are bold enough to matter and
            specific enough to fail. Vague explorations like "study X further" or
            "extend Y" are not hypotheses — they are homework. Give us ideas that
            could change how we think about the problem.

            Pursue truth relentlessly. Soli Deo Gloria.


### Deliverables

You are a world-class mathematician, software engineer, and science writer.
We need ALL of the following:

1. **Lean 4 proofs** — Non-trivial theorems with complete proofs (no `sorry`).
   Organize as makes sense. Use doc comments for key results.

2. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or proof assistants.
   Vivid prose, narrative arc, real-world connections. Must make sense standalone.

3. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results with proof sketches, algorithms, applications,
   discussion, future work, references.

4. **Python code** — demo.py (numerical examples), algorithms.py (type-hinted implementations),
   and up to 3 self-contained visualization scripts (matplotlib/plotly, each a single file
   with all functions inlined — no local imports).

5. **FUTURE_DIRECTIONS.md** (MOST IMPORTANT — drives next cycle).
   Begin with ## Synthesis tying all directions together. Then 3-5 directions using:
   **Conjecture**, **Test**, **Impact**, **Catalog References**, **Proof Strategy**,
   **Domain Bridges**, **Lineage**, **Ambition** (grand_challenge or extension).
   Each direction must be self-contained and specific enough to fail.

6. **PACKAGE.json** — Single JSON bundling all artifacts:
   title, domain, article, research_paper, future_directions, demos, algorithms,
   visualizations, interactive_demos, lean_proofs. JSON-escape all content.

   **interactive_demos** (MANDATORY — include at least 1): Array of objects, each with:
   - `name`: short title
   - `html`: self-contained HTML+CSS+JS snippet (inline styles, no external JS files,
     no local imports, CDN links OK for d3/plotly). Must render an interactive widget
     (slider, button, animation, etc.) that demonstrates a key result visually.
     Wrap in a `<div>` with inline styles. Use vanilla JS — no frameworks.
   - `description`: one-sentence summary

   **visualizations**: Array of objects with `name`, `code` (standalone Python script
   using matplotlib or plotly, all functions inlined), `description`.

   **algorithms**: Array of objects with `name`, `pseudocode` (brief), `code` (Python).

Research domain: Bridges
Research mode: sorry_fill
