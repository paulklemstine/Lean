/-
  # Entropy Barrier Theory for Resolution Lower Bounds

  This file formalizes an information-theoretic framework for understanding
  resolution proof complexity through entropy barriers. The central idea:
  if the "entropy" of derivable clauses exhibits a sharp drop at some
  intermediate width scale, then any resolution refutation must be
  exponentially long.

  ## Key Definitions
  - `EntropyBarrier`: a multiplicative entropy drop across widths
  - `StepBoundedGrowth`: processes where each step increases a measure by ≤ Δ
  - `AbstractResolutionSystem`: abstract refutation system with entropy tracking
  - `freeEnergy`: free-energy functional bridging to statistical physics

  ## Key Theorems
  - `entropyBarrier_interval`: barrier persistence under width windows
  - `stepBoundedGrowth_iterate`: inductive bound on step-bounded processes
  - `steps_needed_for_entropy_crossing`: crossing requires sufficient steps
  - `crossing_time_lower_bound`: lower bound on crossing time
  - `entropy_barrier_lower_bound`: abstract resolution size lower bound
  - `freeEnergy_barrier_of_entropy_gap`: free-energy barrier from entropy gap
  - `freeEnergy_monotone_interval`: free-energy comparison on intervals

  ## Cross-Domain Connections
  - **Information theory**: entropy profile as information-theoretic measure
  - **Statistical physics**: free-energy landscape and phase transitions
  - **Proof complexity**: abstract lower bound engine for resolution
-/
import Mathlib

namespace EntropyBarrier

/-! ## Definition 1: Entropy Barrier -/

/-- An `EntropyBarrier` captures a multiplicative entropy drop in a profile `P : ℕ → ℝ`.
    It records three width scales `w0 ≤ wStar ≤ wMax` and a gap ratio `gapRatio`
    such that `P wStar ≤ gapRatio * P wMax`. When `gapRatio < 1`, this represents
    a genuine entropy bottleneck: the profile is suppressed at the intermediate
    width `wStar` relative to its value at `wMax`. -/
structure EntropyBarrierData (P : ℕ → ℝ) where
  w0 : ℕ
  wStar : ℕ
  wMax : ℕ
  hw0_le_wStar : w0 ≤ wStar
  hwStar_le_wMax : wStar ≤ wMax
  gapRatio : ℝ
  hgap_nonneg : 0 ≤ gapRatio
  hbarrier : P wStar ≤ gapRatio * P wMax

/-- A profile `P` has an entropy barrier if there exists barrier data with gap ratio < 1. -/
def HasEntropyBarrier (P : ℕ → ℝ) : Prop :=
  ∃ B : EntropyBarrierData P, B.gapRatio < 1

/-! ## Theorem 1: Barrier Persistence Under Width Windows -/

/-
**Barrier persistence**: if a monotone nonneg profile has a gap at `wStar`,
    then the gap persists for all widths below `wStar`. This is the formal device
    for turning a pointwise barrier into a window barrier.
-/
theorem entropyBarrier_interval
    {P : ℕ → ℝ}
    (hmono : Monotone P)
    (_hnonneg : ∀ w, 0 ≤ P w)
    {u v wStar W : ℕ}
    (huv : u ≤ v)
    (hvw : v ≤ wStar)
    (_hwW : wStar ≤ W)
    {ε : ℝ}
    (_hε : 0 ≤ ε)
    (hbar : P wStar ≤ ε * P W) :
    P u ≤ ε * P W ∧ P v ≤ ε * P W := by
  exact ⟨ le_trans ( hmono huv ) ( le_trans ( hmono hvw ) hbar ), le_trans ( hmono hvw ) hbar ⟩

/-! ## Definition 2: Step-Bounded Growth -/

/-- A process `E : ℕ → ℝ` has step-bounded growth by `Δ` if each step increases
    the measure by at most `Δ`. This models the constraint that each resolution
    derivation step can add at most a bounded amount of "accessible entropy". -/
def StepBoundedGrowth (E : ℕ → ℝ) (Δ : ℝ) : Prop :=
  ∀ t : ℕ, E (t + 1) ≤ E t + Δ

/-! ## Theorem 2: Abstract Crossing Lower Bound -/

/-
**Inductive accumulation lemma**: if growth is bounded by `Δ` per step,
    then after `T` steps the total increase is at most `T * Δ`.
