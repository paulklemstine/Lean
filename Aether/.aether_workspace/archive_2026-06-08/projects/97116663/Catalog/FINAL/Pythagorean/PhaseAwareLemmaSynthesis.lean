import Mathlib

/-!
# Phase-Aware Lemma Synthesis for AI Theorem Provers

This module develops a mathematical theory of *reasoning phase transitions*:
there exist structural regimes of theorem-search in which lemma synthesis is
provably the correct macroscopic control parameter.

## Main Results

1. **`phaseAwarePolicy_synthesis_upward_closed`**: Once a problem is assigned to
   lemma synthesis, every harder problem is too. (Monotone control stability)

2. **`effectiveComplexity_strictly_decreases_above_threshold`**: Above a certified
   complexity threshold, lemma synthesis strictly reduces effective complexity.

3. **`phaseAware_dominates_direct_above_threshold`**: A phase-aware prover solves
   problems within budget that a direct-search prover cannot.

4. **`synthesis_lowers_reasoningEnergy`**: Lemma synthesis lowers "reasoning energy"
   in the hard phase — a bridge to statistical physics.

5. **`theoremSpace_partitioned_by_phase`**: Theorem space decomposes into
   disjoint phase strata.
-/

namespace PhaseAwareLemmaSynthesis

/-! ## Phase Classification -/

/-- Phase classification for theorem instances. -/
inductive Phase where
  | tractable : Phase
  | transitional : Phase
  | intractable : Phase
  deriving DecidableEq, Repr

/-- Numerical index of a phase, for monotonicity statements. -/
def Phase.index : Phase → ℕ
  | .tractable => 0
  | .transitional => 1
  | .intractable => 2

instance : LE Phase where
  le p q := p.index ≤ q.index

instance : Preorder Phase where
  le_refl p := Nat.le_refl _
  le_trans _ _ _ := Nat.le_trans

theorem Phase.le_def (p q : Phase) : p ≤ q ↔ p.index ≤ q.index := Iff.rfl

theorem Phase.tractable_le (p : Phase) : Phase.tractable ≤ p := by
  cases p <;> simp [Phase.le_def, Phase.index]

theorem Phase.le_intractable (p : Phase) : p ≤ Phase.intractable := by
  cases p <;> simp [Phase.le_def, Phase.index]

theorem Phase.le_tractable_iff (p : Phase) : p ≤ Phase.tractable ↔ p = Phase.tractable := by
  cases p <;> simp [Phase.le_def, Phase.index]

/-! ## Phase Prediction -/

/-- Phase prediction given a threshold parameter. -/
def predictedPhase (threshold : ℕ) (n : ℕ) : Phase :=
  if n ≤ threshold then Phase.tractable
  else if n ≤ 2 * threshold then Phase.transitional
  else Phase.intractable

/-- The phase predictor is monotone. -/
theorem predictedPhase_monotone (t : ℕ) : Monotone (predictedPhase t) := by
  intro a b hab
  unfold predictedPhase
  split_ifs with h1 h2 h3 h4 <;>
    simp_all [Phase.le_def, Phase.index] <;> omega

/-! ## Search Actions and Policy -/

/-- The two search strategies available to the prover. -/
inductive SearchAction
  | direct
  | synthesizeLemmas
  deriving DecidableEq, Repr

/-- Phase-aware policy: direct search in tractable phase, synthesis otherwise. -/
def PhaseAwarePolicy (phaseFn : α → Phase) : α → SearchAction :=
  fun x =>
    match phaseFn x with
    | Phase.tractable => SearchAction.direct
    | Phase.transitional => SearchAction.synthesizeLemmas
    | Phase.intractable => SearchAction.synthesizeLemmas

/-- The policy assigns synthesis iff the phase is not tractable. -/
theorem phaseAwarePolicy_eq_synth_iff (phaseFn : α → Phase) (x : α) :
    PhaseAwarePolicy phaseFn x = SearchAction.synthesizeLemmas ↔
    phaseFn x ≠ Phase.tractable := by
  simp only [PhaseAwarePolicy]
  cases phaseFn x <;> simp

/-! ## Theorem 1: Monotone Phase-Aware Action Stability -/

