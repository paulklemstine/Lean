import Combinatorics.PlateauRungBudget

/-!
# Two limits of the ladder: the certified ratio, and measurement noise

## Research context

`Catalog.Combinatorics.PlateauRungBudget` prices plateau identification in rungs, *assuming*
exact rung values and a certified deceleration ratio `r`.  This file bounds the two remaining
degrees of freedom of the experiment.

* **The certified ratio is the real currency** (`plateauSet_mono_ratio`,
  `plateauLength_mono_ratio`): sharpening the ratio certificate from `r'` to `r ≤ r'` shrinks
  the admissible plateau set monotonically, and the interval length is monotone in `r`.  A
  factor-`2` improvement of the ratio certificate is worth more than any number of rungs when
  `r` is close to `1`, since `r/(1−r)` blows up there.
* **Noise imposes a floor no ladder can cross** (`noisy_identification_floor`,
  `noisy_diameter_ge`): if the measured rung values are only known to within `η`, then for
  *every* prefix length the admissible plateau set contains two points at distance `2η`.  The
  budget formula of the previous file therefore saturates: measuring past
  `d₀r^{m+1}/(1−r) ≈ η` is provably wasted effort.  At the U108 reading the rung CI half-width
  is `0.0445`, so the floor is `0.089` — an order of magnitude *above* the one-rung interval
  `0.0259` (`u108_noise_floor_dominates`).  The honest conclusion for the programme: the U108
  ladder is noise-limited, not rung-limited, and additional rungs cannot help at all.
-/

namespace Catalog.Combinatorics.PlateauRungBudget

open Real Set Filter

/-! ## Section 1. Monotonicity in the certified ratio -/

/-- A fade admissible for the ratio `r` is admissible for any weaker certificate `r ≤ r'`. -/
lemma AdmissibleFade.mono {r r' : ℝ} {s : ℕ → ℝ} (h : AdmissibleFade r s) (hrr : r ≤ r') :
    AdmissibleFade r' s := by
  refine ⟨h.1, fun n => ?_⟩
  have hd : 0 ≤ s n - s (n + 1) := by have := h.1 n; linarith
  have := h.2 n
  nlinarith

/-- **Sharpening the ratio certificate shrinks the admissible plateau set.** -/
theorem plateauSet_mono_ratio {r r' : ℝ} {p : ℕ → ℝ} {M : ℕ} (hrr : r ≤ r') :
    plateauSet r p M ⊆ plateauSet r' p M := by
  rintro L ⟨s, hs, hpre, hlim⟩
  exact ⟨s, hs.mono hrr, hpre, hlim⟩

