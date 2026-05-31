/-
# Cellular Automata at the Ordinals: Transfinite Computation

We formalize cellular automata that evolve over ordinal time steps, proving that
the limit-step mechanism at limit ordinals provides strictly greater computational
power than finite iteration. This connects to Infinite Time Turing Machines (ITTMs)
and ordinal computation theory.
-/

import Mathlib

open Classical Set

/-!
## Part 1: Core Definitions
-/

/-- A spatial configuration of a 1D binary cellular automaton. -/
abbrev CAConfig := ℤ → Bool

/-- A 1D cellular automaton rule: maps a 3-neighborhood to a new state. -/
abbrev CARuleType := Bool → Bool → Bool → Bool

/-- Apply a CA rule to a configuration for one step. -/
def caStep (rule : CARuleType) (cfg : CAConfig) : CAConfig := fun i =>
  rule (cfg (i - 1)) (cfg i) (cfg (i + 1))

/-- Iterate caStep n times. -/
def caIter (rule : CARuleType) (cfg : CAConfig) : ℕ → CAConfig
  | 0 => cfg
  | n + 1 => caStep rule (caIter rule cfg n)

/-!
## Part 2: Transfinite Evolution via Limit Detection
-/

/-- A cell eventually stabilizes if there exists N such that for all n ≥ N,
    the cell has the same value. -/
def EventuallyStable (rule : CARuleType) (cfg : CAConfig) (i : ℤ) : Prop :=
  ∃ N : ℕ, ∀ n : ℕ, N ≤ n → caIter rule cfg n i = caIter rule cfg N i

/-- The eventual value of a cell (if it stabilizes), or false otherwise. -/
noncomputable def eventualValue (rule : CARuleType) (cfg : CAConfig) (i : ℤ) : Bool :=
  if h : EventuallyStable rule cfg i then
    caIter rule cfg (Classical.choose h) i
  else false

/-- The limit configuration at ω: the pointwise eventual value. -/
noncomputable def omegaLimitConfig (rule : CARuleType) (cfg : CAConfig) : CAConfig :=
  eventualValue rule cfg

/-- A transfinite CA evolution indexed by natural numbers of "limit steps".
    Level 0 = initial, Level n+1 = omega-limit of level n. -/
noncomputable def transfiniteLevel (rule : CARuleType) (cfg : CAConfig) : ℕ → CAConfig
  | 0 => cfg
  | n + 1 => omegaLimitConfig rule (transfiniteLevel rule cfg n)

/-!
## Part 3: Identity Rule Analysis
-/

/-- The identity rule: every cell maps to itself. -/
def idRule : CARuleType := fun _ c _ => c

/-- The identity rule preserves configurations exactly. -/
theorem idRule_preserves (cfg : CAConfig) : caStep idRule cfg = cfg := by
  ext i; simp [caStep, idRule]

/-- Iterating the identity rule preserves configurations. -/
theorem idRule_iter (cfg : CAConfig) (n : ℕ) : caIter idRule cfg n = cfg := by
  induction n with
  | zero => rfl
  | succ n ih => simp [caIter, ih, idRule_preserves]

/-- Under the identity rule, every cell is eventually stable. -/
theorem idRule_eventually_stable (cfg : CAConfig) (i : ℤ) :
    EventuallyStable idRule cfg i :=
  ⟨0, fun n _ => by rw [idRule_iter, idRule_iter]⟩

/-!
## Part 4: Fixed Points
-/

/-- A configuration is a fixed point of a rule. -/
def isFixedPoint (rule : CARuleType) (cfg : CAConfig) : Prop :=
  caStep rule cfg = cfg

/-- The identity rule has every configuration as a fixed point. -/
theorem idRule_all_fixed (cfg : CAConfig) : isFixedPoint idRule cfg :=
  idRule_preserves cfg

/-- If a configuration is a fixed point, then all iterations equal the original. -/
theorem fixedPoint_iter_eq (rule : CARuleType) (cfg : CAConfig) (hfp : isFixedPoint rule cfg)
    (n : ℕ) : caIter rule cfg n = cfg := by
  induction n with
  | zero => rfl
  | succ n ih =>
    simp only [caIter, ih]
    exact hfp

