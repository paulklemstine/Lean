            Soli Deo Gloria

            ## Assignment: Non-Abelian Plünnecke-Ruzsa via Covering Calculus

            Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

            ## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`,
   `norm_num`, or `rfl` unless the statement itself is genuinely important.
   If the only proof tactic is enumeration, the theorem is not worth formalizing.

2. **At least 3 theorems with deep proof tactics**: Your file must contain at
   least 3 theorems proven using induction, rcases, by_contra, field_simp,
   or multi-step calc reasoning.

3. **Novel definitions**: Define at least one new mathematical structure or concept
   that does not already exist in the Catalog. Check the catalog references to
   confirm novelty.

4. **Cross-domain connections**: Include at least one theorem that connects your
   domain to a different mathematical domain (e.g., number theory + tropical
   geometry, algebra + physics).

5. **Conjecture with testable prediction**: State at least one falsifiable
   conjecture with a clear computational test that could disprove it.


            ### Research Direction
            Conjecture: For a K-approximate subgroup H in any group G, for all n ≥ 1: H^n can be covered by K^(n-1) left translates of H. (Generalization of the triple product cover K² bound from n=3 to all n.)

Test: Verify computationally for n = 4, 5, 6 in S₃, S₄, and GL(2, F₃). Check whether the inductive step H^n → H^(n+1) preserves the K^(n-1) bound.

