/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Bridges.DeepestRungTwoSeed256

/-!
# The random-`k` control, the empirical exponent, and grid resolution (NET-43, cycle 2)

This is the second research cycle on the NET-43 round.  Cycle 1
(`Bridges.DeepestRungTwoSeed256`) proved that top-`k` selection dominates every width-`k`
selection, that concentration forces a knee floor, that a fail/pass pair brackets the knee,
and that the concave `d^(2/3)` law is sub-linear with affine fits over-predicting at depth.

Three questions were left open by cycle 1, and are answered here.

1. **How large is the random-`k` control's handicap, quantitatively?**  Cycle 1 only gave a
   sign (`mass_le_bestMass`, `mass_lt_bestMass_of_swap`).  Here we compute the *exact*
   expected mass of a uniformly random width-`k` selection: it is `k / n`, by a
   double-counting identity (`sum_mass_powersetCard`, `expected_random_mass`).  Hence the
   selection gap of the Part-B2 control is at least `topMass − k/n`
   (`bestMass_ge_uniform_fraction`, `net43_random_control_gap`).  At the NET-43 cell
   `(n, k) = (512, 256)` the random control captures mass `0.5` against the measured
   `0.922`: a mass gap of at least `0.42`, which is why the accuracy gap had to be positive.

2. **What exponent do the measured per-doubling ratios actually imply?**  The round reports
   ratios `1.50 → 1.58 → 1.68` across three depth doublings.  Their product `3.9816` is
   *strictly below* `4 = 2^2`, so the empirical exponent `a` defined by `2^(3a) = 3.9816`
   obeys `0.6 < a < 2/3` (`empirical_exponent_bracket`).  The `2/3` law is therefore an
   upper envelope for the measured leg, not an exact fit — a falsifiable refinement.

3. **How precise can a knee measured on a multiplicative grid ever be?**  A sweep grid with
   ratio `ρ` caps the achievable relative uncertainty at `1 − 1/ρ`
   (`knee_grid_resolution`).  At NET-43's finest local ratio `256/240 = 16/15` this is
   `1/16 = 6.25%`, so the reported "exact reproduction" is exact only up to the grid, and
   two seeds landing in the same bracket differ by less than `16`
   (`two_seed_spread_lt_grid_step`).

## Main results

* `card_powersetCard_filter_mem` — subsets of size `k` through a fixed key
* `sum_mass_powersetCard` — double-counting identity for total selected mass
* `expected_random_mass` — expected random-`k` mass is exactly `k / n`
* `bestMass_ge_uniform_fraction`, `net43_random_control_gap`
* `empirical_exponent_bracket` — `0.6 < a < 2/3` for the measured doubling ratios
* `knee_grid_resolution`, `two_seed_spread_lt_grid_step`
-/

namespace Bridges.DeepestRungTwoSeed256

open Finset

variable {n : ℕ}

/-! ## A. The random-`k` control -/

/-- The number of `k`-element subsets containing a fixed key is `C(n-1, k-1)`. -/
lemma card_powersetCard_filter_mem {k : ℕ} (hk : 1 ≤ k) (i : Fin n) :
    (((Finset.univ : Finset (Fin n)).powersetCard k).filter (fun S => i ∈ S)).card
      = (n - 1).choose (k - 1) := by
  classical
  have key : (((Finset.univ : Finset (Fin n)).powersetCard k).filter (fun S => i ∈ S)).card
      = (((Finset.univ : Finset (Fin n)).erase i).powersetCard (k - 1)).card := by
    refine Finset.card_bij' (fun S _ => S.erase i) (fun T _ => insert i T) ?_ ?_ ?_ ?_
    · intro S hS
      simp only [Finset.mem_filter, Finset.mem_powersetCard] at hS
      simp only [Finset.mem_powersetCard]
      refine ⟨Finset.erase_subset_erase _ hS.1.1, ?_⟩
      rw [Finset.card_erase_of_mem hS.2, hS.1.2]
    · intro T hT
      simp only [Finset.mem_powersetCard] at hT
      have hiT : i ∉ T := fun h => (Finset.mem_erase.1 (hT.1 h)).1 rfl
      simp only [Finset.mem_filter, Finset.mem_powersetCard]
      refine ⟨⟨Finset.subset_univ _, ?_⟩, Finset.mem_insert_self _ _⟩
      rw [Finset.card_insert_of_notMem hiT, hT.2]
      omega
    · intro S hS
      simp only [Finset.mem_filter] at hS
      exact Finset.insert_erase hS.2
    · intro T hT
      simp only [Finset.mem_powersetCard] at hT
      have hiT : i ∉ T := fun h => (Finset.mem_erase.1 (hT.1 h)).1 rfl
      exact Finset.erase_insert hiT
  rw [key, Finset.card_powersetCard, Finset.card_erase_of_mem (Finset.mem_univ i),
    Finset.card_univ, Fintype.card_fin]