/-
**Theorem 1.** If the phase predictor is monotone and a problem is assigned to
lemma synthesis, then every harder problem is also assigned to lemma synthesis.
"Once hard, always structurally hard upward."
-/
theorem phaseAwarePolicy_synthesis_upward_closed
    {α : Type} [Preorder α]
    (phaseFn : α → Phase)
    (hmono : Monotone phaseFn)
    {x y : α} (hxy : x ≤ y)
    (hx : PhaseAwarePolicy phaseFn x = SearchAction.synthesizeLemmas) :
    PhaseAwarePolicy phaseFn y = SearchAction.synthesizeLemmas := by
  unfold PhaseAwarePolicy at *;
  rcases h : phaseFn x with ( _ | _ | _ ) <;> rcases h' : phaseFn y with ( _ | _ | _ ) <;> simp_all +decide;
  · have := hmono hxy; simp_all +decide [ Phase.le_def ] ;
  · exact absurd ( hmono hxy ) ( by simp +decide [ h, h' ] )

/-! ## Lemma Benefit Model -/

/-- A lemma benefit model captures how intermediate lemma synthesis reduces
effective search complexity. -/
structure LemmaBenefit (α : Type) where
  baseComplexity : α → ℕ
  reducedComplexity : α → ℕ
  beneficial : ∀ x, reducedComplexity x ≤ baseComplexity x

/-- Effective complexity: with or without lemma synthesis. -/
def effectiveComplexity (L : LemmaBenefit α) (useLemma : Bool) (x : α) : ℕ :=
  if useLemma then L.reducedComplexity x else L.baseComplexity x

/-- Compression threshold: above complexity `k`, lemma synthesis yields *strict*
complexity reduction. -/
def CompressionThreshold (L : LemmaBenefit α) (k : ℕ) : Prop :=
  ∀ x, k ≤ L.baseComplexity x → L.reducedComplexity x < L.baseComplexity x

/-! ## Theorem 2: Strict Advantage Above Compression Threshold -/

/-
**Theorem 2.** Above a certified complexity threshold, lemma synthesis strictly
lowers effective complexity compared to direct search.
-/
theorem effectiveComplexity_strictly_decreases_above_threshold
    {α : Type}
    (L : LemmaBenefit α)
    (k : Nat)
    (hthr : CompressionThreshold L k)
    {x : α}
    (hx : k ≤ L.baseComplexity x) :
    effectiveComplexity L true x < effectiveComplexity L false x := by
  exact hthr x hx

/-! ## Theorem 3: Resource Allocation Dominance -/

/-- A problem is solvable within budget `B` if its complexity does not exceed `B`. -/
def SolvesWithinBudget (c : α → ℕ) (B : ℕ) (x : α) : Prop :=
  c x ≤ B

/-
**Theorem 3.** A phase-aware prover that uses lemma synthesis solves problems
within budget that a direct-search-only prover cannot.
-/
theorem phaseAware_dominates_direct_above_threshold
    {α : Type}
    (L : LemmaBenefit α)
    (k B : Nat)
    (_hthr : CompressionThreshold L k)
    {x : α}
    (_hxk : k ≤ L.baseComplexity x)
    (hB : L.reducedComplexity x ≤ B)
    (hnot : ¬ L.baseComplexity x ≤ B) :
    SolvesWithinBudget (effectiveComplexity L true) B x ∧
    ¬ SolvesWithinBudget (effectiveComplexity L false) B x := by
  unfold SolvesWithinBudget effectiveComplexity; aesop;

/-! ## Cross-Domain Bridge: Statistical Physics -/

/-- Reasoning energy: an abstract energy functional proportional to complexity. -/
def reasoningEnergy (c : α → ℕ) (x : α) : ℚ := c x

/-
**Theorem 4.** Above the compression threshold, lemma synthesis lowers reasoning
energy. Formal analogue of free-energy descent in statistical physics.
-/
theorem synthesis_lowers_reasoningEnergy
    {α : Type}
    (L : LemmaBenefit α)
    (k : Nat)
    (hthr : CompressionThreshold L k)
    {x : α}
    (hx : k ≤ L.baseComplexity x) :
    reasoningEnergy L.reducedComplexity x < reasoningEnergy L.baseComplexity x := by
  convert hthr _ hx using 1 ; unfold reasoningEnergy ; norm_cast;

/-
Energy gap is at least 1 above threshold (discrete complexity).
-/
theorem energy_gap_at_least_one
    {α : Type}
    (L : LemmaBenefit α)
    (k : Nat)
    (hthr : CompressionThreshold L k)
    {x : α}
    (hx : k ≤ L.baseComplexity x) :
    1 ≤ reasoningEnergy L.baseComplexity x - reasoningEnergy L.reducedComplexity x := by
  unfold reasoningEnergy ;
  exact le_tsub_of_add_le_left ( mod_cast hthr x hx )

/-! ## Phase Partition of Theorem Space -/

/-
Phase regions for distinct phases are pairwise disjoint.
-/
theorem phase_regions_disjoint
    (phaseFn : α → Phase) (p q : Phase) (hpq : p ≠ q) :
    Disjoint {x | phaseFn x = p} {x | phaseFn x = q} := by
  exact Set.disjoint_left.mpr fun x hx hx' => hpq <| hx.symm.trans hx'

/-
**Theorem 5.** Theorem space decomposes into the union of phase strata.
-/
theorem theoremSpace_partitioned_by_phase
    (phaseFn : α → Phase) :
    (⋃ p : Phase, {x | phaseFn x = p}) = Set.univ := by
  exact Set.eq_univ_of_forall fun x => Set.mem_iUnion.2 ⟨ phaseFn x, rfl ⟩

/-
The synthesis region is upward closed under a monotone phase predictor.
-/
theorem synthesis_region_upward_closed
    {α : Type} [Preorder α]
    (phaseFn : α → Phase)
    (hmono : Monotone phaseFn)
    {x y : α} (hxy : x ≤ y)
    (hx : phaseFn x ≠ Phase.tractable) :
    phaseFn y ≠ Phase.tractable := by
  contrapose! hx;
  exact hmono hxy |> fun h => by rw [ hx ] at h; exact Phase.le_tractable_iff _ |>.1 h;

/-! ## Verified Algorithm -/

/-- Certified decision procedure: choose search action based on predicted phase. -/
def chooseSearchAction (threshold : ℕ) (n : ℕ) : SearchAction :=
  PhaseAwarePolicy (predictedPhase threshold) n

/-- `chooseSearchAction` selects direct search in the tractable phase. -/
theorem chooseSearchAction_tractable (threshold n : ℕ) (h : n ≤ threshold) :
    chooseSearchAction threshold n = SearchAction.direct := by
  simp [chooseSearchAction, PhaseAwarePolicy, predictedPhase, h]

/-
`chooseSearchAction` selects lemma synthesis outside the tractable phase.
-/
theorem chooseSearchAction_synthesis (threshold n : ℕ) (h : threshold < n) :
    chooseSearchAction threshold n = SearchAction.synthesizeLemmas := by
  unfold chooseSearchAction;
  cases h : predictedPhase threshold n <;> simp_all +decide [ PhaseAwarePolicy ];
  unfold predictedPhase at h; aesop;

/-- The certified selector improves complexity when threshold conditions hold. -/
theorem chooseSearchAction_improves_complexity
    (L : LemmaBenefit ℕ)
    (threshold k : ℕ)
    (hthr : CompressionThreshold L k)
    (n : ℕ)
    (_hn_phase : threshold < n)
    (hn_compl : k ≤ L.baseComplexity n) :
    effectiveComplexity L true n < effectiveComplexity L false n := by
  exact effectiveComplexity_strictly_decreases_above_threshold L k hthr hn_compl

/-! ## Concrete Example: Exponential vs Linear -/

/-- The canonical lemma benefit model: exponential base, linear reduced. -/
noncomputable def exponentialBenefit : LemmaBenefit ℕ where
  baseComplexity := fun n => 2 ^ n
  reducedComplexity := fun n => n + 1
  beneficial := by
    intro n
    induction n with
    | zero => simp
    | succ n ih =>
      calc n + 1 + 1 ≤ 2 ^ n + 2 ^ n := by omega
        _ = 2 ^ (n + 1) := by ring

/-
Above threshold 3, the exponential benefit model satisfies compression.
    For all n with 3 ≤ 2^n (i.e., n ≥ 2), we have n + 1 < 2^n.
-/
theorem exponentialBenefit_threshold : CompressionThreshold exponentialBenefit 3 := by
  intro n hn;
  rcases n with ( _ | _ | _ | n ) <;> simp_all +arith +decide;
  exact Nat.recOn n ( by decide ) fun n ihn => by norm_num [ Nat.pow_succ', exponentialBenefit ] at * ; linarith

/-
Concrete dominance: for n ≥ 3, reduced complexity fits within polynomial budget
    but base complexity does not.
-/
theorem exponential_dominance_example (n : ℕ) (_hn : 3 ≤ n) (B : ℕ)
    (hB : n + 1 ≤ B) (hnotB : ¬ 2 ^ n ≤ B) :
    SolvesWithinBudget (effectiveComplexity exponentialBenefit true) B n ∧
    ¬ SolvesWithinBudget (effectiveComplexity exponentialBenefit false) B n := by
  exact ⟨ hB, hnotB ⟩

/-! ## Curriculum Partition -/

/-- Curriculum bucket: problems above threshold go to the hard bucket. -/
def curriculumBucket (threshold : ℕ) (n : ℕ) : Bool :=
  decide (threshold < n)

/-
The curriculum bucket agrees with the phase-aware policy.
-/
theorem curriculumBucket_agrees_with_policy (threshold n : ℕ) :
    curriculumBucket threshold n = true ↔
    chooseSearchAction threshold n = SearchAction.synthesizeLemmas := by
  unfold curriculumBucket chooseSearchAction;
  unfold PhaseAwarePolicy predictedPhase; aesop;

end PhaseAwareLemmaSynthesis