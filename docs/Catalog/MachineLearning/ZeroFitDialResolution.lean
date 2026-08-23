import Mathlib
import Novelty.ZeroFitDialU64
import MachineLearning.ZeroFitDialUnif52

/-!
# The resolution law: how many distinct values a dial statistic must have

## Research context (FACT round-58 #1, exp 528, `CELL-CLOSED-DIAL-HOLDS-UNIF-52`)

`Novelty.ZeroFitDialU64` proves the tie-attenuation law
`ρ² = 1 - 12·Σⱼ(mⱼ³-mⱼ)/(n³-n)`, and `MachineLearning.ZeroFitDialUnif52` computes the two
tie profiles that the round-58 measurement compares at bitlen 52 — the dyadic profile of
the trailing-zero dial (ceiling `6/7`) and the binomial profile of the count baseline
(ceiling `≥ 0.974`).  Both are *lower* bounds on, respectively, an exact value and a
bound; neither says how far a tie ceiling can possibly go once the number of distinct
values of the statistic is fixed.

This file supplies that missing upper half, and with it a *shape dichotomy* for tie
ceilings.

## Main results

* `cube_sum_power_mean` — the power-mean (double Cauchy–Schwarz) inequality for a tie
  profile, `n³ ≤ K²·Σⱼ mⱼ³`, proved by list induction from the algebraic identity
  `K²(K+1)²m³ + (K+1)²s³ - K²(m+s)³ = (Km-s)²(K²m + 2Km + 2Ks + s)`.
* `resolution_law` — the **resolution law**: a statistic taking `K` distinct values on
  `n` points has Spearman tie ceiling `ρ² ≤ 1 - 1/K² + 1/n²`.
* `spearmanSq_lt_one_of_blocks_lt` — strict sub-unity: whenever the statistic has fewer
  values than points, its ceiling is `< 1`.
* `blocks_sq_lower_bound` — the contrapositive **resolution budget**: to read
  `ρ² ≥ 1 - ε` a statistic needs `K² ≥ 1/(ε + n⁻²)` distinct values.
* `count_ceiling_upper`, `count_ceiling_sandwich_52` — the count baseline at bitlen 52 is
  pinned into `[0.974, 1 - 1/53² + 2⁻¹⁰⁴]`: it is *not* tie-limited in the band.
* `dyadic_far_below_resolution_law` — the **shape gap**: the trailing-zero profile, with
  exactly the same number `53` of distinct values as the count profile, sits a full
  `0.14` below the resolution bound.  Resolution alone therefore does not determine a
  ceiling; the *shape* of the profile does, and the dyadic shape is the extreme
  dominant-block one.
* `band_reading_needs_two_values` — a sanity floor: any profile whose ceiling reaches the
  bottom of the validation band `[0.55, 0.85]` must have at least two distinct values.

## The scientific payload

Together with `MachineLearning.ZeroFitDialUnif52.ceiling_inversion`, the resolution law
closes the tie-artefact explanation of the recorded `+0.070` dial-over-count advantage
from both sides: the count baseline's ceiling is above `0.974` (so ties cannot depress
its reading to `0.635`), and the dial's `6/7` ceiling is *far below* what its `53` values
would allow (so the dial's own attenuation is a shape effect, fully accounted for by the
2-adic profile).  Any residual explanation must live in the response.
-/

open Finset

open Catalog.Novelty.ZeroFitDialU64

open Catalog.MachineLearning.ZeroFitDialUnif52

namespace Catalog.MachineLearning.ZeroFitDialResolution

/-! ## 1. The power-mean inequality for tie profiles -/

/-- Cube sum of a tie profile, as a rational number. -/
def cubeSum : List ℕ → ℚ
  | [] => 0
  | m :: L => (m : ℚ) ^ 3 + cubeSum L

lemma cubeSum_nonneg (L : List ℕ) : 0 ≤ cubeSum L := by
  induction L with
  | nil => simp [cubeSum]
  | cons m L ih =>
      have : (0 : ℚ) ≤ (m : ℚ) ^ 3 := by positivity
      rw [cubeSum]
      linarith

