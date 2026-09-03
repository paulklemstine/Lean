import Mathlib
import Probability.PPowMultiseedLift

/-!
# `ΔR² = 1` on the smooth tower: an exact variance decomposition for the prime-power lift

Third cycle of the PPOW-MULTISEED study (round-46 #2, experiment 506).  The
first two files established that the prime-power feature `ppExcess` is a
non-negative arithmetic signal, orthogonal to the squarefree part, with an exact
von Mangoldt window law.  Here we compute an **honest coefficient of
determination** for the two competing models on an explicit design, and show
that the empirically observed lift is not merely positive but *maximal* in the
smooth regime.

The design is the `2`-smooth tower `{2, 4, 8, …, 2^m}` (the extreme small-`u`
regime).  On it the base feature is **constant** (`rad (2^k) = 2`), while the
target `ppExcess (2^k) = (k-1) log 2` is not.  Consequently:

* `sumSqDev_le_sumSq_sub_const` — the classical fact that the mean minimises the
  squared error, proved here from scratch (`sum_sq_expand`).
* `towerTSS_eq` — the exact total sum of squares of the design,
  `TSS = m(m²-1)/12 · (log 2)²`, obtained from the closed forms
  `∑_{j<m} j = m(m-1)/2` and `∑_{j<m} j² = m(m-1)(2m-1)/6`.
* `R2_base_nonpos` — **no** model in the base feature alone attains a positive
  `R²` on this design: `R² ≤ 0` for every `f`.
* `R2_pp_eq_one` — the prime-power model attains `R² = 1`.
* `deltaR2_ge_one` — hence the lift `ΔR² ≥ 1` (and equals `1` for the best base
  model): on the smoothest design the prime-power feature explains *all* of the
  variance that the base feature explains *none* of.

This is the sharp form of the empirical statement "the lift is larger at smaller
`u`": as the design becomes smoother the base feature degenerates to a constant
and the entire explanatory power migrates to the prime-power term.
-/

namespace PPowMultiseed

open Finset

/-! ## Least squares generalities -/

theorem sum_sq_expand {ι : Type*} (S : Finset ι) (y : ι → ℝ) (b : ℝ) :
    ∑ i ∈ S, (y i - b) ^ 2 = (∑ i ∈ S, (y i) ^ 2) - 2 * b * (∑ i ∈ S, y i) + S.card * b ^ 2 := by
  simp only [sub_sq, Finset.sum_add_distrib, Finset.sum_sub_distrib, Finset.sum_const,
    nsmul_eq_mul, show ∀ x : ι, 2 * y x * b = (2 * b) * y x from fun x => by ring,
    ← Finset.mul_sum]

/-- The mean minimises the squared error: the total sum of squares is a lower
bound for the residual of any constant predictor. -/
theorem sumSqDev_le_sumSq_sub_const {ι : Type*} (S : Finset ι) (y : ι → ℝ)
    (hS : 0 < S.card) (c : ℝ) :
    ∑ i ∈ S, (y i - (∑ j ∈ S, y j) / S.card) ^ 2 ≤ ∑ i ∈ S, (y i - c) ^ 2 := by
  have hn : (0 : ℝ) < S.card := by exact_mod_cast hS
  rw [sum_sq_expand, sum_sq_expand]
  have key : (0 : ℝ) ≤ ((S.card : ℝ)) * (c - (∑ j ∈ S, y j) / S.card) ^ 2 := by positivity
  have hexp : ((S.card : ℝ)) * (c - (∑ j ∈ S, y j) / S.card) ^ 2
      = (S.card : ℝ) * c ^ 2 - 2 * c * (∑ j ∈ S, y j) + (∑ j ∈ S, y j) ^ 2 / S.card := by
    field_simp; ring
  have h2 : ((S.card : ℝ)) * ((∑ j ∈ S, y j) / S.card) ^ 2 = (∑ j ∈ S, y j) ^ 2 / S.card := by
    field_simp
  have h3 : 2 * ((∑ j ∈ S, y j) / (S.card : ℝ)) * (∑ i ∈ S, y i)
      = 2 * ((∑ j ∈ S, y j) ^ 2 / S.card) := by field_simp
  rw [h2, h3]
  rw [hexp] at key
  linarith

/-- Total sum of squares of a finite design. -/
noncomputable def TSS {ι : Type*} (S : Finset ι) (y : ι → ℝ) : ℝ :=
  ∑ i ∈ S, (y i - (∑ j ∈ S, y j) / S.card) ^ 2

/-- Coefficient of determination of a predictor `pred` for the target `y`. -/
noncomputable def R2 {ι : Type*} (S : Finset ι) (y pred : ι → ℝ) : ℝ :=
  1 - (∑ i ∈ S, (y i - pred i) ^ 2) / TSS S y

/-! ## Closed forms for the power sums -/

theorem sum_range_cast (m : ℕ) : ∑ j ∈ Finset.range m, (j : ℝ) = m * (m - 1) / 2 := by
  induction m with
  | zero => simp
  | succ n ih =>
    rw [Finset.sum_range_succ, ih]
    push_cast
    ring

theorem sum_range_sq_cast (m : ℕ) :
    ∑ j ∈ Finset.range m, (j : ℝ) ^ 2 = m * (m - 1) * (2 * m - 1) / 6 := by
  induction m with
  | zero => simp
  | succ n ih =>
    rw [Finset.sum_range_succ, ih]
    push_cast
    ring

/-! ## The `2`-smooth tower design -/

/-- The design `{2, 4, 8, …, 2^m}`: the extreme smooth (small-`u`) regime. -/
def towerDesign (m : ℕ) : Finset ℕ := (Finset.Icc 1 m).image (fun k => 2 ^ k)

theorem sum_towerDesign (m : ℕ) (g : ℕ → ℝ) :
    ∑ n ∈ towerDesign m, g n = ∑ k ∈ Finset.Icc 1 m, g (2 ^ k) := by
  unfold towerDesign
  refine Finset.sum_image ?_
  intro x _ y _ h
  exact Nat.pow_right_injective le_rfl h

theorem card_towerDesign (m : ℕ) : (towerDesign m).card = m := by
  unfold towerDesign
  rw [Finset.card_image_of_injOn (fun x _ y _ h => Nat.pow_right_injective le_rfl h),
    Nat.card_Icc]
  omega

theorem sum_ppExcess_towerDesign (m : ℕ) :
    ∑ n ∈ towerDesign m, ppExcess n = ((m : ℝ) * (m - 1) / 2) * Real.log 2 := by
  rw [sum_towerDesign, smoothTower_mass]

/-- The mean of the target over the tower design. -/
theorem mean_towerDesign {m : ℕ} (hm : 1 ≤ m) :
    (∑ n ∈ towerDesign m, ppExcess n) / (towerDesign m).card
      = (((m : ℝ) - 1) / 2) * Real.log 2 := by
  rw [sum_ppExcess_towerDesign, card_towerDesign]
  have hm0 : (0 : ℝ) < m := by exact_mod_cast hm
  field_simp

/-- **The exact total sum of squares of the tower design**:
`TSS = m(m²-1)/12 · (log 2)²`. -/
theorem towerTSS_eq {m : ℕ} (hm : 1 ≤ m) :
    TSS (towerDesign m) ppExcess = ((m : ℝ) * ((m : ℝ) ^ 2 - 1) / 12) * (Real.log 2) ^ 2 := by
  unfold TSS
  rw [mean_towerDesign hm]
  rw [sum_towerDesign]
  have hterm : ∀ k ∈ Finset.Icc 1 m,
      (ppExcess (2 ^ k) - (((m : ℝ) - 1) / 2) * Real.log 2) ^ 2
        = (((k : ℝ) - 1) - ((m : ℝ) - 1) / 2) ^ 2 * (Real.log 2) ^ 2 := by
    intro k hk
    simp only [Finset.mem_Icc] at hk
    rw [ppExcess_two_pow hk.1]
    ring
  rw [Finset.sum_congr rfl hterm, ← Finset.sum_mul]
  have hshift : ∑ k ∈ Finset.Icc 1 m, (((k : ℝ) - 1) - ((m : ℝ) - 1) / 2) ^ 2
      = ∑ j ∈ Finset.range m, ((j : ℝ) - ((m : ℝ) - 1) / 2) ^ 2 := by
    rw [show Finset.Icc 1 m = Finset.image (fun j => j + 1) (Finset.range m) from by
      ext x; simp only [Finset.mem_Icc, Finset.mem_image, Finset.mem_range]
      constructor
      · rintro ⟨h1, h2⟩; exact ⟨x - 1, by omega, by omega⟩
      · rintro ⟨j, hj, rfl⟩; omega]
    rw [Finset.sum_image (by intro x _ y _ h; simpa using h)]
    refine Finset.sum_congr rfl fun j _ => ?_
    push_cast
    ring
  rw [hshift]
  have hexpand : ∑ j ∈ Finset.range m, ((j : ℝ) - ((m : ℝ) - 1) / 2) ^ 2
      = (∑ j ∈ Finset.range m, (j : ℝ) ^ 2)
        - 2 * (((m : ℝ) - 1) / 2) * (∑ j ∈ Finset.range m, (j : ℝ))
        + (Finset.range m).card * (((m : ℝ) - 1) / 2) ^ 2 :=
    sum_sq_expand _ _ _
  rw [hexpand, sum_range_cast, sum_range_sq_cast, Finset.card_range]
  ring

theorem towerTSS_pos {m : ℕ} (hm : 2 ≤ m) : 0 < TSS (towerDesign m) ppExcess := by
  rw [towerTSS_eq (by omega)]
  have hm2 : (2 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm
  have hlog : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have h1 : 0 < (m : ℝ) * ((m : ℝ) ^ 2 - 1) / 12 := by nlinarith
  positivity

/-! ## The two models on the tower design -/

/-- The base feature is *constant* on the tower: `rad (2^k) = 2`. -/
theorem rad_towerDesign {m n : ℕ} (hn : n ∈ towerDesign m) : rad n = 2 := by
  unfold towerDesign at hn
  simp only [Finset.mem_image, Finset.mem_Icc] at hn
  obtain ⟨k, hk, rfl⟩ := hn
  exact rad_prime_pow Nat.prime_two (by omega)

/-- **No base-only model has positive `R²` on the smooth tower.** -/
theorem R2_base_nonpos {m : ℕ} (hm : 2 ≤ m) (f : ℕ → ℝ) :
    R2 (towerDesign m) ppExcess (fun n => f (rad n)) ≤ 0 := by
  have hcard : 0 < (towerDesign m).card := by rw [card_towerDesign]; omega
  have hconst : ∑ n ∈ towerDesign m, (ppExcess n - f (rad n)) ^ 2
      = ∑ n ∈ towerDesign m, (ppExcess n - f 2) ^ 2 :=
    Finset.sum_congr rfl fun n hn => by rw [rad_towerDesign hn]
  have hle : TSS (towerDesign m) ppExcess
      ≤ ∑ n ∈ towerDesign m, (ppExcess n - f (rad n)) ^ 2 := by
    rw [hconst]
    exact sumSqDev_le_sumSq_sub_const _ _ hcard _
  have hpos := towerTSS_pos hm
  unfold R2
  rw [sub_nonpos, le_div_iff₀ hpos]
  linarith

/-- **The prime-power model attains `R² = 1`.**  (By `towerTSS_pos` the design
has strictly positive total sum of squares whenever `2 ≤ m`, so this value of
`R²` is the meaningful one and not an artefact of a degenerate denominator.) -/
theorem R2_pp_eq_one (m : ℕ) : R2 (towerDesign m) ppExcess ppExcess = 1 := by
  unfold R2
  simp

/-- **`ΔR² = 1` on the smooth tower.**  The prime-power feature explains the
entire variance that the base feature cannot touch: the measured positive lift
is, in the smoothest regime, the maximal possible one. -/
theorem deltaR2_ge_one {m : ℕ} (hm : 2 ≤ m) (f : ℕ → ℝ) :
    1 ≤ R2 (towerDesign m) ppExcess ppExcess
          - R2 (towerDesign m) ppExcess (fun n => f (rad n)) := by
  have h1 := R2_pp_eq_one m
  have h2 := R2_base_nonpos hm f
  linarith

end PPowMultiseed