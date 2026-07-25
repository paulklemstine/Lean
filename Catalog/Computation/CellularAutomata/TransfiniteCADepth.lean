/-
# Transfinite Cellular Automata: Depth Hierarchy and Oscillation Classification

We extend the transfinite CA framework with a rigorous depth theory.
The main results are:
1. Depth-0 Classification: A config has depth 0 iff it is a fixed point.
2. The NOT rule has infinite depth (no fixed points exist).
3. The OR rule from a single cell has depth ≤ 1 (omega-limit is a fixed point).
4. A novel "Convergence Spectrum" structure classifying rules by their limit behavior.
5. Oscillation collapse: oscillating cells map to false in the omega limit.

Builds on: `Catalog/Computation/TransfiniteCA.lean`
-/

import Mathlib

open Classical Set Function

/-!
## Core Definitions
-/

abbrev CAConfig := ℤ → Bool
abbrev CARuleType := Bool → Bool → Bool → Bool

def caStep (rule : CARuleType) (cfg : CAConfig) : CAConfig := fun i =>
  rule (cfg (i - 1)) (cfg i) (cfg (i + 1))

def caIter (rule : CARuleType) (cfg : CAConfig) : ℕ → CAConfig
  | 0 => cfg
  | n + 1 => caStep rule (caIter rule cfg n)

def EventuallyStable (rule : CARuleType) (cfg : CAConfig) (i : ℤ) : Prop :=
  ∃ N : ℕ, ∀ n : ℕ, N ≤ n → caIter rule cfg n i = caIter rule cfg N i

noncomputable def eventualValue (rule : CARuleType) (cfg : CAConfig) (i : ℤ) : Bool :=
  if h : EventuallyStable rule cfg i then
    caIter rule cfg (Classical.choose h) i
  else false

noncomputable def omegaLimitConfig (rule : CARuleType) (cfg : CAConfig) : CAConfig :=
  eventualValue rule cfg

def isFixedPoint (rule : CARuleType) (cfg : CAConfig) : Prop :=
  caStep rule cfg = cfg

noncomputable def transfiniteLevel (rule : CARuleType) (cfg : CAConfig) : ℕ → CAConfig
  | 0 => cfg
  | n + 1 => omegaLimitConfig rule (transfiniteLevel rule cfg n)

def configDominates (cfg₁ cfg₂ : CAConfig) : Prop :=
  ∀ i : ℤ, cfg₁ i = true → cfg₂ i = true

def orRule : CARuleType := fun l c r => l || c || r

def CAMonotone (rule : CARuleType) : Prop :=
  ∀ l₁ c₁ r₁ l₂ c₂ r₂ : Bool,
    (l₁ = true → l₂ = true) →
    (c₁ = true → c₂ = true) →
    (r₁ = true → r₂ = true) →
    rule l₁ c₁ r₁ = true → rule l₂ c₂ r₂ = true

def Oscillates (rule : CARuleType) (cfg : CAConfig) (i : ℤ) : Prop :=
  (∀ N : ℕ, ∃ n : ℕ, N ≤ n ∧ caIter rule cfg n i = true) ∧
  (∀ N : ℕ, ∃ n : ℕ, N ≤ n ∧ caIter rule cfg n i = false)

/-!
## Novel Structure: Convergence Spectrum

The **Convergence Spectrum** classifies initial configurations by the number of limit
steps required to reach a fixed point, creating a stratification that mirrors the
arithmetic hierarchy.
-/

/-- The transfinite depth of a computation: the minimum number of limit steps
    to reach a fixed point, or ⊤ if no fixed point is ever reached. -/
noncomputable def transfiniteDepth (rule : CARuleType) (cfg : CAConfig) : WithTop ℕ :=
  if h : ∃ n : ℕ, isFixedPoint rule (transfiniteLevel rule cfg n)
  then ↑(Nat.find h)
  else ⊤

