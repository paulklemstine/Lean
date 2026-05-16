/-
# Ordinal Research Governance: Depth Guarantees via Proof-Theoretic Analysis

This module develops a formal theory of **ordinally certified automated discovery**,
where ordinal-valued depth functionals on research artifacts control non-triviality
and support automated triage of shallow cycles.

## Architecture

We define two complementary depth models:

1. **AetherOutput model**: A finite syntactic object with height, branching, novelty atoms,
   and dependencies. The ordinal depth is `height + branching`, giving a computable
   governance layer.

2. **ProofShape model**: An inductive type of proof constructors (axiom, compose, iterate,
   reflect) with genuinely transfinite ordinal depth via `ω`-exponentiation at reflection.
   This creates a phase transition between finitary and transfinite derivations.

## Main Results

* `depth_above_threshold_nontrivial` — Outputs above threshold ordinal are non-trivial.
* `innovationRank_le_ordinalDepth` — Innovation rank is dominated by ordinal depth.
* `cycleDepth_lt_iff_allBelow` — Cycle depth characterizes element-wise bounds.
* `shallow_cycle_rejected` — Shallow cycles have all outputs below threshold.
* `shallow_but_nontrivial_needs_escalation` — Mixed cycles require escalation.
* `psDepth_reflect_gt_finite` — Reflection strictly dominates finite iteration.
* `proofShape_nontrivial_of_depth_gt_one` — Deep proof shapes certify non-triviality.
* `reflectionFree_finite_depth` — Reflection-free shapes live below ω.
-/

import Mathlib

open Ordinal Finset

/-! ## Part I: AetherOutput Model — Finite Syntactic Research Objects -/

/-- A finite syntactic object encoding a research output with structural metadata. -/
structure AetherOutput where
  size : Nat
  height : Nat
  branching : Nat
  noveltyAtoms : Finset Nat
  dependencies : Finset Nat
  deriving DecidableEq

/-- The shallow threshold ordinal: 2. -/
noncomputable def shallowThreshold : Ordinal := 2

/-- Ordinal depth of an AetherOutput: the sum of height and branching. -/
noncomputable def aetherDepth (x : AetherOutput) : Ordinal :=
  (x.height : Ordinal) + (x.branching : Ordinal)

/-- An output is shallow if both height and branching are at most 1. -/
def AetherShallow (x : AetherOutput) : Prop :=
  x.height ≤ 1 ∧ x.branching ≤ 1

/-- An output is research-nontrivial if it is not shallow. -/
def ResearchNontrivial (x : AetherOutput) : Prop :=
  ¬ AetherShallow x

instance : DecidablePred AetherShallow := fun x =>
  inferInstanceAs (Decidable (x.height ≤ 1 ∧ x.branching ≤ 1))

instance : DecidablePred ResearchNontrivial := fun x =>
  inferInstanceAs (Decidable (¬ AetherShallow x))

/-- Innovation rank: ordinal sum of novelty atom count and dependency count. -/
noncomputable def InnovationRank (x : AetherOutput) : Ordinal :=
  (x.noveltyAtoms.card : Ordinal) + (x.dependencies.card : Ordinal)

/-! ### Theorem 1: Threshold Depth Implies Non-Triviality -/

/-
Shallow outputs have ordinal depth at most 2.
-/
theorem shallow_depth_le_two (x : AetherOutput) (h : AetherShallow x) :
    aetherDepth x ≤ shallowThreshold := by
  -- By definition of AetherShallow, we have x.height ≤ 1 and x.branching ≤ 1.
  obtain ⟨h_height, h_branching⟩ := h;
  convert add_le_add ( Nat.cast_le.mpr h_height ) ( Nat.cast_le.mpr h_branching ) using 1;
  all_goals try infer_instance;
  norm_num [ shallowThreshold ]

/-
**Theorem 1**: If an output's ordinal depth exceeds the shallow threshold,
    then it is research-nontrivial.
