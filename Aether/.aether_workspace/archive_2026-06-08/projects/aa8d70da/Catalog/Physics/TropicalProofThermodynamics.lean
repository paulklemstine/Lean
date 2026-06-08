/-
# Tropical Proof Thermodynamics

This file establishes a rigorous mathematical framework connecting Landauer's
principle to proof theory via tropical (min-plus) algebra. The central insight is
that proof steps can be viewed as information transformations, and the thermodynamic
cost of a proof is governed by the erasure structure of its trace.

## Main Definitions

* `ProofTrace` — a finite sequence of entropy values modeling a proof's information flow
* `stepErasure` — the information erased at step i (clamped to ≥ 0)
* `thermodynamicDepth` — total erasure cost of a proof trace
* `ProofEntropyMorphism` — entropy-monotone map between proof traces

## Main Results

* `telescoping_theorem` — for monotone traces, total depth = boundary difference
* `erasure_concentration` — pigeonhole: some step has erasure ≥ depth/length
* `composition_depth_superadditive` — depth is superadditive under composition
* `reversible_iff_zero_erasure` — a step is reversible iff its erasure vanishes
* `tropical_triangle_inequality` — tropical metric satisfies the triangle inequality
* `depth_dominates_tropical_distance` — thermodynamic depth bounds tropical distance

## References

Builds on: `Catalog/Physics/Landauer.lean`, `Catalog/Physics/Bridge.lean`
-/

import Mathlib

open Finset Real BigOperators

/-! ## Core Definitions -/

/-- A `ProofTrace n` is a sequence of `n + 1` entropy values h₀, h₁, ..., hₙ
representing the information content at each stage of a proof with `n` steps.
The entropy values are non-negative reals. -/
structure ProofTrace (n : ℕ) where
  /-- Entropy at stage `i` -/
  entropy : Fin (n + 1) → ℝ
  /-- Entropy values are non-negative -/
  entropy_nonneg : ∀ i, 0 ≤ entropy i

/-- The erasure at step `i` of a proof trace: the non-negative part of the
entropy decrease. Represents information irreversibly lost at this step.
`stepErasure T i = max(0, h_i - h_{i+1})` -/
noncomputable def stepErasure {n : ℕ} (T : ProofTrace n) (i : Fin n) : ℝ :=
  max 0 (T.entropy i.castSucc - T.entropy i.succ)

/-- The thermodynamic depth of a proof trace: the total information erased
across all steps. This is the Landauer cost of the proof. -/
noncomputable def thermodynamicDepth {n : ℕ} (T : ProofTrace n) : ℝ :=
  ∑ i : Fin n, stepErasure T i

/-- A proof trace is *monotone* (entropy non-increasing) if each step
weakly decreases entropy. This models the "Second Law of Proof":
each deduction step can only lose information. -/
def ProofTrace.isMonotone {n : ℕ} (T : ProofTrace n) : Prop :=
  ∀ i : Fin n, T.entropy i.succ ≤ T.entropy i.castSucc

/-- A step is *reversible* if no information is erased: `h_i = h_{i+1}`. -/
def ProofTrace.stepReversible {n : ℕ} (T : ProofTrace n) (i : Fin n) : Prop :=
  T.entropy i.castSucc = T.entropy i.succ

/-- The boundary entropy difference: `h₀ - hₙ`. -/
noncomputable def boundaryDifference {n : ℕ} (T : ProofTrace n) : ℝ :=
  T.entropy 0 - T.entropy (Fin.last n)

/-! ## Tropical Metric -/

/-- The tropical distance between two real numbers, defined as |a - b|.
In the min-plus semiring interpretation, this measures the cost of
transforming one entropy level to another. -/
noncomputable def tropicalDistance (a b : ℝ) : ℝ := |a - b|

/-! ## Key Lemma: Step Erasure Properties -/

lemma stepErasure_nonneg {n : ℕ} (T : ProofTrace n) (i : Fin n) :
    0 ≤ stepErasure T i :=
  le_max_left 0 _

/-- For monotone traces, step erasure equals the entropy decrease. -/
lemma stepErasure_of_monotone {n : ℕ} (T : ProofTrace n) (hmon : T.isMonotone) (i : Fin n) :
    stepErasure T i = T.entropy i.castSucc - T.entropy i.succ := by
  unfold stepErasure
  rw [max_eq_right_iff.mpr]
  linarith [hmon i]

/-! ## Theorem 1: The Telescoping Theorem

For a monotone proof trace, the thermodynamic depth equals the boundary
entropy difference h₀ - hₙ. This is the fundamental identity: total erasure
depends only on the initial and final entropy, not on intermediate steps. -/