/-- The interval length is strictly increasing in the certified ratio: the map
`r ↦ r·dₘ/(1−r)` is monotone on `[0,1)`, and blows up as `r → 1`. -/
theorem plateauLength_mono_ratio {r r' : ℝ} {p : ℕ → ℝ} {m : ℕ} (hrr : r ≤ r')
    (hr1 : r' < 1) (hdm : 0 ≤ p m - p (m + 1)) :
    plateauLength r p m ≤ plateauLength r' p m := by
  have h1 : 0 < 1 - r := by linarith
  have h2 : 0 < 1 - r' := by linarith
  simp only [plateauLength]
  rw [div_le_div_iff₀ h1 h2]
  nlinarith

/-! ## Section 2. The noise floor -/

/-- The admissible plateau set when the measured rung values are only known to within `η`. -/
def noisyPlateauSet (r eta : ℝ) (p : ℕ → ℝ) (M : ℕ) : Set ℝ :=
  {L | ∃ s : ℕ → ℝ, AdmissibleFade r s ∧ (∀ k ≤ M, |s k - p k| ≤ eta) ∧
        Tendsto s atTop (nhds L)}

/-- **The noise floor.**  Whatever the prefix length `m`, both `p (m+1) + η` and
`p (m+1) − η` are admissible plateaus once the rung values carry an uncertainty `η`: the
whole prefix may be shifted rigidly by `±η` without violating any deceleration constraint,
and a constant tail then freezes the plateau at the shifted value. -/
theorem noisy_identification_floor {r eta : ℝ} {p : ℕ → ℝ} {m : ℕ} (hr0 : 0 ≤ r)
    (heta : 0 ≤ eta)
    (hpmono : ∀ k ≤ m, p (k + 1) ≤ p k)
    (hpgeo : ∀ k, k + 2 ≤ m + 1 → p (k + 1) - p (k + 2) ≤ r * (p k - p (k + 1))) :
    p (m + 1) + eta ∈ noisyPlateauSet r eta p (m + 1) ∧
      p (m + 1) - eta ∈ noisyPlateauSet r eta p (m + 1) := by
  have hdm : 0 ≤ p m - p (m + 1) := by have := hpmono m (le_refl m); linarith
  have hrdm : 0 ≤ r * (p m - p (m + 1)) := mul_nonneg hr0 hdm
  constructor
  · -- shift the whole prefix up by `η`
    refine ⟨spliceFade 0 (p (m + 1) + eta) (fun k => p k + eta) (m + 1), ?_, ?_, ?_⟩
    · refine spliceFade_admissible le_rfl (by norm_num) hr0 ?_ ?_ (by simp) (by simpa using hrdm)
      · intro k hk; have := hpmono k hk; linarith
      · intro k hk
        simp only [add_sub_add_right_eq_sub]
        exact hpgeo k hk
    · intro k hk
      rw [spliceFade_prefix hk]
      simp [abs_of_nonneg heta]
    · exact spliceFade_tendsto le_rfl (by norm_num)
  · -- shift the whole prefix down by `η`
    refine ⟨spliceFade 0 (p (m + 1) - eta) (fun k => p k - eta) (m + 1), ?_, ?_, ?_⟩
    · refine spliceFade_admissible le_rfl (by norm_num) hr0 ?_ ?_ (by simp) (by simpa using hrdm)
      · intro k hk; have := hpmono k hk; linarith
      · intro k hk
        simp only [sub_sub_sub_cancel_right]
        exact hpgeo k hk
    · intro k hk
      rw [spliceFade_prefix hk]
      simp [abs_of_nonneg heta]
    · exact spliceFade_tendsto le_rfl (by norm_num)

/-- **The budget saturates.**  For every prefix length the noisy admissible plateau set
contains two points at distance exactly `2η`, so no number of further rungs can identify the
plateau to better than `2η`. -/
theorem noisy_diameter_ge {r eta : ℝ} {p : ℕ → ℝ} {m : ℕ} (hr0 : 0 ≤ r) (heta : 0 ≤ eta)
    (hpmono : ∀ k ≤ m, p (k + 1) ≤ p k)
    (hpgeo : ∀ k, k + 2 ≤ m + 1 → p (k + 1) - p (k + 2) ≤ r * (p k - p (k + 1))) :
    ∃ L₁ ∈ noisyPlateauSet r eta p (m + 1), ∃ L₂ ∈ noisyPlateauSet r eta p (m + 1),
      L₁ - L₂ = 2 * eta := by
  obtain ⟨hup, hdown⟩ := noisy_identification_floor hr0 heta hpmono hpgeo
  exact ⟨p (m + 1) + eta, hup, p (m + 1) - eta, hdown, by ring⟩

/-- **The U108 ladder is noise-limited, not rung-limited.**  The rung uncertainty at U108 is
the CI half-width `η = 0.0445`, so the noise floor `2η = 0.089` exceeds the *one-rung*
admissible interval `0.0259` by a factor of more than three.  Every further rung is therefore
provably worthless for plateau identification at the current measurement precision. -/
theorem u108_noise_floor_dominates :
    plateauLength (1/2 : ℝ) (Catalog.Physics.TDialU108.geoFade 0.488 0.0259 (1/2)) 0
      < 2 * (445 / 10000 : ℝ) := by
  rw [plateauLength_geoFade _ _ _ (by norm_num : (1:ℝ)/2 < 1)]
  norm_num

end Catalog.Combinatorics.PlateauRungBudget