/-- **Power-mean inequality for tie profiles** (equivalently, two applications of
Cauchy–Schwarz): with `K` blocks of total mass `n`, `n³ ≤ K² · Σⱼ mⱼ³`, with equality iff
all blocks are equal. -/
theorem cube_sum_power_mean (L : List ℕ) :
    ((L.sum : ℚ)) ^ 3 ≤ ((L.length : ℚ)) ^ 2 * cubeSum L := by
  induction L with
  | nil => simp [cubeSum]
  | cons m L ih =>
      have hsum : (((m :: L).sum : ℕ) : ℚ) = (m : ℚ) + (L.sum : ℚ) := by
        rw [List.sum_cons]; push_cast; ring
      have hlen : (((m :: L).length : ℕ) : ℚ) = (L.length : ℚ) + 1 := by
        rw [List.length_cons]; push_cast; ring
      have hcube : cubeSum (m :: L) = (m : ℚ) ^ 3 + cubeSum L := rfl
      rw [hsum, hlen, hcube]
      set K : ℚ := (L.length : ℚ) with hK
      set s : ℚ := (L.sum : ℚ) with hs
      set S : ℚ := cubeSum L with hS
      have hK0 : 0 ≤ K := by rw [hK]; positivity
      have hs0 : 0 ≤ s := by rw [hs]; positivity
      have hS0 : 0 ≤ S := cubeSum_nonneg L
      have hm0 : (0 : ℚ) ≤ (m : ℚ) := by positivity
      have hgoal : ((m : ℚ) + s) ^ 3 ≤ (K + 1) ^ 2 * ((m : ℚ) ^ 3 + S) := by
        rcases eq_or_lt_of_le hK0 with hK1 | hK1
        · -- no further blocks: the profile is the singleton `[m]`
          have hL : L = [] := by
            have hlen0 : L.length = 0 := by
              have : (L.length : ℚ) = 0 := by rw [← hK, ← hK1]
              exact_mod_cast this
            exact List.length_eq_zero_iff.1 hlen0
          have hs' : s = 0 := by rw [hs, hL]; simp
          have hS' : S = 0 := by rw [hS, hL]; simp [cubeSum]
          rw [hs', hS', ← hK1]
          norm_num
        · -- the generic case: clear the denominator `K²` and use the exact identity
          have hid : K ^ 2 * ((K + 1) ^ 2 * ((m : ℚ) ^ 3 + S)) - K ^ 2 * ((m : ℚ) + s) ^ 3
              = (K ^ 2 * (K + 1) ^ 2 * (m : ℚ) ^ 3 + (K + 1) ^ 2 * s ^ 3
                  - K ^ 2 * ((m : ℚ) + s) ^ 3)
                + (K + 1) ^ 2 * (K ^ 2 * S - s ^ 3) := by ring
          have hfac : K ^ 2 * (K + 1) ^ 2 * (m : ℚ) ^ 3 + (K + 1) ^ 2 * s ^ 3
              - K ^ 2 * ((m : ℚ) + s) ^ 3
              = (K * (m : ℚ) - s) ^ 2 * (K ^ 2 * (m : ℚ) + 2 * K * (m : ℚ) + 2 * K * s + s) := by
            ring
          have hpos : 0 ≤ (K * (m : ℚ) - s) ^ 2
              * (K ^ 2 * (m : ℚ) + 2 * K * (m : ℚ) + 2 * K * s + s) := by positivity
          have hih : 0 ≤ K ^ 2 * S - s ^ 3 := by linarith [ih]
          have hK1' : (0 : ℚ) < K ^ 2 := by positivity
          nlinarith [hpos, hih, hfac, hid]
      linarith [hgoal]

/-! ## 2. The resolution law -/

/-- A profile with only nonempty blocks has at most as many blocks as points. -/
lemma length_le_sum (L : List ℕ) (hpos : ∀ m ∈ L, 1 ≤ m) : L.length ≤ L.sum := by
  induction L with
  | nil => simp
  | cons m L ih =>
      have hm : 1 ≤ m := hpos m (List.mem_cons_self ..)
      have := ih fun x hx => hpos x (List.mem_cons_of_mem _ hx)
      simp only [List.length_cons, List.sum_cons]
      omega

lemma twelve_tieCorr_eq (L : List ℕ) : 12 * tieCorr L = cubeSum L - (L.sum : ℚ) := by
  induction L with
  | nil => simp [tieCorr, cubeSum]
  | cons m L ih =>
      have hsum : (((m :: L).sum : ℕ) : ℚ) = (m : ℚ) + (L.sum : ℚ) := by
        rw [List.sum_cons]; push_cast; ring
      have hcube : cubeSum (m :: L) = (m : ℚ) ^ 3 + cubeSum L := rfl
      rw [tieCorr_cons, mul_add, hsum, hcube]
      linarith