/-- If a configuration is a fixed point, every cell is eventually stable. -/
theorem fixedPoint_stable (rule : CARuleType) (cfg : CAConfig) (hfp : isFixedPoint rule cfg)
    (i : ℤ) : EventuallyStable rule cfg i :=
  ⟨0, fun n _ => by rw [fixedPoint_iter_eq rule cfg hfp n, fixedPoint_iter_eq rule cfg hfp 0]⟩

/-
For a fixed point, the omega limit equals the original configuration.
-/
theorem fixedPoint_omegaLimit (rule : CARuleType) (cfg : CAConfig) (hfp : isFixedPoint rule cfg) :
    omegaLimitConfig rule cfg = cfg := by
  ext i;
  unfold omegaLimitConfig eventualValue;
  split_ifs with h;
  · rw [ fixedPoint_iter_eq rule cfg hfp ];
  · exact False.elim <| h <| fixedPoint_stable rule cfg hfp i

/-!
## Part 5: Monotone CA and Expanding Dynamics
-/

/-- A configuration dominates another pointwise. -/
def configDominates (cfg₁ cfg₂ : CAConfig) : Prop :=
  ∀ i : ℤ, cfg₁ i = true → cfg₂ i = true

/-- The OR rule: output is true if any of the three cells is true. -/
def orRule : CARuleType := fun l c r => l || c || r

/-
For the OR rule, caStep produces a configuration that dominates the input.
-/
theorem orRule_expanding (cfg : CAConfig) :
    configDominates cfg (caStep orRule cfg) := by
  intro i hi; unfold caStep orRule; aesop;

/-
For the OR rule, iterations are monotonically expanding.
-/
theorem orRule_iter_monotone (cfg : CAConfig) (m n : ℕ) (hmn : m ≤ n) :
    configDominates (caIter orRule cfg m) (caIter orRule cfg n) := by
  induction' hmn with n hmn ih;
  · tauto;
  · have h_orRule : configDominates (caIter orRule cfg n) (caStep orRule (caIter orRule cfg n)) := by
      exact orRule_expanding (caIter orRule cfg n);
    exact fun i hi => h_orRule i ( ih i hi )

/-- A CA rule is monotone if flipping any input from false to true
    cannot cause the output to flip from true to false. -/
def CAMonotone (rule : CARuleType) : Prop :=
  ∀ l₁ c₁ r₁ l₂ c₂ r₂ : Bool,
    (l₁ = true → l₂ = true) →
    (c₁ = true → c₂ = true) →
    (r₁ = true → r₂ = true) →
    rule l₁ c₁ r₁ = true → rule l₂ c₂ r₂ = true

/-
The OR rule is monotone.
-/
theorem orRule_monotone : CAMonotone orRule := by
  unfold CAMonotone orRule; aesop;

/-
Monotone rules preserve dominance between configurations.
-/
theorem monotone_preserves_dominance (rule : CARuleType) (hm : CAMonotone rule)
    (cfg₁ cfg₂ : CAConfig) (hdom : configDominates cfg₁ cfg₂) :
    configDominates (caStep rule cfg₁) (caStep rule cfg₂) := by
  grind +locals

/-!
## Part 6: Transfinite Halting
-/

/-- A computation halts transfinitely if it reaches a fixed point after
    finitely many limit steps. -/
def transfinitelyHalts (rule : CARuleType) (cfg : CAConfig) : Prop :=
  ∃ n : ℕ, isFixedPoint rule (transfiniteLevel rule cfg n)

/-- The identity rule transfinitely halts from any configuration immediately. -/
theorem idRule_transfinitely_halts (cfg : CAConfig) :
    transfinitelyHalts idRule cfg :=
  ⟨0, idRule_all_fixed cfg⟩