/-- The convergence spectrum of a CA rule at depth d. -/
noncomputable def convergenceSpectrum (rule : CARuleType) (d : WithTop ℕ) : Set CAConfig :=
  {cfg | transfiniteDepth rule cfg = d}

/-- A CA rule has finite spectrum if every configuration reaches a fixed point. -/
def hasFiniteSpectrum (rule : CARuleType) : Prop :=
  ∀ cfg : CAConfig, transfiniteDepth rule cfg ≠ ⊤

/-- A CA rule has bounded spectrum with a uniform depth bound. -/
def hasBoundedSpectrum (rule : CARuleType) (bound : ℕ) : Prop :=
  ∀ cfg : CAConfig, ∃ n : ℕ, n ≤ bound ∧ isFixedPoint rule (transfiniteLevel rule cfg n)

/-!
## Fixed Point Preservation
-/

theorem fixedPoint_iter_eq (rule : CARuleType) (cfg : CAConfig) (hfp : isFixedPoint rule cfg)
    (n : ℕ) : caIter rule cfg n = cfg := by
  induction n with
  | zero => rfl
  | succ n ih => simp only [caIter, ih]; exact hfp

theorem fixedPoint_stable (rule : CARuleType) (cfg : CAConfig) (hfp : isFixedPoint rule cfg)
    (i : ℤ) : EventuallyStable rule cfg i :=
  ⟨0, fun n _ => by rw [fixedPoint_iter_eq rule cfg hfp n, fixedPoint_iter_eq rule cfg hfp 0]⟩

theorem fixedPoint_omegaLimit (rule : CARuleType) (cfg : CAConfig)
    (hfp : isFixedPoint rule cfg) :
    omegaLimitConfig rule cfg = cfg := by
  ext i
  unfold omegaLimitConfig eventualValue
  rw [dif_pos (fixedPoint_stable rule cfg hfp i)]
  have := fixedPoint_iter_eq rule cfg hfp (Classical.choose (fixedPoint_stable rule cfg hfp i))
  exact congr_fun this i

/-!
## Depth-0 Classification
-/

/-
A fixed point has transfinite depth 0.
-/
theorem depth_zero_of_fixedPoint (rule : CARuleType) (cfg : CAConfig)
    (hfp : isFixedPoint rule cfg) :
    transfiniteDepth rule cfg = 0 := by
  unfold transfiniteDepth;
  split_ifs <;> simp_all +decide [ Nat.find_eq_iff ];
  · exact hfp;
  · exact ‹∀ x : ℕ, ¬isFixedPoint rule ( transfiniteLevel rule cfg x ) › 0 hfp

/-
If transfinite depth is 0, the configuration is a fixed point.
-/
theorem fixedPoint_of_depth_zero (rule : CARuleType) (cfg : CAConfig)
    (hd : transfiniteDepth rule cfg = 0) :
    isFixedPoint rule cfg := by
  unfold transfiniteDepth at hd; aesop;

/-- **Depth-0 Classification Theorem**: depth = 0 ↔ fixed point. -/
theorem depth_zero_iff_fixedPoint (rule : CARuleType) (cfg : CAConfig) :
    transfiniteDepth rule cfg = 0 ↔ isFixedPoint rule cfg :=
  ⟨fixedPoint_of_depth_zero rule cfg, depth_zero_of_fixedPoint rule cfg⟩

/-!
## NOT Rule: Oscillation and Infinite Depth
-/

def notRule : CARuleType := fun _ c _ => !c

theorem notRule_step (cfg : CAConfig) :
    caStep notRule cfg = fun i => !(cfg i) := by
  exact funext fun i => by unfold caStep notRule; simp +decide ;

theorem notRule_iter_even (cfg : CAConfig) (n : ℕ) :
    caIter notRule cfg (2 * n) = cfg := by
  induction n <;> simp_all +decide [ Nat.mul_succ, caIter ];
  exact funext fun i => by unfold caStep; simp +decide [ notRule ] ;