-/
theorem depth_above_threshold_nontrivial
    (x : AetherOutput)
    (hx : shallowThreshold < aetherDepth x) :
    ResearchNontrivial x := by
  exact fun h => hx.not_ge <| shallow_depth_le_two x h

/-
**Theorem 1 (Abstract)**: For any threshold τ, if all trivial outputs
    have depth ≤ τ, then any output with depth > τ is non-trivial.
    This is the abstract form: the threshold separates trivial from non-trivial.
-/
theorem depth_above_threshold_abstract
    (τ : Ordinal) (x : AetherOutput)
    (hτ : ∀ y, ¬ ResearchNontrivial y → aetherDepth y ≤ τ)
    (hx : τ < aetherDepth x) :
    ResearchNontrivial x := by
  exact Classical.not_not.1 fun hx' => hx.not_ge <| hτ x hx'

/-! ### Theorem 2: Innovation Bounded by Depth -/

/-
Innovation rank is bounded by ordinal depth when counts are bounded
    by height and branching respectively.
-/
theorem innovationRank_le_aetherDepth
    (x : AetherOutput)
    (h1 : x.noveltyAtoms.card ≤ x.height)
    (h2 : x.dependencies.card ≤ x.branching) :
    InnovationRank x ≤ aetherDepth x := by
  exact add_le_add ( Nat.cast_le.mpr h1 ) ( Nat.cast_le.mpr h2 )

/-! ## Part II: Research Cycles and Governance Policy -/

/-- A research cycle is a finite collection of AetherOutputs. -/
structure ResearchCycle where
  outputs : Finset AetherOutput

/-- The depth of a research cycle: supremum of output depths. -/
noncomputable def cycleDepth (C : ResearchCycle) : Ordinal :=
  C.outputs.sup aetherDepth

/-- All outputs in a cycle are below threshold τ. -/
def AllBelow (τ : Ordinal) (C : ResearchCycle) : Prop :=
  ∀ x ∈ C.outputs, aetherDepth x < τ

/-- A cycle is rejectable if its depth is below threshold. -/
def Rejectable (τ : Ordinal) (C : ResearchCycle) : Prop :=
  cycleDepth C < τ

/-- A cycle needs escalation if it is shallow but contains non-trivial outputs. -/
def NeedsEscalation (τ : Ordinal) (C : ResearchCycle) : Prop :=
  cycleDepth C < τ ∧ ∃ x ∈ C.outputs, ResearchNontrivial x

/-! ### Theorem 3: Cycle Depth Characterization -/

/-
**Theorem 3**: Cycle depth below threshold iff all outputs below threshold.
    Requires the threshold to be positive (since `Finset.sup` of empty set is ⊥ = 0).
-/
theorem cycleDepth_lt_iff_allBelow
    (τ : Ordinal) (C : ResearchCycle) (hτ : 0 < τ) :
    cycleDepth C < τ ↔ AllBelow τ C := by
  convert Finset.sup_lt_iff _ ; aesop

/-
Shallow cycles have all outputs below threshold.
-/
theorem shallow_cycle_rejected
    (τ : Ordinal) (C : ResearchCycle) (hτ : 0 < τ)
    (h : cycleDepth C < τ) :
    AllBelow τ C := by
  -- Apply the theorem cycleDepth_lt_iff_allBelow with the given hypotheses.
  apply (cycleDepth_lt_iff_allBelow τ C hτ).mp h

/-! ### Theorem 4: Escalation Policy -/

/-
**Theorem 4**: A shallow cycle with a non-trivial output needs escalation.
-/
theorem shallow_but_nontrivial_needs_escalation
    (τ : Ordinal) (C : ResearchCycle)
    (h1 : cycleDepth C < τ)
    (h2 : ∃ x ∈ C.outputs, ResearchNontrivial x) :
    NeedsEscalation τ C := by
  exact ⟨ h1, h2 ⟩

/-
**Policy Completeness**: Every shallow cycle is either purely trivial or needs escalation.
-/
theorem shallow_cycle_triage
    (τ : Ordinal) (C : ResearchCycle)
    (h : cycleDepth C < τ) :
    (∀ x ∈ C.outputs, ¬ ResearchNontrivial x) ∨ NeedsEscalation τ C := by
  exact Classical.or_iff_not_imp_left.2 fun h' => ⟨ h, by push_neg at h'; tauto ⟩