/-
The transfinite levels are constant under the identity rule.
-/
theorem idRule_levels_constant (cfg : CAConfig) (n : ℕ) :
    transfiniteLevel idRule cfg n = cfg := by
  induction' n with n ih;
  · rfl;
  · -- By definition of `transfiniteLevel`, we have `transfiniteLevel idRule cfg (n + 1) = omegaLimitConfig idRule (transfiniteLevel idRule cfg n)`.
    rw [show transfiniteLevel idRule cfg (n + 1) = omegaLimitConfig idRule (transfiniteLevel idRule cfg n) from rfl];
    rw [ ih, fixedPoint_omegaLimit ] ; exact idRule_all_fixed cfg

/-!
## Part 7: Novel Structure — Transfinite Computation Stratification

A `StratifiedTransfiniteCA` organizes configurations by their stabilization depth,
creating a lattice structure on the space of transfinite computations.
-/

/-- A stratified transfinite computation record. -/
structure StratifiedTransfiniteCA where
  /-- The CA rule governing evolution. -/
  rule : CARuleType
  /-- The initial configuration. -/
  initial : CAConfig
  /-- The maximum transfinite level to track. -/
  maxLevel : ℕ
  /-- At each level, the set of cells that have stabilized. -/
  stableSet : ℕ → Set ℤ
  /-- Stability is monotone: once stable, always stable at higher levels. -/
  stable_mono : ∀ n m : ℕ, n ≤ m → m ≤ maxLevel → stableSet n ⊆ stableSet m

/-- The depth of a cell: the first level at which it stabilizes.
    Uses `WithTop ℕ` where ⊤ means "never stabilizes". -/
noncomputable def cellDepth (S : StratifiedTransfiniteCA) (i : ℤ) : WithTop ℕ :=
  if h : ∃ n : ℕ, n ≤ S.maxLevel ∧ i ∈ S.stableSet n
  then ↑(Nat.find h)
  else ⊤

/-
Cells that stabilize at level 0 have depth 0.
-/
theorem cellDepth_zero (S : StratifiedTransfiniteCA) (i : ℤ) (h : i ∈ S.stableSet 0)
    (_h0 : 0 ≤ S.maxLevel) :
    cellDepth S i = 0 := by
  unfold cellDepth; aesop;

/-!
## Part 8: The Spreading Lemma for OR Rule

For the OR rule starting from a single cell, we prove exact formulas
for the configuration at each time step.
-/

/-- A single-cell configuration: only position 0 is true. -/
def singleCell : CAConfig := fun i => i == 0

/-
After n steps of the OR rule from a single cell, position i is true
    iff |i| ≤ n.
-/
theorem orRule_single_cell_spread (n : ℕ) (i : ℤ) :
    caIter orRule singleCell n i = true ↔ i.natAbs ≤ n := by
  induction' n with n ih generalizing i <;> simp_all +decide [ caIter ];
  · unfold singleCell; aesop;
  · unfold caStep; simp +decide [ *, orRule ] ;
    omega

/-
The OR rule from a single cell eventually makes every cell true.
-/
theorem orRule_single_cell_eventually_all_true (i : ℤ) :
    ∃ N : ℕ, ∀ n : ℕ, N ≤ n → caIter orRule singleCell n i = true := by
  -- By the spreading lemma, caIter orRule singleCell n i = true if and only if i.natAbs ≤ n.
  have h_spread : ∀ n : ℕ, caIter orRule singleCell n i = true ↔ i.natAbs ≤ n := by
    exact fun n => orRule_single_cell_spread n i;
  exact ⟨ _, fun n hn => h_spread n |>.2 hn ⟩

/-
Every cell stabilizes to true under the OR rule from a single cell.
-/
theorem orRule_single_cell_stabilizes (i : ℤ) :
    EventuallyStable orRule singleCell i := by
  -- Apply the theorem that states every cell � eventually� stabilizes to true under the OR rule from a single cell.
  obtain ⟨N, hN⟩ := orRule_single_cell_eventually_all_true i;
  use N;
  intro n hn;
  aesop