theorem notRule_iter_odd (cfg : CAConfig) (n : ℕ) :
    caIter notRule cfg (2 * n + 1) = fun i => !(cfg i) := by
  convert notRule_step ( caIter notRule cfg ( 2 * n ) ) using 1;
  rw [ notRule_iter_even ]

/-
**Oscillation Theorem**: Every cell oscillates under the NOT rule.
-/
theorem notRule_oscillates (cfg : CAConfig) (i : ℤ) :
    Oscillates notRule cfg i := by
  constructor;
  · by_cases hi : cfg i;
    · exact fun N => ⟨ 2 * N, by linarith, by rw [ notRule_iter_even ] ; exact hi ⟩;
    · intro N; use 2 * N + 1; simp_all +decide [ notRule_iter_odd ] ;
      grind;
  · intro N
    by_cases h : cfg i = true;
    · exact ⟨ 2 * N + 1, by linarith, by simp +decide [ *, notRule_iter_odd ] ⟩;
    · exact ⟨ 2 * N, by linarith, by rw [ notRule_iter_even ] ; aesop ⟩

/-!
## Oscillation Collapse
-/

theorem oscillates_not_stable (rule : CARuleType) (cfg : CAConfig) (i : ℤ)
    (hosc : Oscillates rule cfg i) : ¬EventuallyStable rule cfg i := by
  intro hstable
  obtain ⟨N, hN⟩ := hstable
  obtain ⟨n1, hn1⟩ := hosc.left N
  obtain ⟨n2, hn2⟩ := hosc.right N
  have h_eq : caIter rule cfg n1 i = caIter rule cfg N i := by
    exact hN n1 hn1.1
  have h_eq' : caIter rule cfg n2 i = caIter rule cfg N i := by
    exact hN _ hn2.1
  aesop

theorem unstable_eventualValue (rule : CARuleType) (cfg : CAConfig) (i : ℤ)
    (h : ¬EventuallyStable rule cfg i) :
    eventualValue rule cfg i = false := by
  unfold eventualValue; rw [dif_neg h]

/-- **Oscillation Collapse Theorem**: Under the NOT rule, the omega-limit of any
    configuration is the all-false configuration. -/
theorem notRule_omegaLimit_allFalse (cfg : CAConfig) :
    omegaLimitConfig notRule cfg = fun _ => false := by
  ext i
  exact unstable_eventualValue notRule cfg i
    (oscillates_not_stable notRule cfg i (notRule_oscillates cfg i))

/-!
## NOT Rule: No Fixed Points → Infinite Depth
-/

/-
The NOT rule has no fixed point whatsoever.
-/
theorem notRule_no_fixedPoint (cfg : CAConfig) : ¬isFixedPoint notRule cfg := by
  unfold isFixedPoint;
  unfold caStep;
  exact fun h => by have := congr_fun h 0; have := congr_fun h 1; simp_all +decide [ notRule ] ;

/-- **NOT Rule Infinite Depth Theorem**: The NOT rule never reaches a fixed point
    at any transfinite level. -/
theorem notRule_depth_infinite (cfg : CAConfig) :
    transfiniteDepth notRule cfg = ⊤ := by
  unfold transfiniteDepth
  rw [dif_neg]
  push_neg
  intro n
  exact notRule_no_fixedPoint _

/-!
## OR Rule Spreading and Depth-1
-/

def singleCell : CAConfig := fun i => i == 0

/-
**Spreading Theorem**: After n steps of the OR rule from a single cell,
    position i is active iff |i| ≤ n.
-/
theorem orRule_spreading (n : ℕ) (i : ℤ) :
    caIter orRule singleCell n i = true ↔ i.natAbs ≤ n := by
  induction' n with n ih generalizing i <;> simp_all +decide [ caIter ];
  · unfold singleCell; aesop;
  · unfold caStep; simp +decide [ ih, orRule ] ;
    omega