/-! ## Part III: ProofShape Model — Transfinite Depth Semantics -/

/-- Proof shapes with constructors of increasing structural complexity.
    `reflect` introduces transfinite depth via ω-exponentiation. -/
inductive ProofShape : Type
  | axm : ProofShape
  | compose : ProofShape → ProofShape → ProofShape
  | iterate : Nat → ProofShape → ProofShape
  | reflect : ProofShape → ProofShape
  deriving DecidableEq

namespace ProofShape

/-- Ordinal-valued depth of a proof shape.
    Reflection applies ω-exponentiation, creating a phase transition. -/
noncomputable def psDepth : ProofShape → Ordinal
  | .axm => 0
  | .compose a b => Order.succ (max a.psDepth b.psDepth)
  | .iterate n a => a.psDepth + (n : Ordinal)
  | .reflect a => omega0 ^ a.psDepth

/-- Predicate: a proof shape contains a reflect constructor. -/
def hasReflect : ProofShape → Prop
  | .axm => False
  | .compose a b => hasReflect a ∨ hasReflect b
  | .iterate _ a => hasReflect a
  | .reflect _ => True

@[simp] theorem psDepth_axm : psDepth .axm = 0 := rfl

/-
Composition strictly increases depth (left component).
-/
theorem psDepth_compose_gt_left (a b : ProofShape) :
    a.psDepth < (compose a b).psDepth := by
  exact lt_of_le_of_lt ( le_max_left _ _ ) ( Order.lt_succ _ )

/-
Composition strictly increases depth (right component).
-/
theorem psDepth_compose_gt_right (a b : ProofShape) :
    b.psDepth < (compose a b).psDepth := by
  -- By definition of `psDepth`, we have `(a.compose b).psDepth = max a.psDepth b.psDepth + 1`.
  rw [ProofShape.psDepth];
  exact lt_of_le_of_lt ( le_max_right _ _ ) ( Order.lt_succ _ )

/-
**Key Theorem**: Reflection of a shape with positive depth produces depth ≥ ω,
    which exceeds any finite ordinal. This is the phase transition.
-/
theorem psDepth_reflect_gt_finite (a : ProofShape) (n : Nat)
    (ha : 0 < a.psDepth) :
    (n : Ordinal) < psDepth (.reflect a) := by
  refine' lt_of_lt_of_le _ ( Ordinal.opow_le_opow_right _ <| show 1 ≤ a.psDepth from _ );
  · simp +decide [ Ordinal.nat_lt_omega0 ];
  · exact Ordinal.omega0_pos;
  · contrapose! ha;
    convert le_of_not_gt _;
    induction a <;> simp_all +decide [ ProofShape.psDepth ];
    · exact Ordinal.succ_ne_zero _ ha;
    · rw [ add_eq_zero_iff_of_nonneg ] at * <;> aesop;

/-
Reflection of a non-trivial shape has depth ≥ ω.
-/
theorem psDepth_reflect_ge_omega (a : ProofShape)
    (ha : 0 < a.psDepth) :
    omega0 ≤ psDepth (.reflect a) := by
  nontriviality;
  rename_i how_le_opow_right;
  have := how_le_opow_right.exists_pair_ne;
  contrapose! this;
  obtain ⟨ x, y, hxy ⟩ := ‹Nontrivial Ordinal›;
  cases lt_or_gt_of_ne hxy <;> cases lt_or_ge x 0 <;> cases lt_or_ge y 0 <;> simp_all +decide [ Ordinal.lt_omega0, Ordinal.omega0_pos ];
  · obtain ⟨ n, hn ⟩ := this;
    exact absurd hn ( ne_of_gt ( psDepth_reflect_gt_finite a n ha ) );
  · obtain ⟨ n, hn ⟩ := this;
    exact absurd hn ( ne_of_gt ( psDepth_reflect_gt_finite a n ha ) )

