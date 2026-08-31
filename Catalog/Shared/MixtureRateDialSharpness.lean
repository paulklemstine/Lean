import Mathlib
import Shared.MixtureRateDialCells
import Shared.MixtureRateDialBaseline
import Shared.MixtureRateDialResidueCarriers

/-!
# Sharpness of the rate-dial theorem (Part IV): the flatness hypothesis is the whole story

Parts II and III show that a mixture over a *flat-composition* grid removes `0 %`
of a positional excess.  A negative result is only informative if the hypothesis
it turns on is not vacuous.  This file proves the two sharpness statements.

* `positional_mixture_removes_excess` — with a genuinely **positional** reference
  family (one whose cells drift with `t`), a two-cell mixture removes the excess
  *completely*.  So the `0 %` removal of paper 242 is a fact about the
  divisibility grid, not an artefact of the mixture formalism.
* `stepCarrier_count_endpoints`, `stepCarrier_composition_not_flat`,
  `stepCarrier_not_periodicClass` — an explicit aperiodic carrier (`j ≥ 0`) whose
  window composition *does* depend on position, hence not `m`-periodic for any
  `m ≥ 1`; the class of position dials that Part III excludes is nonempty, and it
  lives exactly outside the residue world.
* `rate_dial_dichotomy` — the two halves side by side: flat composition forces
  `0 %` removal, non-flat composition can force `100 %` removal.
-/

namespace RateDial

open Finset

/-! ## A positional reference family removes the excess entirely -/

/-- A two-cell reference family that *is* allowed to drift with `t`: cell `false`
carries the flat shape `B`, cell `true` carries the measured profile `T`. -/
noncomputable def positionalRef (B T : ℝ → ℝ) : Bool → ℝ → ℝ :=
  fun c t => if c then T t else B t

/-- **Sharpness I.**  With a positional reference family the mixture reproduces
the measurement exactly, so the residual is constant and the mid-window excess is
removed in full (`100 %` removal).  Contrast Part II: over the divisibility grid
the same fitting procedure removes `0 %`. -/
theorem positional_mixture_removes_excess (B T : ℝ → ℝ) {t₀ t₁ : ℝ}
    (h₀ : T t₀ ≠ 0) (h₁ : T t₁ ≠ 0) :
    relExcess (resid T (mixPred (fun c => if c then 1 else 0) (positionalRef B T))) t₀ t₁ = 0 := by
  have hmix : ∀ t, mixPred (fun c => if c then (1:ℝ) else 0) (positionalRef B T) t = T t := by
    intro t
    simp [mixPred, positionalRef]
  simp only [relExcess, resid, hmix, div_self h₀, div_self h₁]
  norm_num

/-- The positional family is *not* of flat composition, whenever `T` is not
proportional to `B`: this is precisely the hypothesis the divisibility grid
satisfies and this family violates. -/
theorem positionalRef_not_flatComposition {B T : ℝ → ℝ} {t₀ t₁ : ℝ}
    (hnp : T t₀ * B t₁ ≠ T t₁ * B t₀) :
    ¬ ∃ w : Bool → ℝ, FlatComposition (positionalRef B T) w B := by
  rintro ⟨w, hflat⟩
  apply hnp
  have hT0 : T t₀ = w true * B t₀ := by simpa [positionalRef] using hflat true t₀
  have hT1 : T t₁ = w true * B t₁ := by simpa [positionalRef] using hflat true t₁
  rw [hT0, hT1]; ring

/-! ## An explicit aperiodic carrier with position-dependent composition -/

/-- The step carrier: the (aperiodic) classification `j ≥ 0`. -/
def stepCarrier : ℤ → Bool := fun j => decide (0 ≤ j)

/-- Its window composition is maximally position dependent: a window starting at
`0` is entirely in class `true`, a window ending at `-1` entirely in class
`false`. -/
theorem stepCarrier_count_endpoints (L : ℕ) :
    count stepCarrier 0 L true = L ∧ count stepCarrier (-(L : ℤ)) L true = 0 := by
  constructor
  · have : ∀ i ∈ Finset.range L, (if stepCarrier (0 + (i : ℤ)) = true then 1 else 0) = 1 := by
      intro i _
      simp [stepCarrier]
    rw [count, Finset.sum_congr rfl this]
    simp
  · have : ∀ i ∈ Finset.range L, (if stepCarrier (-(L : ℤ) + (i : ℤ)) = true then 1 else 0) = 0 := by
      intro i hi
      have hiL : (i : ℤ) < (L : ℤ) := by exact_mod_cast Finset.mem_range.mp hi
      have hneg : ¬ (0 : ℤ) ≤ -(L : ℤ) + (i : ℤ) := by omega
      simp [stepCarrier, hneg]
    rw [count, Finset.sum_congr rfl this]
    simp

/-- Consequently the step carrier has non-flat composition on every nonempty
window. -/
theorem stepCarrier_composition_not_flat {L : ℕ} (hL : 0 < L) :
    count stepCarrier 0 L true ≠ count stepCarrier (-(L : ℤ)) L true := by
  obtain ⟨h1, h2⟩ := stepCarrier_count_endpoints L
  omega

/-- **Sharpness II.**  The step carrier is not `m`-periodic for any `m ≥ 1`: the
position dials excluded by Part III really do exist, and they are exactly the
ones that cannot be written as a residue class of `j`. -/
theorem stepCarrier_not_periodicClass {m : ℕ} (hm : 0 < m) :
    ¬ PeriodicClass m stepCarrier := by
  intro hper
  have h0 := count_const_of_period_dvd hper (L := m) (q := 1) (by ring) 0 true
  have hneg := count_const_of_period_dvd hper (L := m) (q := 1) (by ring) (-(m : ℤ)) true
  exact stepCarrier_composition_not_flat hm (h0.trans hneg.symm)

/-! ## The dichotomy -/

/-- **Rate dial vs position dial, side by side.**  Over a flat-composition grid
(Part I: every divisibility / residue classification of `j² - N`) the mid-window
excess is preserved *exactly*, for every choice of per-cell rates; over a
positional family the very same fitting procedure annihilates it.  Divisibility
is a rate dial; whatever carries the `u* ≈ 0.65` excess is a position dial. -/
theorem rate_dial_dichotomy {C : Type*} [Fintype C] {S : C → ℝ → ℝ} {w : C → ℝ}
    {B T : ℝ → ℝ} {t₀ t₁ : ℝ}
    (hflat : FlatComposition S w B) (hT₀ : T t₀ ≠ 0) (hT₁ : T t₁ ≠ 0) (hB : B t₁ ≠ 0) :
    (∀ κ : C → ℝ, (∑ c, κ c * w c) ≠ 0 →
        relExcess (resid T (mixPred κ S)) t₀ t₁ = relExcess (resid T B) t₀ t₁) ∧
      relExcess (resid T (mixPred (fun c => if c then 1 else 0) (positionalRef B T))) t₀ t₁ = 0 := by
  refine ⟨fun κ hK => relExcess_invariant hflat κ hK hT₁ hB, ?_⟩
  exact positional_mixture_removes_excess B T hT₀ hT₁

end RateDial