theorem orRule_singleCell_stabilizes (i : ℤ) :
    EventuallyStable orRule singleCell i := by
  use i.natAbs
  intro n hn
  rw [(orRule_spreading n i).mpr hn, (orRule_spreading i.natAbs i).mpr le_rfl]

theorem orRule_singleCell_omegaLimit :
    omegaLimitConfig orRule singleCell = fun _ => true := by
  funext i;
  -- By definition of `omegaLimitConfig`, we need to show that `i` is eventually stable under `orRule`.
  have h_eventually_stable : EventuallyStable orRule singleCell i := by
    exact?;
  convert h_eventually_stable.choose_spec _ le_rfl using 1;
  · exact dif_pos h_eventually_stable;
  · have := h_eventually_stable.choose_spec ( Max.max ( Exists.choose h_eventually_stable ) ( Int.natAbs i ) ) ( le_max_left _ _ ) ; simp_all +decide [ orRule_spreading ] ;
    grind +suggestions

theorem orRule_allTrue_fixed : isFixedPoint orRule (fun _ => true) := by
  exact funext fun x => by simp +decide [ caStep, orRule ] ;

/-- **OR Rule Depth Theorem**: The OR rule from a single cell achieves depth ≤ 1. -/
theorem orRule_singleCell_depth_le_one :
    ∃ n : ℕ, n ≤ 1 ∧ isFixedPoint orRule (transfiniteLevel orRule singleCell n) := by
  exact ⟨1, le_rfl, by simp [transfiniteLevel, orRule_singleCell_omegaLimit]; exact orRule_allTrue_fixed⟩

/-!
## Transfinite Level Composition
-/

/-
**Composition Theorem**: Level-(m+n) = n levels applied from level-m.
-/
theorem transfiniteLevel_add (rule : CARuleType) (cfg : CAConfig) (m n : ℕ) :
    transfiniteLevel rule (transfiniteLevel rule cfg m) n =
    transfiniteLevel rule cfg (m + n) := by
  induction' n with n ih generalizing cfg <;> simp_all +decide [ Nat.add_comm, Nat.add_assoc, Nat.succ_add, transfiniteLevel ]

/-!
## Fixed Point Permanence
-/

/-
**Permanence Theorem**: Once a fixed point is reached, all subsequent levels are identical.
-/
theorem levels_constant_after_fixedPoint (rule : CARuleType) (cfg : CAConfig)
    (n : ℕ) (hfp : isFixedPoint rule (transfiniteLevel rule cfg n)) (k : ℕ) :
    transfiniteLevel rule cfg (n + k) = transfiniteLevel rule cfg n := by
  induction' k with k ih;
  · rfl;
  · convert fixedPoint_omegaLimit rule ( transfiniteLevel rule cfg n ) hfp using 1;
    rw [ ← ih, Nat.add_succ, transfiniteLevel ]

/-!
## Spectrum Partition
-/

/-- **Partition Theorem**: Every configuration belongs to exactly one spectrum level. -/
theorem spectrum_covers (rule : CARuleType) (cfg : CAConfig) :
    ∃! d : WithTop ℕ, cfg ∈ convergenceSpectrum rule d := by
  use transfiniteDepth rule cfg
  exact ⟨rfl, fun d hd => hd.symm⟩

/-!
## Bounded implies Finite Spectrum
-/

theorem bounded_implies_finite (rule : CARuleType) (bound : ℕ)
    (hb : hasBoundedSpectrum rule bound) : hasFiniteSpectrum rule := by
  intro cfg
  obtain ⟨n, hn⟩ := hb cfg
  have h_transfiniteDepth : transfiniteDepth rule cfg ≠ ⊤ := by
    unfold transfiniteDepth; aesop;
  exact h_transfiniteDepth

/-!
## AND Rule Properties
-/

def andRule : CARuleType := fun l c r => l && c && r

theorem andRule_monotone : CAMonotone andRule := by
  unfold CAMonotone andRule;
  lia