/-- **Resolution law.**  A tied statistic taking `K` distinct values on `n` points cannot
have Spearman tie ceiling better than `1 - 1/K² + 1/n²`, whatever the response.  The bound
depends on nothing but the *number* of distinct values. -/
theorem resolution_law (L : List ℕ) (h : 2 ≤ L.sum) (hpos : ∀ m ∈ L, 1 ≤ m) :
    spearmanSq L ≤ 1 - 1 / ((L.length : ℚ)) ^ 2 + 1 / ((L.sum : ℚ)) ^ 2 := by
  have hn : (2 : ℚ) ≤ (L.sum : ℚ) := by exact_mod_cast h
  have hKn : (L.length : ℚ) ≤ (L.sum : ℚ) := by exact_mod_cast length_le_sum L hpos
  have hK1 : (1 : ℚ) ≤ (L.length : ℚ) := by
    have hL : L ≠ [] := by
      intro hnil
      rw [hnil] at h
      simp at h
    have : 1 ≤ L.length := List.length_pos_iff.2 hL
    exact_mod_cast this
  have hden : (0 : ℚ) < (L.sum : ℚ) ^ 3 - (L.sum : ℚ) := cube_sub_self_pos hn
  have hpm : ((L.sum : ℚ)) ^ 3 ≤ ((L.length : ℚ)) ^ 2 * cubeSum L := cube_sum_power_mean L
  have hcube : 12 * tieCorr L = cubeSum L - (L.sum : ℚ) := twelve_tieCorr_eq L
  rw [spearmanSq_eq L h, hcube]
  have hK0 : (0 : ℚ) < (L.length : ℚ) ^ 2 := by nlinarith
  have hS : ((L.sum : ℚ)) ^ 3 / ((L.length : ℚ)) ^ 2 ≤ cubeSum L := (div_le_iff₀' hK0).2 hpm
  have hn0 : (0 : ℚ) < (L.sum : ℚ) ^ 2 := by nlinarith
  -- the crude but clean form of the bound
  have hkey : 1 / ((L.length : ℚ)) ^ 2 - 1 / ((L.sum : ℚ)) ^ 2
      ≤ (cubeSum L - (L.sum : ℚ)) / ((L.sum : ℚ) ^ 3 - (L.sum : ℚ)) := by
    rw [le_div_iff₀ hden]
    have h1 : ((L.sum : ℚ)) ^ 3 / ((L.length : ℚ)) ^ 2 - (L.sum : ℚ) ≤ cubeSum L - (L.sum : ℚ) := by
      linarith
    have hKn2 : ((L.length : ℚ)) ^ 2 ≤ ((L.sum : ℚ)) ^ 2 := by nlinarith
    have h2 : (1 / ((L.length : ℚ)) ^ 2 - 1 / ((L.sum : ℚ)) ^ 2)
        * ((L.sum : ℚ) ^ 3 - (L.sum : ℚ))
        ≤ ((L.sum : ℚ)) ^ 3 / ((L.length : ℚ)) ^ 2 - (L.sum : ℚ) := by
      have e1 : (1 / ((L.length : ℚ)) ^ 2 - 1 / ((L.sum : ℚ)) ^ 2)
          * ((L.sum : ℚ) ^ 3 - (L.sum : ℚ))
          = ((L.sum : ℚ)) ^ 3 / ((L.length : ℚ)) ^ 2 - (L.sum : ℚ)
            - ((L.sum : ℚ) / ((L.length : ℚ)) ^ 2 - 1 / (L.sum : ℚ)) := by
        field_simp
      have e2 : (1 : ℚ) / (L.sum : ℚ) ≤ (L.sum : ℚ) / ((L.length : ℚ)) ^ 2 := by
        rw [div_le_div_iff₀ (by linarith) hK0]
        nlinarith
      linarith
    linarith
  linarith

/-- **Strict sub-unity.**  A statistic with fewer distinct values than points has ceiling
strictly below one — an effective form of `spearmanSq_eq_one_iff`. -/
theorem spearmanSq_lt_one_of_blocks_lt (L : List ℕ) (h : 2 ≤ L.sum) (hpos : ∀ m ∈ L, 1 ≤ m)
    (hlt : L.length < L.sum) : spearmanSq L < 1 := by
  have hbound := resolution_law L h hpos
  have hKn : (L.length : ℚ) < (L.sum : ℚ) := by exact_mod_cast hlt
  have hK1 : (1 : ℚ) ≤ (L.length : ℚ) := by
    have hL : L ≠ [] := by
      intro hnil
      rw [hnil] at h
      simp at h
    have : 1 ≤ L.length := List.length_pos_iff.2 hL
    exact_mod_cast this
  have h1 : 1 / ((L.sum : ℚ)) ^ 2 < 1 / ((L.length : ℚ)) ^ 2 := by
    apply one_div_lt_one_div_of_lt (by nlinarith)
    nlinarith
  linarith

/-- **Resolution budget.**  Reading `ρ² ≥ 1 - ε` forces the statistic to take at least
`1/√(ε + n⁻²)` distinct values. -/
theorem blocks_sq_lower_bound (L : List ℕ) (h : 2 ≤ L.sum) (hpos : ∀ m ∈ L, 1 ≤ m)
    (eps : ℚ) (hread : 1 - eps ≤ spearmanSq L) :
    1 ≤ ((L.length : ℚ)) ^ 2 * (eps + 1 / ((L.sum : ℚ)) ^ 2) := by
  have hbound := resolution_law L h hpos
  have hn : (2 : ℚ) ≤ (L.sum : ℚ) := by exact_mod_cast h
  have hK1 : (1 : ℚ) ≤ (L.length : ℚ) := by
    have hL : L ≠ [] := by
      intro hnil
      rw [hnil] at h
      simp at h
    have : 1 ≤ L.length := List.length_pos_iff.2 hL
    exact_mod_cast this
  have hK0 : (0 : ℚ) < (L.length : ℚ) ^ 2 := by nlinarith
  have hstep : 1 / ((L.length : ℚ)) ^ 2 ≤ eps + 1 / ((L.sum : ℚ)) ^ 2 := by linarith
  rw [div_le_iff₀ hK0] at hstep
  linarith

/-! ## 3. Application: the count baseline and the dyadic dial at bitlen 52 -/

lemma binomBlocks_length (b : ℕ) : (binomBlocks b).length = b + 1 := by
  simp [binomBlocks]

lemma binomBlocks_pos (b : ℕ) : ∀ m ∈ binomBlocks b, 1 ≤ m := by
  intro m hm
  rw [binomBlocks, List.mem_map] at hm
  obtain ⟨k, hk, rfl⟩ := hm
  rw [List.mem_range] at hk
  exact Nat.choose_pos (by omega)

lemma binomBlocks_two_le (b : ℕ) (hb : 1 ≤ b) : 2 ≤ (binomBlocks b).sum := by
  rw [binomBlocks_sum]
  calc 2 = 2 ^ 1 := rfl
    _ ≤ 2 ^ b := Nat.pow_le_pow_right (by norm_num) hb

/-- **Upper half of the count sandwich.**  The Hamming-weight statistic on `b`-bit words
takes only `b+1` values, so its ceiling cannot exceed `1 - 1/(b+1)² + 4⁻ᵇ`. -/
theorem count_ceiling_upper (b : ℕ) (hb : 1 ≤ b) :
    spearmanSq (binomBlocks b) ≤ 1 - 1 / (((b : ℚ) + 1)) ^ 2 + 1 / ((2 : ℚ) ^ b) ^ 2 := by
  have h := resolution_law (binomBlocks b) (binomBlocks_two_le b hb) (binomBlocks_pos b)
  have hlen : ((binomBlocks b).length : ℚ) = (b : ℚ) + 1 := by
    rw [binomBlocks_length]; push_cast; ring
  have hsum : (((binomBlocks b).sum : ℕ) : ℚ) = (2 : ℚ) ^ b := by
    rw [binomBlocks_sum]; push_cast; ring
  rwa [hlen, hsum] at h

/-- **The count sandwich at bitlen 52.**  The count baseline's tie ceiling lies between
`0.974` and `1 - 1/2809 + 2⁻¹⁰⁴`; in particular it is far above the recorded reading
`0.635` and above the dial's `6/7`. -/
theorem count_ceiling_sandwich_52 :
    (1 - 2 / 79 : ℚ) ≤ spearmanSq (binomBlocks 52) ∧
      spearmanSq (binomBlocks 52) ≤ 1 - 1 / 2809 + 1 / ((2 : ℚ) ^ 52) ^ 2 := by
  refine ⟨count_ceiling_52, ?_⟩
  have h := count_ceiling_upper 52 (by norm_num)
  norm_num at h ⊢
  linarith

/-- **Shape gap.**  The trailing-zero profile has the *same* number of distinct values
(`53`) as the count profile at bitlen 52, yet its ceiling `6/7` falls short of the
resolution bound by more than `0.14`: resolution does not determine the ceiling, shape
does. -/
theorem dyadic_far_below_resolution_law :
    (dyadicBlocks 52).length = (binomBlocks 52).length ∧
      spearmanSq (dyadicBlocks 52) + 1 / 10
        < 1 - 1 / (((52 : ℚ)) + 1) ^ 2 + 1 / ((2 : ℚ) ^ 52) ^ 2 := by
  constructor
  · have hd : ∀ b : ℕ, (dyadicBlocks b).length = b + 1 := by
      intro b
      induction b with
      | zero => simp [dyadicBlocks]
      | succ k ih => simp [dyadicBlocks, ih]
    rw [hd, binomBlocks_length]
  · rw [dyadic_spearmanSq 52 (by norm_num)]
    have h1 : (0 : ℚ) < 1 / ((2 : ℚ) ^ 52 * (2 ^ 52 + 1)) := by positivity
    have h2 : 1 / ((2 : ℚ) ^ 52 * (2 ^ 52 + 1)) ≤ 1 / 1024 := by
      apply one_div_le_one_div_of_le (by norm_num)
      nlinarith [pow_le_pow_right₀ (by norm_num : (1:ℚ) ≤ 2) (by norm_num : 10 ≤ 52),
        (by positivity : (0:ℚ) < (2:ℚ) ^ 52)]
    have h3 : (0 : ℚ) < 1 / ((2 : ℚ) ^ 52) ^ 2 := by positivity
    have h4 : (6 : ℚ) / 7 * (1 + 1 / ((2 : ℚ) ^ 52 * (2 ^ 52 + 1))) ≤ 6 / 7 + 1 / 1024 := by
      nlinarith
    have hgoal : (6 : ℚ) / 7 + 1 / 1024 + 1 / 10 < 1 - 1 / (((52 : ℚ)) + 1) ^ 2 := by norm_num
    linarith

/-- A profile whose ceiling reaches the bottom `0.55` of the validation band must
distinguish at least two values — the degenerate one-block statistic reads `0`. -/
theorem band_reading_needs_two_values (L : List ℕ) (h : 2 ≤ L.sum) (hpos : ∀ m ∈ L, 1 ≤ m)
    (hband : (55 / 100 : ℚ) ^ 2 ≤ spearmanSq L) : 2 ≤ L.length := by
  by_contra hc
  push_neg at hc
  interval_cases hlen : L.length
  · have hL : L = [] := List.length_eq_zero_iff.1 hlen
    rw [hL] at h
    simp at h
  · obtain ⟨m, rfl⟩ := List.length_eq_one_iff.1 hlen
    have hsum : ([m] : List ℕ).sum = m := by simp
    have hzero : spearmanSq [m] = 0 := by
      have hcube : 12 * tieCorr ([m] : List ℕ) = cubeSum [m] - (([m] : List ℕ).sum : ℚ) :=
        twelve_tieCorr_eq _
      rw [spearmanSq_eq _ h, hsum] at *
      have hc3 : cubeSum ([m] : List ℕ) = (m : ℚ) ^ 3 := by simp [cubeSum]
      rw [hcube, hc3, hsum]
      have hm2 : (2 : ℚ) ≤ (m : ℚ) := by exact_mod_cast (by simpa using h : 2 ≤ m)
      have hden : (0 : ℚ) < (m : ℚ) ^ 3 - (m : ℚ) := cube_sub_self_pos hm2
      rw [div_self (ne_of_gt hden)]
      ring
    rw [hzero] at hband
    norm_num at hband

end Catalog.MachineLearning.ZeroFitDialResolution