Impact: This would be a covering-theoretic analog of the Plünnecke-Ruzsa inequality. The standard Plünnecke-Ruzsa gives |H^n| ≤ K^n·|H|; our version gives covering number K^(n-1), which is sharper (it doesn't multiply by |H|).

            ### Mathematical Framing
            Conjecture: For a K-approximate subgroup H in any group G, for all n ≥ 1: H^n can be covered by K^(n-1) left translates of H. (Generalization of the triple product cover K² bound from n=3 to all n.)

Test: Verify computationally for n = 4, 5, 6 in S₃, S₄, and GL(2, F₃). Check whether the inductive step H^n → H^(n+1) preserves the K^(n-1) bound.

Impact: This would be a covering-theoretic analog of the Plünnecke-Ruzsa inequality. The standard Plünnecke-Ruzsa gives |H^n| ≤ K^n·|H|; our version gives covering number K^(n-1), which is sharper (it doesn't multiply by |H|).


            ### Existing Verified Theorems
            Existing theorems you can build on:
  1. `triple_channel_left_product` : theorem triple_channel_left_product (a b c d : ℤ)
     (file: Pythagorean/TreeFactoring/NewTheorems.lean)
  2. `triangle_lower_bound_from_sandwich` : theorem triangle_lower_bound_from_sandwich (n : ℕ)
     (file: FINAL/Pythagorean/AsymptoticCompactness.lean)
  3. `berggren_ca_triple_entry_bound` : theorem berggren_ca_triple_entry_bound (prog : TCProgram) (n₁ n₂ t : ℕ)
     (file: FINAL/Pythagorean/BerggrenCA.lean)
  4. `berggren_ca_triple_entry_bound` : theorem berggren_ca_triple_entry_bound :
     (file: FINAL/Pythagorean/BerggrenUniformExpansion.lean)
  5. `bounded_cover_implies_product_cover` : theorem bounded_cover_implies_product_cover {G : Type*} [CommGroup G]
     (file: FINAL/Pythagorean/BoundedPseudofiniteTransfer.lean)
  6. `fidelity_bound_from_perturbation` : theorem fidelity_bound_from_perturbation {α : Type*} [Fintype α]
     (file: FINAL/Pythagorean/RobustCertificateCompilation.lean)
  7. `log_bound_implies_conjecture` : theorem log_bound_implies_conjecture
     (file: FINAL/Pythagorean/SemidirectUniversality.lean)
  8. `exp_step_bound_pulled_back` : theorem exp_step_bound_pulled_back (n : ℕ) (D C : ℝ) (hD : D < 1) (hC : 0 < C) :
     (file: FINAL/Pythagorean/Separation.lean)
  9. `covering_card_lower_bound` : theorem covering_card_lower_bound {α : Type*} [DecidableEq α]
     (file: FINAL/Pythagorean/SupportRigidityCircuitBounds.lean)
  10. `triangle_lower_bound_from_sandwich` : theorem triangle_lower_bound_from_sandwich (n : ℕ)
     (file: Pythagorean/AsymptoticCompactness.lean)
  11. `berggren_ca_triple_entry_bound` : theorem berggren_ca_triple_entry_bound (prog : TCProgram) (n₁ n₂ t : ℕ)
     (file: Pythagorean/BerggrenCA.lean)
  12. `berggren_ca_triple_entry_bound` : theorem berggren_ca_triple_entry_bound :
     (file: Pythagorean/BerggrenUniformExpansion.lean)
  13. `bounded_cover_implies_product_cover` : theorem bounded_cover_implies_product_cover {G : Type*} [CommGroup G]
     (file: Pythagorean/BoundedPseudofiniteTransfer.lean)
  14. `irrep_count_from_dim_bound` : theorem irrep_count_from_dim_bound
     (file: Pythagorean/G2CharacterSheafCertificate.lean)
  15. `exp_step_bound_pulled_back` : theorem exp_step_bound_pulled_back (n : ℕ) (D C : ℝ) (hD : D < 1) (hC : 0 < C) :
     (file: Pythagorean/HardyHierarchy/Separation.lean)

### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


### Catalog Reference Files (Catalog/FINAL/ = vetted, high-quality)

(File paths starting with FINAL/ are vetted, high-quality catalog entries.)
@FINAL/Pythagorean/AbelianizationTorsion.lean
```lean
/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Non-Abelian Arithmetic Phase Classification:
# Abelianization Torsion Completeness and Its Failure

This file establishes the fundamental relationship between abelianization and
torsion detection for finite groups. The central results are:

1. **Completeness at degree 1**: The abelianization G^ab determines the p-torsion
   profile of G at degree 1 (i.e., H₁(G, ℤ/pℤ) depends only on G^ab).

2. **Incompleteness at degree 2**: The quaternion group Q₈ and the Klein four-group
   V₄ provide a concrete counterexample — they have isomorphic abelianizations but
   different higher torsion structure (Schur multipliers).

3. **Structural results**: Abelianization preserves and reflects p-torsion existence,
   providing a functorial "first approximation" to the torsion character of any
   finite group.

## Catalog References

Extends `HasPTorsion_ZMod_iff_dvd` and `torsionProfileUpTo_prod` from
`Catalog/Algebra/TorsionDetection.lean` from abelian to non-abelian groups.

## Main Definitions

* `HasPTorsionMul` — multiplicative p-torsion predicate
* `GroupHasPTorsion` — a group has p-torsion
* `pTorsionSet` — the set of elements killed by p-th power
* `AbelianizationHasPTorsion` — torsion profile derived from abelianization
* `TorsionCompleteAtDeg1` — abelianization captures all degree-1 torsion
* `derivedTorsionProfileDeg1` — count of p-torsion elements in G^ab
* `KleinFour` — the Klein four-group V₄

## Main Results

* `abelianization_of_surjective` — the canonical map G → G^ab is surjective
* `abelianization_torsion_transfer` — isomorphic abelianizations ⟹ same torsion
* `comm_group_abelianization_torsion_complete` — for abelian groups, G^ab captures all
* `product_pTorsion_iff` — torsion in products decomposes
* `grand_classification_summary` — the full degree-1 classification theorem
* `q8_card` / `v4_card` — cardinalities of Q₈ and V₄
* `q8_not_comm` — Q₈ is non-abelian
* `v4_comm` — V₄ is abelian
-/
import Mathlib

open scoped Pointwise

/-! ## Section 1: Core Definitions for Multiplicative Torsion -/

/-- The **Klein four-group** V₄ = ℤ/2ℤ × ℤ/2ℤ, viewed as a multiplicative group. -/
abbrev KleinFour : Type := Multiplicative (ZMod 2 × ZMod 2)

/-- A group element `g` has **multiplicative p-torsion** if `g^p = 1` and `g ≠ 1`. -/
def HasPTorsionMul {G : Type*} [Group G] (g : G) (p : ℕ) : Prop :=
  g ≠ 1 ∧ g ^ p = 1

-- ... (truncated, full file has 387 lines)
```

@FINAL/Pythagorean/AdaptiveOverlapRounding.lean
```lean
/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Overlap-Adaptive Rounding for Hypergraph Transversals

This file develops the theory of **data-driven rounding for bounded-overlap
hypergraph transversals**, where the algorithm extracts an effective overlap
parameter from the LP optimum itself rather than receiving it as external input.

## Central Idea

The classical bounded-codegree story says: if a `d`-uniform hypergraph has
pairwise overlap at most `K`, threshold rounding at `1/d` gives a
`d`-approximation. But `K` is often unknown. The key insight is that the
**pair-overlap energy** of the fractional optimum acts as a self-calibrating
diagnostic that detects latent overlap structure, yielding instance-sensitive
approximation guarantees without external structural parameters.

## Main Definitions

* `HG` — a hypergraph as a finite set of finite sets
* `PairCodegree` — number of edges containing both vertices u and v (0 on diagonal)
* `PairCodegreeBounded` — all pair codegrees bounded by K
* `PairOverlapEnergy` — the pair-overlap energy functional
* `EdgeSquareEnergy` — sum of squared edge masses
* `FractionalMass` — total LP mass Σ x(v)
* `EffectiveOverlap` — normalized energy diagnostic ρ = E/M²
* `ThresholdSet` — threshold rounding operator

## Main Results

* `pairOverlapEnergy_le_of_codegree_bounded` — energy ≤ K · M² under codegree bound
* `effectiveOverlap_le_of_codegree_bounded` — diagnostic ≤ K under codegree bound
* `edgeSquareEnergy_ge_card` — edge-square energy ≥ |E| for fractional transversals
* `thresholdSet_isTransversal` — threshold rounding at 1/d produces a valid transversal
* `thresholdSet_card_le` — cardinality bound for threshold set
* `adaptive_rounding_with_certificate` — combined adaptive guarantee
* `low_energy_integrality_gap` — low energy certifies small integrality gap

## Cross-Domain Connections

* **Operations Research**: instance-sensitive certificates for set cover difficulty
* **Statistical Physics**: energy as two-body interaction Hamiltonian;
  low interaction energy ↔ efficient deterministic rounding
* **Algorithm Selection**: LP diagnostic predicts algorithmic performance

## Conjectures (stated informally)

**Smooth adaptive improvement law**: There exists c > 0 such that for every
d-uniform hypergraph and optimal fractional transversal x*,
  τ_ad(H; x*) ≤ (d - c/(1 + ρ_H(x*))) · τ*(H) + O(1 + ρ_H(x*)).

**Monotone diagnostic-performance principle**: Among random d-uniform instances
with fixed |V|, |E|, the approximation ratio of adaptive rounding is
stochastically nonincreasing as ρ_H(x*) decreases.
-/
-- ... (truncated, full file has 295 lines)
```

@FINAL/Pythagorean/AdelicPersistentHomology.lean
```lean
/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Adelic Persistent Homology

This file formalizes the theory of **adelic torsion persistence** for filtered finite
abelian groups. The central insight is that the torsion barcode of a filtered
finite abelian group decomposes canonically by prime, and this decomposition admits
an adelic packaging with reconstruction and uniqueness properties.

## Main definitions

* `IsPPrimary` — An element is p-primary if killed by some power of p
* `pPrimaryComponent` — The p-primary subgroup
* `pPrimaryNontrivial` — The p-primary component is nontrivial
* `torsionPrimeSupportSet` — Primes with nontrivial p-primary part
* `AdelicTorsionDatum` — Adelic packaging of prime-indexed persistence data
* `reconstructTorsionSupport` — Recovers global support from adelic data
* `adelicTorsionDatum` — The canonical adelic datum for a filtration
* `nTorsionSubgroup` — The n-torsion subgroup {a | n • a = 0}

## Main results

* `map_preserves_pPrimary` — Homomorphisms preserve p-primary torsion (Thm 1)
* `adelic_reconstruction_correct_set` — Adelic reconstruction is exact (Thm 2)
* `adelic_reconstruction_unique` — Reconstruction is unique on supports (Thm 2b)
* `bounded_torsion_implies_bounded_primeSupport` — Bounded torsion → bounded support (Thm 3)
* `persistence_CRT_decomposition` — CRT splitting of torsion persistence (Thm 4)

## References

* Builds on `Catalog.Algebra.Homology.DerivedFunctors.TorsionDetection`
* Builds on `Catalog.Pythagorean.ArithmeticPhaseClassification`
-/

import Mathlib

set_option maxHeartbeats 800000

open scoped Classical

/-! ## Section 1: p-Primary Torsion Components -/

/-- An element `a` of an additive abelian group is **p-primary** if
`p^k • a = 0` for some natural number `k`. -/
def IsPPrimary (p : ℕ) {A : Type*} [AddCommGroup A] (a : A) : Prop :=
  ∃ k : ℕ, (p ^ k) • a = 0

/-- The **p-primary component** of an additive abelian group:
the subgroup of all elements killed by some power of `p`. -/
def pPrimaryComponent (p : ℕ) (A : Type*) [AddCommGroup A] : AddSubgroup A where
  carrier := {a | IsPPrimary p a}
  zero_mem' := ⟨0, by simp⟩
  add_mem' := by
    rintro a b ⟨ka, hka⟩ ⟨kb, hkb⟩
    refine ⟨ka + kb, ?_⟩
    have h1 : (p ^ (ka + kb)) • a = 0 := by
      have : p ^ (ka + kb) = p ^ kb * p ^ ka := by ring
      rw [this, mul_smul, hka, smul_zero]
-- ... (truncated, full file has 424 lines)
```

@FINAL/Pythagorean/AdvancedFactoringResearch.lean
```lean
import Mathlib

/-! # CatalogBuild.Pythagorean.Core.AdvancedFactoringResearch

Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 35
-/

/-- Primary channel: removing component d from a quintuplet. -/
theorem cascade_channel_d (a b c d N : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = N ^ 2) :
    (N - d) * (N + d) = a ^ 2 + b ^ 2 + c ^ 2 := by nlinarith

/-- Primary channel: removing component c -/
theorem cascade_channel_c (a b c d N : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = N ^ 2) :
    (N - c) * (N + c) = a ^ 2 + b ^ 2 + d ^ 2 := by nlinarith

/-- Primary channel: removing component b -/
theorem cascade_channel_b (a b c d N : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = N ^ 2) :
    (N - b) * (N + b) = a ^ 2 + c ^ 2 + d ^ 2 := by nlinarith

/-- Primary channel: removing component a -/
theorem cascade_channel_a (a b c d N : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = N ^ 2) :
    (N - a) * (N + a) = b ^ 2 + c ^ 2 + d ^ 2 := by nlinarith

/-- Pairwise channel: a² - b² = (a-b)(a+b) -/
theorem pairwise_ab (a b : ℤ) :
    a ^ 2 - b ^ 2 = (a - b) * (a + b) := by ring

/-- Pairwise channel cd: removing both c and d simultaneously -/
theorem pairwise_cd (a b c d N : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = N ^ 2) :
    (N - c) * (N + c) - d ^ 2 = a ^ 2 + b ^ 2 := by nlinarith

/-- **The Full Cascade**: All four primary channels from a quintuplet. -/
theorem full_cascade (a b c d N : ℤ) (h : a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = N ^ 2) :
    ((N - a) * (N + a) = b ^ 2 + c ^ 2 + d ^ 2) ∧
    ((N - b) * (N + b) = a ^ 2 + c ^ 2 + d ^ 2) ∧
    ((N - c) * (N + c) = a ^ 2 + b ^ 2 + d ^ 2) ∧
    ((N - d) * (N + d) = a ^ 2 + b ^ 2 + c ^ 2) := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> nlinarith

/-- The R₁₁₁₁ reflection applied to a lifted triple (a,b,0,c). -/
def liftAndReflect (a b c : ℤ) : ℤ × ℤ × ℤ × ℤ :=
  (c - b, c - a, c - a - b, 2*c - a - b)

/-- **Complementarity Theorem**: The lifted-reflected first component (c-b)
is algebraically independent from the Berggren parent first component (a+2b-2c). -/
theorem complementary_channels (a b c : ℤ) :
    (liftAndReflect a b c).1 = c - b ∧
    (berggrenParent a b c).1 = a + 2*b - 2*c := by
  simp [liftAndReflect, berggrenParent]

/-- The lifted-reflected quadruple preserves the Pythagorean equation. -/
theorem liftReflect_preserves (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (c - b) ^ 2 + (c - a) ^ 2 + (c - a - b) ^ 2 = (2*c - a - b) ^ 2 := by
-- ... (truncated, full file has 215 lines)
```

            ---

            You are Aristotle. Pursue this research direction deeply and originally.
            Discover what matters. Prove what you can. Define what needs defining.
            Build on the catalog theorems referenced above (FINAL/ entries are vetted, high-quality — prioritize these).

            Use concrete types (Nat, Real, Finset, Matrix). Avoid trivial tautologies.
            If a direct proof fails, try the contrapositive, a constructive witness,
            or structural induction. Connect to at least one other domain for impact.

            ### Team Directive
            You are not a lone researcher — you are LEADING a research science team.
            Organize your team into roles:

            1. **Hypothesis Team**: Brainstorm 3-5 bold, falsifiable hypotheses.
               Each must be a precise conjecture that can be proved or disproved.
            2. **Experiment Team**: Design and run Lean 4 experiments to test each
               hypothesis. Prove theorems, find counterexamples, compute examples.
            3. **Analysis Team**: Examine results. Which hypotheses survived? Which
               failed? What does each failure teach? Update the knowledge base.
            4. **Iteration Lead**: Based on analysis, propose the NEXT round of
               hypotheses. Science is a loop: hypothesize → experiment → analyze →
               repeat. Each cycle must advance the frontier.

            The team operates as a self-improving science engine. Each round builds
            on the last. Failed hypotheses are as valuable as successful ones — they
            constrain the search space and reveal structure.

            Required: Lean 4 proofs, FUTURE_DIRECTIONS.md, RESEARCH_PAPER.md,
                      ARTICLE.md (Scientific American style), algorithm, demo.py
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
            Below is information about the current state of the Catalog. Reference
            specific theorems by their Catalog file paths when writing FUTURE_DIRECTIONS.md.
            Use the **Catalog References** field to cite the exact file paths.

            ### Catalog Breakthrough Analysis
            ## Catalog Breakthrough Analysis

### Under-Explored Domains (many declarations, few deep results)
- Algebra: 13064 declarations, 0 sorries, exploration ratio 13064.0 (HIGH potential)
- MachineLearning: 9232 declarations, 1 sorries, exploration ratio 9232.0 (HIGH potential)
- EML: 5561 declarations, 0 sorries, exploration ratio 5561.0 (HIGH potential)
- Computation: 3610 declarations, 0 sorries, exploration ratio 3610.0 (HIGH potential)
- Logic: 3401 declarations, 0 sorries, exploration ratio 3401.0 (HIGH potential)

### Structural Opportunities (shared structures, no bridge)
- Algebra <-> MachineLearning: Both Algebra and MachineLearning use category, field, functor, group, hilbert, lattice, manifold, measure, metric, metricspace, module, monoid, norm, normed, normedspace, order, ring, semiring, topological, topologicalspace, topology, tropical but no bridge exists between them
- Algebra <-> EML: Both Algebra and EML use category, field, group, hilbert, lattice, manifold, measure, metric, metricspace, module, monoid, norm, normed, normedspace, order, ring, semiring, topological, topologicalspace, topology, tropical but no bridge exists between them
- EML <-> MachineLearning: Both EML and MachineLearning use category, field, group, hilbert, lattice, manifold, measure, metric, metricspace, module, monoid, norm, normed, normedspace, order, ring, semiring, topological, topologicalspace, topology, tropical but no bridge exists between them
- Algebra <-> Tropical: Both Algebra and

            ### Key Theorems Available (for lineage references)
            **Algebra**:
  `Algebra/Advanced.lean`: iterateB, iterateB_one, iterateB_two
  `Algebra/Agent.lean`: euclid_inradius_num, euclid_perimeter, euclid_twice_area
  `Algebra/Berggren.lean`: applyB₁, A_iter, A_closed
**Bridges**:
  `Bridges/AlgebraEMLClosureComputation.lean`: ClosureSemimoduleSystem, ProbeFamily, ClosureStableProbe
  `Bridges/AlgebraEMLReconstruction.lean`: SetClosureOperator, {α, ClosedSet
  `Bridges/AlgebraPythagoreanCryptography/BerggrenLatticeReductionDuality.lean`: PrimTriple, PrimTriple.a_lt_c, PrimTriple.b_lt_c
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
  `EML/ModularForms.lean`: T_sq, S_gen, BM₃_inv

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

            **Conjecture**: A precise mathematical statement that can be proved or disproved.
            **Test**: What specific experiment, calculation, or proof attempt would confirm
            or refute this conjecture.
            **Impact**: If true, what new territory does this open? If false, what does
            the failure teach us?
            **Catalog References**: `Bridges.Basic.lean`, `Algebra.QuadraticForms.mordell`
            (Use backtick-enclosed file paths or theorem names from the Catalog.)
            **Proof Strategy**: Outline the key steps or approach. What mathematical
            machinery is needed? What lemmas would need to be established first?
            **Domain Bridges**: NumberTheory <-> Tropical, Algebra <-> Physics
            (List domain pairs this connects, using the <-> connector.)
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

            Soli Deo Gloria.


### WHAT WE NEED FROM YOU

You are a world-class mathematician, software engineer, and science writer.
Use your judgment on the best way to organize and present your work.
We need ALL of the following deliverables:

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 1 — Formally verified mathematics (Lean 4)
────────────────────────────────────────────────────────────────────────────
- Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
- Organize the code however makes sense — one file or several,
  whatever serves the mathematics best
- Use doc comments to explain the significance of key results

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 2 — Standalone Popular-Science ARTICLE  →  ARTICLE.md
────────────────────────────────────────────────────────────────────────────
Write a **superb, standalone magazine-quality article** about this research.

CRITICAL RULES FOR THE ARTICLE:
• Do NOT mention "Scientific American", "Sci Am", or "Lean" anywhere.
• Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
• This is a POPULAR SCIENCE article for a curious, intelligent audience.
  Write it as if it will be published in a premier science magazine.
• The reader should come away saying "Wow, I had no idea math could do THAT."

ARTICLE QUALITY STANDARDS:
• **Superb writing**: Vivid, engaging prose. Strong opening hook. Narrative arc.
  Use concrete analogies and metaphors that make abstract ideas tangible.
• **Depth without jargon**: Explain the IDEAS, not the formalism.
  A reader with a college education should understand and enjoy every paragraph.
• **Story structure**: Open with a provocative question or surprising fact.
  Build tension. Reveal the breakthrough. Show why it matters.
• **Real-world connections**: Connect to technology, nature, everyday life.
  Why should a non-mathematician care about this?
• **Historical context**: Place the discovery in the sweep of intellectual history.
  Who tried this before? What barriers stood in the way?
• **Length**: 1500–3000 words. Substantial but not padded.
• **Standalone**: The article must make complete sense on its own.
  No references to "the proof above" or "our formal verification."

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 3 — Comprehensive RESEARCH PAPER  →  RESEARCH_PAPER.md
────────────────────────────────────────────────────────────────────────────
Write a **thorough, in-depth research paper** that a mathematician or
graduate student would find valuable. This is NOT a summary — it is a
complete, publishable-quality paper.

RESEARCH PAPER REQUIREMENTS:
• **Abstract**: Concise summary of contributions and significance.
• **Introduction**: Motivation, context, relationship to prior work.
• **Definitions & Notation**: Precise mathematical setup.
• **Main Results**: Full theorem statements with detailed proof sketches.
  Include the key ideas, not just "by induction."
• **Algorithms**: If the work produces algorithms, include complete
  pseudocode with complexity analysis (time, space, convergence).
• **Applications**: Concrete applications with worked examples.
  Show HOW to use the results in practice.
• **Computational Experiments**: Reference the Python demos.
  Include tables, charts, or numerical results.
• **Discussion**: Implications, limitations, open questions.
• **Future Work**: Specific, actionable next steps.
• **References**: Cite relevant prior work properly.
• **Length**: 3000–8000 words. Comprehensive and substantive.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 4 — Python Code: Demos, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  Show the math working.
- **Visualization scripts** — Produce up to 3 self-contained Python scripts
  that visually illustrate the core mathematical concepts discovered. Use
  matplotlib for static plots (heatmaps, curves, surfaces) or plotly for
  interactive charts. Available libraries: numpy, matplotlib, plotly.
  If using matplotlib, the script must call plt.savefig() — the system
  captures the output as a PNG. If using plotly, assign the figure to a
  variable named `fig` — the system captures fig.to_html(). Each script
  must include a comment header explaining what it visualizes and why.
  **CRITICAL: Each visualization script MUST be a single, fully self-contained
  file. Do NOT import from any local modules (algorithms.py, demo.py, etc.).
  Instead, inline all needed functions and classes directly in the script.
  The browser runtime (Pyodide) has no access to local .py files.**
- **Interactive HTML demos** — Produce up to 3 self-contained HTML snippets
  (with inline CSS/JS, no external dependencies) that demonstrate the
  mathematical concepts interactively — sliders, animations, dynamic SVG,
  or canvas drawing. Each demo must be a complete <div> fragment that
  works when inserted into a page. No <html>, <head>, or <body> tags —
  just the content div with its inline styles and scripts.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Every research cycle MUST produce a
FUTURE_DIRECTIONS.md that identifies 3-5 specific, testable scientific
hypotheses, including 1-2 grand_challenge paradigm-shifting conjectures
and 2-3 solid extensions building directly on Catalog theorems.
MUST begin with a ## Synthesis section tying all directions together.
Each direction must use the structured format with explicit fields:
**Conjecture**, **Test**, **Impact**, **Catalog References**,
**Proof Strategy**, **Domain Bridges**, **Lineage**, **Ambition**.
Reference specific Catalog theorems by file path. Every hypothesis
must be daring enough to matter and specific enough to fail.


────────────────────────────────────────────────────────────────────────────
DELIVERABLE 6 — JSON Data Package  →  PACKAGE.json
────────────────────────────────────────────────────────────────────────────
Create a **single JSON file** that bundles ALL artifacts for the web templating system.
Requirements:

• **Structure**: Output a strictly valid JSON object matching this schema:
  {
    "title": "Title of the Research",
    "domain": "Mathematical Domain",
    "article": "Markdown content...",
    "research_paper": "Markdown content...",
    "future_directions": "Markdown content...",
    "demos": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files like 'algorithms'" } ],
    "algorithms": [ { "name": "...", "pseudocode": "...", "code": "executable Python implementation" } ],
    "visualizations": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files. Inline all needed functions directly.", "description": "What this visualizes" } ],
    "interactive_demos": [ { "name": "...", "html": "<div>...</div>", "description": "What this demonstrates" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Pythagorean
Research mode: prove