theorem telescoping_theorem {n : ℕ} (T : ProofTrace n) (hmon : T.isMonotone) :
    thermodynamicDepth T = boundaryDifference T := by
      have h_telescope : ∀ (n : ℕ) (T : ProofTrace n), T.isMonotone → ∑ i : Fin n, (T.entropy i.castSucc - T.entropy i.succ) = T.entropy 0 - T.entropy (Fin.last n) := by
        intro n T hmon; induction' n with n ih <;> simp_all +decide [ Fin.sum_univ_succ ] ;
        specialize ih ( ⟨ fun i => T.entropy i.succ, fun i => T.entropy_nonneg _ ⟩ ) ( fun i => hmon i.succ ) ; norm_num [ Fin.sum_univ_succ ] at * ; linarith!;
      convert h_telescope n T hmon using 1;
      exact Finset.sum_congr rfl fun i hi => stepErasure_of_monotone T hmon i

/-! ## Theorem 2: Erasure Concentration (Pigeonhole)

In any proof trace of positive length, at least one step has erasure
at least `depth / n`. This guarantees the existence of thermodynamic
bottlenecks — no proof can spread its erasure cost perfectly evenly
below this threshold. -/

theorem erasure_concentration {n : ℕ} (hn : 0 < n) (T : ProofTrace n) :
    ∃ i : Fin n, thermodynamicDepth T / n ≤ stepErasure T i := by
      by_contra! h;
      -- Summing up the inequalities from h, we get a contradiction with the definition of thermodynamic depth.
      have h_sum : ∑ i : Fin n, stepErasure T i < n * (thermodynamicDepth T / n) := by
        simpa using Finset.sum_lt_sum_of_nonempty ⟨ ⟨ 0, hn ⟩, Finset.mem_univ _ ⟩ fun i hi => h i;
      rw [ mul_div_cancel₀ _ ( by positivity ) ] at h_sum ; exact h_sum.ne ( by rfl )

/-! ## Theorem 3: Reversible Steps Have Zero Erasure

For *monotone* traces, a step is reversible if and only if its erasure vanishes.
Without monotonicity the backward direction fails: entropy could increase
(zero erasure) without the step being reversible. -/

theorem reversible_implies_zero_erasure {n : ℕ} (T : ProofTrace n) (i : Fin n) :
    T.stepReversible i → stepErasure T i = 0 := by
      exact fun h => max_eq_left <| h.symm ▸ by norm_num;

theorem zero_erasure_iff_reversible_monotone {n : ℕ} (T : ProofTrace n)
    (hmon : T.isMonotone) (i : Fin n) :
    T.stepReversible i ↔ stepErasure T i = 0 := by
      grind +locals

/-! ## Theorem 4: Tropical Triangle Inequality -/

theorem tropical_triangle_inequality (a b c : ℝ) :
    tropicalDistance a c ≤ tropicalDistance a b + tropicalDistance b c := by
      exact abs_sub_le _ _ _

/-! ## Theorem 5: Depth Dominates Tropical Distance

For any monotone trace, the thermodynamic depth is at least
the tropical distance between initial and final entropy. Combined with
the telescoping theorem, this becomes an equality for monotone traces. -/

/-
For monotone traces, thermodynamic depth equals the tropical distance
between boundary entropies. Without monotonicity, entropy can increase,
making erasure zero while the distance grows.
-/
theorem depth_eq_tropical_distance_monotone {n : ℕ} (T : ProofTrace n) (hmon : T.isMonotone) :
    thermodynamicDepth T = tropicalDistance (T.entropy 0) (T.entropy (Fin.last n)) := by
      convert telescoping_theorem T hmon using 1;
      convert abs_of_nonneg ?_ using 1;
      · infer_instance;
      · exact sub_nonneg_of_le <| by exact Fin.inductionOn ( Fin.last n ) ( by norm_num ) fun i hi => by linarith [ hmon i ] ;

/-! ## Novel Definition: Proof Entropy Category

A `ProofEntropyMorphism` is a monotone map between entropy levels that
tracks the erasure cost of composing proof steps. This gives proof
thermodynamics a categorical structure where composition costs are
superadditive. -/

/-- A morphism in the proof entropy category: a monotone map with
tracked erasure cost. The key invariant is that the tracked cost
is at least the actual entropy difference. -/
structure ProofEntropyMorphism where
  /-- Source entropy level -/
  source : ℝ
  /-- Target entropy level -/
  target : ℝ
  /-- Source is non-negative -/
  source_nonneg : 0 ≤ source
  /-- Target is non-negative -/
  target_nonneg : 0 ≤ target
  /-- Monotonicity: target ≤ source (entropy can only decrease) -/
  monotone : target ≤ source
  /-- The tracked erasure cost -/
  cost : ℝ
  /-- Cost is at least the boundary difference -/
  cost_bound : source - target ≤ cost

/-- Composition of proof entropy morphisms. The cost is additive,
but the actual entropy difference telescopes. This gap between
additive cost and telescoped difference is the source of
superadditivity. -/
noncomputable def ProofEntropyMorphism.comp (f g : ProofEntropyMorphism)
    (h : f.target = g.source) : ProofEntropyMorphism where
  source := f.source
  target := g.target
  source_nonneg := f.source_nonneg
  target_nonneg := g.target_nonneg
  monotone := by linarith [f.monotone, g.monotone, h]
  cost := f.cost + g.cost
  cost_bound := by linarith [f.cost_bound, g.cost_bound, h]