/-- **Double counting.**  Summing the captured mass over *all* width-`k` selections gives
`C(n-1, k-1)`, independently of the attention profile. -/
theorem sum_mass_powersetCard (a : AttnDist n) {k : ℕ} (hk : 1 ≤ k) :
    ∑ S ∈ (Finset.univ : Finset (Fin n)).powersetCard k, ∑ i ∈ S, a.p i
      = ((n - 1).choose (k - 1) : ℝ) := by
  classical
  have hswap : ∑ S ∈ (Finset.univ : Finset (Fin n)).powersetCard k, ∑ i ∈ S, a.p i
      = ∑ i : Fin n, ∑ S ∈ (Finset.univ : Finset (Fin n)).powersetCard k,
          (if i ∈ S then a.p i else 0) := by
    rw [Finset.sum_comm]
    refine Finset.sum_congr rfl (fun S _ => ?_)
    rw [Finset.sum_ite_mem, Finset.univ_inter]
  rw [hswap]
  have hinner : ∀ i : Fin n,
      ∑ S ∈ (Finset.univ : Finset (Fin n)).powersetCard k, (if i ∈ S then a.p i else 0)
        = a.p i * ((n - 1).choose (k - 1) : ℝ) := by
    intro i
    rw [← Finset.sum_filter, Finset.sum_const, card_powersetCard_filter_mem hk i,
      nsmul_eq_mul, mul_comm]
  simp only [hinner, ← Finset.sum_mul, a.sum_one, one_mul]

/-- **Expected mass of a uniformly random width-`k` selection is `k / n`.**  (The average is
over the `C(n,k)` admissible selections.) -/
theorem expected_random_mass (a : AttnDist n) {k : ℕ} (hk : 1 ≤ k) (hkn : k ≤ n) :
    (∑ S ∈ (Finset.univ : Finset (Fin n)).powersetCard k, ∑ i ∈ S, a.p i)
      / ((n.choose k : ℝ)) = (k : ℝ) / n := by
  obtain ⟨m, rfl⟩ : ∃ m, n = m + 1 := ⟨n - 1, by omega⟩
  obtain ⟨j, rfl⟩ : ∃ j, k = j + 1 := ⟨k - 1, by omega⟩
  have hid : (m + 1) * (m.choose j) = ((m + 1).choose (j + 1)) * (j + 1) :=
    Nat.add_one_mul_choose_eq m j
  have hchoose_pos : 0 < (m + 1).choose (j + 1) := Nat.choose_pos (by omega)
  have hcR : ((m + 1).choose (j + 1) : ℝ) ≠ 0 := Nat.cast_ne_zero.2 hchoose_pos.ne'
  have hnR : ((m : ℝ) + 1) ≠ 0 := by positivity
  rw [sum_mass_powersetCard a hk]
  simp only [Nat.add_sub_cancel]
  rw [div_eq_div_iff hcR (by push_cast; exact hnR)]
  have := congrArg (fun t : ℕ => (t : ℝ)) hid
  push_cast at this ⊢
  linarith [this]