-/
theorem stepBoundedGrowth_iterate
    {E : ℕ → ℝ} {Δ : ℝ}
    (hstep : StepBoundedGrowth E Δ)
    (T : ℕ) :
    E T ≤ E 0 + (T : ℝ) * Δ := by
  exact Nat.recOn T ( by norm_num ) fun n ihn => by norm_num; linarith [ hstep n ] ;

/-
**Crossing bound**: if growth per step is bounded by `Δ > 0`, and the process
    starts at or below `A` and ends at or above `B`, then `B ≤ A + T * Δ`.
-/
theorem steps_needed_for_entropy_crossing
    {E : ℕ → ℝ} {Δ A B : ℝ} {T : ℕ}
    (_hΔ : 0 < Δ)
    (hstep : StepBoundedGrowth E Δ)
    (hstart : E 0 ≤ A)
    (hend : B ≤ E T) :
    B ≤ A + (T : ℝ) * Δ := by
  linarith [ stepBoundedGrowth_iterate hstep T ]

/-
**Crossing time lower bound**: the number of steps `T` needed to cross from
    level `A` to level `B` is at least `(B - A) / Δ`. This is the abstract
    engine converting entropy barriers into proof-length lower bounds.
-/
theorem crossing_time_lower_bound
    {E : ℕ → ℝ} {Δ A B : ℝ} {T : ℕ}
    (hΔ : 0 < Δ)
    (hstep : StepBoundedGrowth E Δ)
    (hstart : E 0 ≤ A)
    (hend : B ≤ E T) :
    (B - A) / Δ ≤ T := by
  rw [ div_le_iff₀ ] <;> linarith [ steps_needed_for_entropy_crossing hΔ hstep hstart hend ]

/-! ## Definition 3: Abstract Resolution System -/

/-- An `AbstractResolutionSystem` models a proof system with:
    - a formula type,
    - an accessible entropy function tracking how much "information" is reachable
      after `t` derivation steps,
    - a terminal entropy threshold that must be reached for refutation,
    - a per-step growth bound on accessible entropy. -/
structure AbstractResolutionSystem (σ : Type) where
  Formula : Type
  accessibleEntropy : Formula → ℕ → ℝ
  terminalEntropy : Formula → ℝ
  growthBound : Formula → ℝ
  growth_axiom :
    ∀ F t, accessibleEntropy F (t + 1) ≤ accessibleEntropy F t + growthBound F

/-- A formula `F` is refutable within `T` steps if the terminal entropy threshold
    is reached by step `T`. -/
def RefutableWithin
    (S : AbstractResolutionSystem σ)
    (F : S.Formula) (T : ℕ) : Prop :=
  S.terminalEntropy F ≤ S.accessibleEntropy F T

/-! ## Theorem 3: Resolution Barrier Implies Size Lower Bound -/

/-
**Entropy barrier lower bound**: in any abstract resolution system, if the
    growth per step is bounded by `Δ > 0` and the initial accessible entropy is
    at most `A`, then any refutation of length `T` satisfies
    `T ≥ (terminalEntropy F - A) / Δ`.

    This is the formal engine: once instantiated for concrete resolution semantics,
    proving lower bounds reduces to calibrating `A`, `terminalEntropy`, and `Δ`.
-/
theorem entropy_barrier_lower_bound
    (S : AbstractResolutionSystem σ)
    (F : S.Formula)
    {A : ℝ} {T : ℕ}
    (hΔ : 0 < S.growthBound F)
    (hstart : S.accessibleEntropy F 0 ≤ A)
    (href : RefutableWithin S F T) :
    (S.terminalEntropy F - A) / S.growthBound F ≤ T := by
  convert crossing_time_lower_bound hΔ ( fun t => S.growth_axiom F t ) hstart ( by simpa using ( show S.terminalEntropy F ≤ S.accessibleEntropy F T from href ) ) using 1

/-! ## Definition 4: Free-Energy Functional (Cross-Domain Bridge) -/

/-- The **free-energy functional** `F_β(w) = β · w - P(w)`, where `β` is an
    inverse temperature parameter and `P` is the entropy profile.
    In the statistical physics interpretation:
    - `β · w` represents the energetic cost of width,
    - `P(w)` represents the entropic gain from derivable clauses at width `w`,
    - a barrier in free energy corresponds to a phase transition in proof search. -/
def freeEnergy (β : ℝ) (P : ℕ → ℝ) (w : ℕ) : ℝ :=
  β * (w : ℝ) - P w