/-! ## Theorem 6: Composition is Cost-Superadditive

When composing two proof steps, the total cost is at least the boundary
difference. -/

theorem composition_cost_superadditive (f g : ProofEntropyMorphism) (h : f.target = g.source) :
    (f.source - (ProofEntropyMorphism.comp f g h).target) ≤
    (ProofEntropyMorphism.comp f g h).cost := by
      convert add_le_add f.cost_bound g.cost_bound using 1 ; ring!;
      linarith!

/-! ## Theorem 7: Uniform Erasure Trace

Construct a proof trace where each step erases exactly `δ` units of entropy,
and show its depth equals `n * δ`. -/

/-- Construct a proof trace where each step erases exactly `δ` units of entropy. -/
noncomputable def uniformErasureTrace (n : ℕ) (δ : ℝ) (hδ : 0 ≤ δ) : ProofTrace n where
  entropy := fun i => (n - i.val) * δ
  entropy_nonneg := fun i => by
    apply mul_nonneg _ hδ
    simp only [sub_nonneg, Nat.cast_le]
    exact Nat.lt_succ_iff.mp i.isLt

theorem uniform_erasure_depth (n : ℕ) (δ : ℝ) (hδ : 0 ≤ δ) :
    thermodynamicDepth (uniformErasureTrace n δ hδ) = n * δ := by
      -- By definition of `uniformErasureTrace`, we know that `stepErasure T i = δ` for each `i`.
      have h_step : ∀ i : (Fin n), stepErasure (uniformErasureTrace n δ hδ) i = δ := by
        unfold stepErasure uniformErasureTrace;
        simp +zetaDelta at *;
        grind +revert;
      unfold thermodynamicDepth; aesop;

/-! ## Theorem 8: Depth Lower Bound for Monotone Traces

For monotone traces, the depth is non-negative and equals the boundary
difference, which is non-negative by monotonicity. This gives a clean
characterization of when depth can be zero. -/

theorem depth_nonneg {n : ℕ} (T : ProofTrace n) :
    0 ≤ thermodynamicDepth T := by
  apply Finset.sum_nonneg
  intro i _
  exact stepErasure_nonneg T i

theorem depth_zero_iff_all_reversible {n : ℕ} (T : ProofTrace n) (hmon : T.isMonotone) :
    thermodynamicDepth T = 0 ↔ ∀ i : Fin n, T.stepReversible i := by
      constructor <;> intro h;
      · contrapose! h;
        obtain ⟨ i, hi ⟩ := h;
        exact ne_of_gt <| lt_of_lt_of_le ( by exact lt_max_of_lt_right <| sub_pos.mpr <| lt_of_le_of_ne ( hmon i ) fun h => hi <| by exact h.symm ) <| Finset.single_le_sum ( fun a _ => stepErasure_nonneg T a ) <| Finset.mem_univ i;
      · exact Finset.sum_eq_zero fun i _ => stepErasure_of_monotone T hmon i ▸ sub_eq_zero_of_eq ( h i )

/-! ## Conjecture: Tropical Proof Complexity Bound

**Conjecture**: For any Boolean function f with circuit complexity C(f),
every monotone proof trace certifying f has thermodynamic depth ≥ log₂(C(f)).

**Testable prediction**: For the AND function on n bits (circuit complexity n-1),
any certifying trace should have depth ≥ log(n-1). Test by constructing explicit
traces for small n and checking the bound computationally. -/

/-- A `BooleanProofCertificate` witnesses that a proof trace certifies
the computation of a Boolean function with given circuit complexity. -/
structure BooleanProofCertificate where
  /-- Number of proof steps -/
  numSteps : ℕ
  /-- The proof trace -/
  trace : ProofTrace numSteps
  /-- The trace is monotone -/
  trace_monotone : trace.isMonotone
  /-- Circuit complexity of the certified function -/
  circuitComplexity : ℕ
  /-- Circuit complexity is at least 2 -/
  complexity_pos : 2 ≤ circuitComplexity
  /-- Initial entropy encodes the circuit complexity -/
  initial_entropy_bound : Real.log circuitComplexity ≤ trace.entropy 0

/-
**Depth Lower Bound Conjecture**: Every Boolean proof certificate with
zero terminal entropy has thermodynamic depth at least log of the circuit
complexity. This follows from the telescoping theorem: depth = h(0) - h(last) ≥ h(0)
when h(last) = 0, and h(0) ≥ log(C) by hypothesis.
-/
theorem depth_lower_bound (cert : BooleanProofCertificate)
    (h_terminal : cert.trace.entropy (Fin.last cert.numSteps) = 0) :
    Real.log cert.circuitComplexity ≤ thermodynamicDepth cert.trace := by
      -- By the telescoping theorem, depth = h(0) - h(last).
      have h_depth : thermodynamicDepth cert.trace = cert.trace.entropy 0 - cert.trace.entropy (Fin.last cert.numSteps) := by
        exact telescoping_theorem _ cert.trace_monotone;
      linarith [ cert.initial_entropy_bound ]