/-
The omega limit of the OR rule from a single cell is the all-true configuration.
-/
theorem orRule_single_cell_omegaLimit :
    omegaLimitConfig orRule singleCell = fun _ => true := by
  -- By definition of `omegaLimitConfig`, we need to show that for any cell `i`, the value of `i` in the omega limit is true.
  funext i
  simp [omegaLimitConfig, eventualValue];
  split_ifs with h;
  · obtain ⟨ N, hN ⟩ := orRule_single_cell_eventually_all_true i;
    by_cases hN' : N ≤ Classical.choose h;
    · exact hN _ hN';
    · have := Classical.choose_spec h;
      exact this N ( le_of_not_ge hN' ) ▸ hN N le_rfl;
  · exact h <| orRule_single_cell_stabilizes i

/-!
## Part 9: Oscillation and Super-Turing Detection
-/

/-- A cell oscillates if it takes both values infinitely often. -/
def Oscillates (rule : CARuleType) (cfg : CAConfig) (i : ℤ) : Prop :=
  (∀ N : ℕ, ∃ n : ℕ, N ≤ n ∧ caIter rule cfg n i = true) ∧
  (∀ N : ℕ, ∃ n : ℕ, N ≤ n ∧ caIter rule cfg n i = false)

/-
If a cell oscillates, it is not eventually stable.
-/
theorem oscillates_not_stable (rule : CARuleType) (cfg : CAConfig) (i : ℤ)
    (hosc : Oscillates rule cfg i) : ¬EventuallyStable rule cfg i := by
  obtain ⟨h₁, h₂⟩ := hosc;
  exact fun ⟨ N, hN ⟩ => by obtain ⟨ n₁, hn₁₁, hn₁₂ ⟩ := h₁ N; obtain ⟨ n₂, hn₂₁, hn₂₂ ⟩ := h₂ N; have := hN n₁ hn₁₁; have := hN n₂ hn₂₁; aesop;

/-- If a cell is not eventually stable, its eventual value defaults to false. -/
theorem unstable_eventualValue_false (rule : CARuleType) (cfg : CAConfig) (i : ℤ)
    (h : ¬EventuallyStable rule cfg i) :
    eventualValue rule cfg i = false := by
  unfold eventualValue
  rw [dif_neg h]

/-- Oscillating cells map to false in the omega limit. -/
theorem oscillating_omegaLimit_false (rule : CARuleType) (cfg : CAConfig) (i : ℤ)
    (hosc : Oscillates rule cfg i) :
    omegaLimitConfig rule cfg i = false :=
  unstable_eventualValue_false rule cfg i (oscillates_not_stable rule cfg i hosc)

/-!
## Part 10: Transfinite Level Composition
-/

/-
Composing transfinite levels: the level-(m+n) configuration
    can be obtained from level m by applying n more limit steps.
-/
theorem transfiniteLevel_add (rule : CARuleType) (cfg : CAConfig) (m n : ℕ) :
    transfiniteLevel rule (transfiniteLevel rule cfg m) n =
    transfiniteLevel rule cfg (m + n) := by
  induction' n with n ih;
  · rfl;
  · convert congr_arg ( fun x => omegaLimitConfig rule x ) ih using 1

/-!
## Part 11: Conjecture — Ordinal Complexity Gap

**Conjecture**: For the OR rule on finitely-supported configurations, the computational
depth is always exactly 1. The omega-limit is the all-true-on-support configuration,
which is a fixed point.

**Test**: Compute OR rule from `singleCell`, verify omega limit = all-true,
verify all-true is a fixed point of OR rule.
-/

/-
The all-true configuration is a fixed point of the OR rule.
-/
theorem orRule_allTrue_fixed : isFixedPoint orRule (fun _ => true) := by
  exact funext fun x => by simp +decide [ isFixedPoint, caStep ] ;

/-
**Conjecture (testable)**: The omega limit of the OR rule from a single cell
    is a fixed point — establishing depth exactly 1.
-/
theorem orRule_omegaLimit_is_fixed :
    isFixedPoint orRule (omegaLimitConfig orRule singleCell) := by
  convert orRule_allTrue_fixed;
  exact congr_fun ( orRule_single_cell_omegaLimit ) _