theorem orRule_monotone : CAMonotone orRule := by
  intro l₁ c₁ r₁ l₂ c₂ r₂ hl hc hr h
  simp only [orRule] at h ⊢
  simp [Bool.or_eq_true] at h ⊢
  rcases h with (h | h) | h
  · left; left; exact hl h
  · left; right; exact hc h
  · right; exact hr h

theorem andRule_allFalse_fixed : isFixedPoint andRule (fun _ => false) := by
  exact funext fun x => by simp +decide [ isFixedPoint, caStep, andRule ] ;

theorem andRule_allTrue_fixed : isFixedPoint andRule (fun _ => true) := by
  exact funext fun _ => rfl

/-!
## Monotone Rule Dominance Preservation
-/

/-
Monotone rules preserve the dominance ordering under one step.
-/
theorem monotone_step_preserves (rule : CARuleType) (hm : CAMonotone rule)
    (cfg₁ cfg₂ : CAConfig) (hdom : configDominates cfg₁ cfg₂) :
    configDominates (caStep rule cfg₁) (caStep rule cfg₂) := by
  intro i hi;
  unfold caStep at *; aesop;

/-
Monotone rules preserve dominance through iteration.
-/
theorem monotone_iter_preserves (rule : CARuleType) (hm : CAMonotone rule)
    (cfg₁ cfg₂ : CAConfig) (hdom : configDominates cfg₁ cfg₂) (n : ℕ) :
    configDominates (caIter rule cfg₁ n) (caIter rule cfg₂ n) := by
  -- We proceed by induction on $n$.
  induction' n with n ih generalizing cfg₁ cfg₂;
  · exact hdom;
  · exact monotone_step_preserves rule hm _ _ ( ih _ _ hdom )

/-!
## Depth Structural Lemmas
-/

theorem depth_ge_one_of_not_fixed (rule : CARuleType) (cfg : CAConfig)
    (hnf : ¬isFixedPoint rule cfg) :
    transfiniteDepth rule cfg ≠ 0 := by
  intro h; exact hnf (fixedPoint_of_depth_zero rule cfg h)

theorem depth_eq_find (rule : CARuleType) (cfg : CAConfig)
    (hex : ∃ n : ℕ, isFixedPoint rule (transfiniteLevel rule cfg n)) :
    transfiniteDepth rule cfg = ↑(Nat.find hex) := by
  unfold transfiniteDepth; rw [dif_pos hex]

theorem fixedPoint_at_depth (rule : CARuleType) (cfg : CAConfig)
    (hex : ∃ n : ℕ, isFixedPoint rule (transfiniteLevel rule cfg n)) :
    isFixedPoint rule (transfiniteLevel rule cfg (Nat.find hex)) :=
  Nat.find_spec hex

theorem not_fixedPoint_below_depth (rule : CARuleType) (cfg : CAConfig)
    (hex : ∃ n : ℕ, isFixedPoint rule (transfiniteLevel rule cfg n))
    (k : ℕ) (hk : k < Nat.find hex) :
    ¬isFixedPoint rule (transfiniteLevel rule cfg k) :=
  Nat.find_min hex hk

/-!
## Testable Conjecture: Depth-2 Existence

**Conjecture**: There exists a 1D binary CA rule R and initial configuration cfg₀
such that `transfiniteDepth R cfg₀ = 2`.

**Test**: The rule must satisfy:
  (a) `omegaLimitConfig R cfg₀` is not a fixed point of R (depth > 1), AND
  (b) `omegaLimitConfig R (omegaLimitConfig R cfg₀)` IS a fixed point (depth ≤ 2).

**Prediction**: A rule that combines spatial spreading (like OR) with a parity-sensitive
component could achieve this. The first omega-limit would resolve spatial structure but
leave parity oscillations, and the second omega-limit would collapse those.
-/

def depth_two_conjecture : Prop :=
  ∃ (rule : CARuleType) (cfg : CAConfig), transfiniteDepth rule cfg = 2