/-! ## Theorem 4: Free-Energy Barrier from Entropy Gap -/

/-
**Free-energy barrier from entropy gap**: if the entropy profile has a gap at
    `wStar` (i.e., `P(wStar) ≤ ε · P(W)`), then the free energy at `wStar` is
    bounded below by `β · wStar - ε · P(W)`. When `ε` is small, this creates
    a high free-energy barrier that proof trajectories must cross.
-/
theorem freeEnergy_barrier_of_entropy_gap
    {P : ℕ → ℝ}
    (_hmono : Monotone P)
    {wStar W : ℕ}
    (_hw : wStar ≤ W)
    {β ε : ℝ}
    (_hβ : 0 ≤ β)
    (_hε : 0 ≤ ε)
    (hgap : P wStar ≤ ε * P W) :
    freeEnergy β P wStar ≥ β * (wStar : ℝ) - ε * P W := by
  simp only [freeEnergy, ge_iff_le, tsub_le_iff_right]; linarith

/-
**Free-energy monotone comparison**: on the interval below `wStar`,
    if `P` is monotone and has a gap, then the free-energy at any `u ≤ wStar`
    satisfies `freeEnergy β P u ≥ β * u - ε * P W`.
    This strengthens the barrier: the entire interval is "hard to cross."
-/
theorem freeEnergy_monotone_interval
    {P : ℕ → ℝ}
    (hmono : Monotone P)
    (_hnonneg : ∀ w, 0 ≤ P w)
    {u wStar W : ℕ}
    (hu : u ≤ wStar)
    (_hw : wStar ≤ W)
    {β ε : ℝ}
    (_hβ : 0 ≤ β)
    (_hε : 0 ≤ ε)
    (hgap : P wStar ≤ ε * P W) :
    freeEnergy β P u ≥ β * (u : ℝ) - ε * P W := by
  exact le_of_sub_nonneg ( by unfold freeEnergy; nlinarith [ hmono hu ] )

/-! ## Theorem 5: Free-Energy Drop Across Width Window -/

/-
**Free-energy drop**: comparing free energies between `u` and `W` when
    there is an entropy barrier. If `P` grows from `≤ ε P(W)` at `u` to `P(W)` at `W`,
    then the free-energy drop from `u` to `W` is at least `(1-ε)P(W) - β(W-u)`.
-/
theorem freeEnergy_drop_across_barrier
    {P : ℕ → ℝ}
    (_hmono : Monotone P)
    (_hnonneg : ∀ w, 0 ≤ P w)
    {u W : ℕ}
    (_huW : u ≤ W)
    {β ε : ℝ}
    (_hβ : 0 ≤ β)
    (_hε : 0 ≤ ε)
    (_hε1 : ε ≤ 1)
    (hgap : P u ≤ ε * P W) :
    freeEnergy β P u - freeEnergy β P W ≥ (1 - ε) * P W - β * ((W : ℝ) - (u : ℝ)) := by
  unfold freeEnergy; nlinarith ;

/-! ## Corollary: Combining Barrier Persistence with Crossing Bound -/

/-
**Combined barrier-crossing theorem**: if a monotone nonneg profile has a gap
    at `wStar` with ratio `ε`, and a step-bounded process must traverse from
    entropy level `P(w0)` to `P(wMax)`, then the number of steps is at least
    `(1 - ε) * P(wMax) / Δ`. This is the key theorem connecting the entropy
    barrier to proof length.
-/
theorem barrier_crossing_combined
    {P : ℕ → ℝ}
    (_hmono : Monotone P)
    (_hnonneg : ∀ w, 0 ≤ P w)
    {E : ℕ → ℝ} {Δ : ℝ} {T : ℕ}
    {wStar wMax : ℕ}
    (_hwStar : wStar ≤ wMax)
    {ε : ℝ}
    (_hε : 0 ≤ ε)
    (_hε1 : ε ≤ 1)
    (_hgap : P wStar ≤ ε * P wMax)
    (hΔ : 0 < Δ)
    (hstep : StepBoundedGrowth E Δ)
    (hstart : E 0 ≤ ε * P wMax)
    (hend : P wMax ≤ E T) :
    ((1 - ε) * P wMax) / Δ ≤ (T : ℝ) := by
  convert crossing_time_lower_bound hΔ hstep _ _ using 1;
  rotate_left;
  exacts [ ε * P wMax, P wMax, hstart, hend, by ring ]

end EntropyBarrier