/-- **The top-`k` selection beats the random-`k` control's average.**  Consequently the
Part-B2 selection gap is bounded below by `topMass − k/n`. -/
theorem bestMass_ge_uniform_fraction (a : AttnDist n) {k : ℕ} (hk : 1 ≤ k) (hkn : k ≤ n) :
    (k : ℝ) / n ≤ bestMass a k := by
  classical
  by_contra hcon
  push_neg at hcon
  have hne : ((Finset.univ : Finset (Fin n)).powersetCard k).Nonempty := by
    rw [← Finset.card_pos, Finset.card_powersetCard, Finset.card_univ, Fintype.card_fin]
    exact Nat.choose_pos hkn
  have hlt : ∀ S ∈ (Finset.univ : Finset (Fin n)).powersetCard k,
      ∑ i ∈ S, a.p i < (k : ℝ) / n := by
    intro S hS
    have hcard : S.card ≤ k := le_of_eq (Finset.mem_powersetCard.1 hS).2
    exact lt_of_le_of_lt (mass_le_bestMass a hcard) hcon
  have hsum : ∑ S ∈ (Finset.univ : Finset (Fin n)).powersetCard k, ∑ i ∈ S, a.p i
      < ∑ _S ∈ (Finset.univ : Finset (Fin n)).powersetCard k, (k : ℝ) / n :=
    Finset.sum_lt_sum_of_nonempty hne hlt
  rw [Finset.sum_const, Finset.card_powersetCard, Finset.card_univ, Fintype.card_fin,
    nsmul_eq_mul] at hsum
  have havg := expected_random_mass a hk hkn
  have hcpos : (0:ℝ) < (n.choose k : ℝ) := by
    exact_mod_cast Nat.choose_pos hkn
  rw [div_eq_iff hcpos.ne'] at havg
  rw [havg] at hsum
  linarith

/-- **NET-43 random-`k` control, quantified.**  At `(n, k) = (512, 256)` a random width-`256`
selection captures mass exactly `1/2` on average, while the measured top-`256` mass is
`0.922`; the mass-level selection gap is therefore at least `0.42`. -/
theorem net43_random_control_gap (a : AttnDist 512) (hmass : (0.922 : ℝ) ≤ bestMass a 256) :
    (0.42 : ℝ) ≤ bestMass a 256 - (256 : ℝ) / 512 := by
  have := bestMass_ge_uniform_fraction a (k := 256) (by norm_num) (by norm_num)
  norm_num at this ⊢
  linarith

/-! ## B. What exponent do the measured doubling ratios imply? -/

/-- The product of NET-43's three measured per-doubling ratios. -/
def measuredRatioProduct : ℝ := 1.50 * 1.58 * 1.68

lemma measuredRatioProduct_lt_four : measuredRatioProduct < 4 := by
  norm_num [measuredRatioProduct]

lemma two_rpow_two : (2:ℝ) ^ (2:ℝ) = 4 := by
  rw [show (2:ℝ) = ((2:ℕ):ℝ) by norm_num, Real.rpow_natCast]
  norm_num

lemma two_rpow_nine_fifths_lt : (2:ℝ) ^ ((9:ℝ)/5) < measuredRatioProduct := by
  set x : ℝ := (2:ℝ) ^ ((9:ℝ)/5) with hx
  have hxpos : 0 < x := Real.rpow_pos_of_pos (by norm_num) _
  have hx5 : x ^ (5:ℕ) = 512 := by
    rw [hx, ← Real.rpow_natCast ((2:ℝ) ^ ((9:ℝ)/5)) 5, ← Real.rpow_mul (by norm_num)]
    norm_num
  by_contra hcon
  push_neg at hcon
  have h1 : (3.98 : ℝ) ≤ x := by
    have : (3.98 : ℝ) ≤ measuredRatioProduct := by norm_num [measuredRatioProduct]
    linarith
  have h2 : (3.98 : ℝ) ^ (5:ℕ) ≤ x ^ (5:ℕ) := by
    gcongr
  rw [hx5] at h2
  norm_num at h2

/-- **Empirical exponent bracket.**  The exponent `a` implied by the three measured
per-doubling ratios (`2^(3a)` equal to their product `3.9816`) satisfies `0.6 < a < 2/3`:
sub-linear, and strictly below the fitted `2/3` envelope. -/
theorem empirical_exponent_bracket {a : ℝ} (ha : (2:ℝ) ^ (3 * a) = measuredRatioProduct) :
    0.6 < a ∧ a < 2 / 3 := by
  have h1 : (1:ℝ) < 2 := by norm_num
  constructor
  · have hlt : (2:ℝ) ^ ((9:ℝ)/5) < (2:ℝ) ^ (3 * a) := by
      rw [ha]; exact two_rpow_nine_fifths_lt
    have := (Real.rpow_lt_rpow_left_iff h1).1 hlt
    linarith
  · have hlt : (2:ℝ) ^ (3 * a) < (2:ℝ) ^ (2:ℝ) := by
      rw [ha, two_rpow_two]; exact measuredRatioProduct_lt_four
    have := (Real.rpow_lt_rpow_left_iff h1).1 hlt
    linarith

/-! ## C. Grid resolution: how exact can "exact reproduction" be? -/

/-- **Grid resolution bound.**  If the knee is bracketed by consecutive grid points `a < k ≤ b`
of a multiplicative grid of ratio `ρ` (so `b ≤ ρ · a`), the residual uncertainty in reporting
`b` as the knee is at most `(1 - 1/ρ) · b`. -/
theorem knee_grid_resolution {ρ : ℝ} {a b k : ℕ} (hρ : 1 ≤ ρ) (ha : 0 < a)
    (hgrid : (b : ℝ) ≤ ρ * a) (hak : a < k) (hkb : k ≤ b) :
    |(b : ℝ) - k| ≤ (1 - 1 / ρ) * b := by
  have haR : (0:ℝ) < (a : ℝ) := by exact_mod_cast ha
  have hρpos : (0:ℝ) < ρ := lt_of_lt_of_le one_pos hρ
  have hkR : (a : ℝ) ≤ (k : ℝ) := by exact_mod_cast hak.le
  have hb : (b : ℝ) / ρ ≤ (a : ℝ) := by
    rw [div_le_iff₀ hρpos]
    linarith [hgrid]
  have hrw : (1 - 1 / ρ) * b = (b : ℝ) - (b : ℝ) / ρ := by field_simp
  have hkbR : (k : ℝ) ≤ (b : ℝ) := by exact_mod_cast hkb
  rw [abs_of_nonneg (by linarith : (0:ℝ) ≤ (b : ℝ) - k), hrw]
  linarith

/-- At NET-43's finest local grid ratio `256/240 = 16/15`, a knee reported as `256` carries at
most `16` of absolute uncertainty. -/
theorem net43_grid_resolution {k : ℕ} (hak : 240 < k) (hkb : k ≤ 256) :
    |(256 : ℝ) - k| ≤ 16 := by
  have := knee_grid_resolution (ρ := 16/15) (a := 240) (b := 256) (k := k)
    (by norm_num) (by norm_num) (by norm_num) hak hkb
  norm_num at this
  linarith

/-- **Two-seed spread.**  Two seeds whose knees fall in the same fail/pass bracket differ by
strictly less than the bracket width; for NET-43's `(240, 256]` bracket this is `< 16`. -/
theorem two_seed_spread_lt_grid_step {k₁ k₂ : ℕ}
    (h₁ : 240 < k₁) (h₁' : k₁ ≤ 256) (h₂ : 240 < k₂) (h₂' : k₂ ≤ 256) :
    (k₁ : ℤ) - k₂ < 16 ∧ (k₂ : ℤ) - k₁ < 16 := by
  omega

/-! ## D. Lab notes (cycle 2)

Derived quantities used above, all from the NET-43 round:

* `n = ctx = 512`, `k* = 256`, so the uniformly random width-`k` control captures expected
  mass `k/n = 0.5`, against measured top-`256` mass `0.922`: mass gap `≥ 0.42`
  (`net43_random_control_gap`).  The reported *accuracy* gaps were `+2.6` (k=256) and
  `+1.7` (k=384); the mass computation above explains why the sign is forced and why the
  gap shrinks as `k → ctx` (at `k = n` the random control equals the top-`k` control, mass
  gap `0`).
* Measured per-doubling ratios `1.50, 1.58, 1.68`, product `3.9816 < 4`, hence empirical
  exponent in `(0.6, 2/3)` (`empirical_exponent_bracket`): the `2/3` law is an upper
  envelope, and the *next* rung (`d = 64`) is predicted below `24.7 · 64^(2/3) = 395`.
* Grid ratio at the knee: `256/240 = 16/15`, so `≤ 6.25%` residual uncertainty
  (`net43_grid_resolution`); "exact reproduction at two seeds" means agreement to within
  this grid resolution, not to within one attention key.
-/

end Bridges.DeepestRungTwoSeed256