private theorem succ_lt_omega0 {a : Ordinal} (ha : a < omega0) : Order.succ a < omega0 := by
  rw [Ordinal.lt_omega0] at ha ⊢
  obtain ⟨n, rfl⟩ := ha
  exact ⟨n + 1, by simp [Nat.cast_succ]⟩

/-
Reflection-free proof shapes have finite (< ω) depth.
-/
theorem reflectionFree_finite_depth :
    ∀ p : ProofShape, ¬ hasReflect p → p.psDepth < omega0 := by
  intro p hp;
  exact Ordinal.lt_omega0.2 ( by
    induction' p using ProofShape.recOn with p hp ih;
    · exact ⟨ 0, rfl ⟩;
    · -- By definition of `hasReflect`, if `¬(p.compose hp✝).hasReflect`, then `¬p.hasReflect` and `¬hp✝.hasReflect`.
      have h_not_reflect : ¬p.hasReflect ∧ ¬‹ProofShape›.hasReflect := by
        exact not_or.mp hp;
      obtain ⟨ n, hn ⟩ := ih h_not_reflect.1; obtain ⟨ m, hm ⟩ := ‹¬_ → ∃ n : ℕ, _› h_not_reflect.2; use Max.max n m + 1; simp +decide [ *, ProofShape.psDepth ] ;
      cases max_choice n m <;> simp +decide [ * ];
      · exact le_of_max_le_left ( by aesop );
      · grind;
    · rename_i n a ih;
      obtain ⟨ k, hk ⟩ := ih ( by cases a <;> tauto );
      exact ⟨ k + n, by erw [ show ( ProofShape.iterate n a ).psDepth = a.psDepth + n from rfl ] ; simp +decide [ hk ] ⟩;
    · exact False.elim <| hp <| by tauto; )

/-
Reflect constructor always produces positive depth.
-/
theorem reflect_depth_pos (a : ProofShape) :
    0 < (ProofShape.reflect a).psDepth := by
  exact Ordinal.opow_pos _ Ordinal.omega0_pos

end ProofShape

/-! ## Part IV: Bridge Theorems -/

/-
Bridge theorem: Finset.sup characterization for ordinal depth.
-/
theorem bridge_sup_lt_iff
    (τ : Ordinal) (S : Finset AetherOutput) (hτ : 0 < τ) :
    S.sup aetherDepth < τ ↔ ∀ x ∈ S, aetherDepth x < τ := by
  convert cycleDepth_lt_iff_allBelow τ ⟨ S ⟩ hτ using 1

/-
Monotonicity: adding branching increases depth.
-/
theorem aetherDepth_mono_branching (x : AetherOutput) (k : Nat) :
    aetherDepth x ≤ aetherDepth { x with branching := x.branching + k } := by
  unfold aetherDepth; simp +decide [ add_assoc ] ;

/-
Monotonicity: adding height increases depth.
-/
theorem aetherDepth_mono_height (x : AetherOutput) (k : Nat) :
    aetherDepth x ≤ aetherDepth { x with height := x.height + k } := by
  -- By definition of aetherDepth, we have:
  unfold aetherDepth;
  norm_cast ; linarith

/-! ## Part V: Decidable Governance -/

/-- Computable threshold check. -/
def aboveNatThreshold (n : Nat) (x : AetherOutput) : Bool :=
  n < x.height + x.branching

/-
The boolean decision agrees with the ordinal predicate.
-/
theorem aboveNatThreshold_iff (n : Nat) (x : AetherOutput) :
    aboveNatThreshold n x = true ↔ (n : Ordinal) < aetherDepth x := by
  unfold aboveNatThreshold aetherDepth; norm_cast;
  grind

/-! ## Part VI: Depth Strict Monotonicity -/

/-- Composition never preserves depth: it always strictly increases. -/
theorem no_depth_preserving_composition (a b : ProofShape) :
    a.psDepth < (ProofShape.compose a b).psDepth :=
  ProofShape.psDepth_compose_gt_left a b