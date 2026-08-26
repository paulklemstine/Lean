import Mathlib
import Novelty.ZeroFitDialU64
import MachineLearning.ZeroFitDialUnif52

/-!
# The zero-fit dial on *exact*-bitlen draws: the one-bit shift law at bitlen 48

## Research context (FACT round-57 #1, exp 527, `CELL-CLOSED-DIAL-HOLDS-UNIF-48B`)

The measurement under study reports a Spearman rank correlation between a
*zero-count statistic* `T` (the number of trailing binary zeros, i.e. the
2-adic valuation) and a downstream `rate`, on uniform draws of **exact bitlen
48**, i.e. uniform on the dyadic window `[2^47, 2^48)`:

* seeds 20261110/11/12 give `0.7291 / 0.7286 / 0.7087`, all inside the
  validation band `[0.55, 0.85]`;
* `T` beats a plain popcount ("count") baseline by `+0.134`, CI `[0.113, 0.158]`.

All previous catalog work on the dial (`Novelty.ZeroFitDialU64`,
`MachineLearning.ZeroFitDialUnif52`, …) models the draw as uniform on
`range (2^b)`.  Exact-bitlen sampling is a genuinely different measure: the top
bit is *conditioned to be one*.  This file supplies the mathematics of that
conditioning.

## Main results

* `card_windowBlock`, `card_windowBlock_top` — the arithmetic bridge for the
  dyadic window: exactly `2^(b-1-k)` integers of `[2^b, 2^(b+1))` have `k`
  trailing zeros for `k < b`, and exactly one (namely `2^b`) has `b`.
* `windowProfile_eq_dyadicBlocks` — the **one-bit shift law for the
  trailing-zero dial**: the tie profile of `T` on exact bitlen `b+1` is
  *literally* the dyadic profile of full-range bitlen `b`.
* `weightWindowBlock_card`, `weightWindowProfile_eq_binomBlocks` — the same
  one-bit shift for the popcount baseline: its exact-bitlen-`(b+1)` profile is
  `binomBlocks b`.  Conditioning on the bitlen shifts *both* dials by exactly
  one bit, so the comparison between them is preserved.
* `exact_bitlen_ceiling` — the closed-form ceiling for exact bitlen `b+1`:
  `ρ² = (6/7)·(1 + 1/(2^b(2^b+1)))`; `exact_bitlen_ceiling_gt_range` shows
  conditioning on the bitlen *raises* the ceiling, but by less than `4^{-b}`.
* `choose_odd_le_two_centralBinom`, `franel_odd_bound`,
  `count_ceiling_ge_of_franel`, `count_ceiling_odd_ge`,
  `ceiling_inversion_odd` — the **odd-bitlen** half of the ceiling-inversion
  law.  The catalog only had the even case (`ZeroFitDialUnif52.ceiling_inversion`),
  and exact bitlen 48 reduces to bitlen `47`, which is odd; the odd case needs
  the new bound `C(2m+1,m) ≤ 2·C(2m,m)` feeding a new Franel estimate
  `franel(2m+1)·(3m+1) ≤ 8^(2m+1)`.
* `exact_bitlen48_ceiling_inversion` — at exact bitlen 48 the popcount baseline
  has a *strictly higher* tie ceiling than the trailing-zero statistic.
* `round57_inside_band`, `round57_seeds_below_ceiling`,
  `round57_advantage_not_tie_artefact`, `round57_ceiling_flat_but_dial_moves`
  — the recorded round-57 numbers checked against the theory.

## The scientific payload

Two negative results sharpen the reported cell.

1. `round57_advantage_not_tie_artefact`: the measured `+0.134` advantage of `T`
   over the count baseline runs *against* the tie-headroom ordering, which at
   exact bitlen 48 strictly favours the count baseline.  So the advantage is
   signal, not tie geometry.
2. `round57_ceiling_flat_but_dial_moves`: exact-bitlen conditioning and the
   move from bitlen 48 to bitlen 64 change the ceiling by less than `4^{-47}`,
   whereas the recorded dial moves by more than `0.07`.  The bitlen dependence
   of the dial is therefore not a quantisation artefact.
-/

open Finset

open Catalog.Novelty.ZeroFitDialU64
open Catalog.MachineLearning.ZeroFitDialUnif52

namespace Catalog.Novelty.ZeroFitDialExactBitlen48

/-! ## 1. The exact-bitlen window and its 2-adic blocks -/

/-- The integers of exact bitlen `b+1`: the dyadic window `[2^b, 2^(b+1))`. -/
def bitWindow (b : ℕ) : Finset ℕ := Finset.Ico (2 ^ b) (2 ^ (b + 1))

/-- The `k`-th trailing-zero block of the exact-bitlen window. -/
def windowBlock (b k : ℕ) : Finset ℕ :=
  (bitWindow b).filter fun x => 2 ^ k ∣ x ∧ ¬ 2 ^ (k + 1) ∣ x

lemma twoAdicBlock_subset (b k : ℕ) : twoAdicBlock b k ⊆ twoAdicBlock (b + 1) k := by
  intro x hx
  simp only [twoAdicBlock, mem_filter, mem_range] at hx ⊢
  refine ⟨lt_of_lt_of_le hx.1 (Nat.pow_le_pow_right (by norm_num) (by omega)), hx.2⟩

/-- The window blocks are the differences of the full-range 2-adic blocks. -/
lemma windowBlock_eq_sdiff (b k : ℕ) :
    windowBlock b k = twoAdicBlock (b + 1) k \ twoAdicBlock b k := by
  ext x
  simp only [windowBlock, bitWindow, twoAdicBlock, mem_filter, mem_sdiff, mem_range,
    Finset.mem_Ico]
  constructor
  · rintro ⟨⟨hlo, hhi⟩, hd⟩
    exact ⟨⟨hhi, hd⟩, fun h => absurd h.1 (by omega)⟩
  · rintro ⟨⟨hhi, hd⟩, hne⟩
    have : ¬ x < 2 ^ b := fun h => hne ⟨h, hd⟩
    exact ⟨⟨by omega, hhi⟩, hd⟩

/-- For `k < b` the exact-bitlen window has `2^(b-1-k)` integers with `k` trailing zeros. -/
theorem card_windowBlock (b k : ℕ) (hk : k < b) : (windowBlock b k).card = 2 ^ (b - 1 - k) := by
  rw [windowBlock_eq_sdiff, card_sdiff_of_subset (twoAdicBlock_subset b k),
    card_two_adic_block (b + 1) k (by omega), card_two_adic_block b k hk]
  have h : b + 1 - 1 - k = (b - 1 - k) + 1 := by omega
  rw [h, pow_succ]
  omega

/-- The top block of the exact-bitlen window is the singleton `{2^b}`. -/
theorem windowBlock_top (b : ℕ) : windowBlock b b = {2 ^ b} := by
  ext x
  simp only [windowBlock, bitWindow, mem_filter, Finset.mem_Ico, Finset.mem_singleton]
  constructor
  · rintro ⟨⟨hlo, hhi⟩, ⟨u, rfl⟩, hnd⟩
    have hpb : 0 < 2 ^ b := Nat.two_pow_pos b
    have hu1 : 1 ≤ u := by nlinarith
    have hu2 : u < 2 := by
      by_contra hcon
      push_neg at hcon
      rw [pow_succ] at hhi
      nlinarith
    have : u = 1 := by omega
    simp [this]
  · rintro rfl
    have hpb : 0 < 2 ^ b := Nat.two_pow_pos b
    have hhi : 2 ^ b < 2 ^ (b + 1) := by rw [pow_succ]; omega
    refine ⟨⟨le_refl _, hhi⟩, ⟨1, by ring⟩, ?_⟩
    rintro ⟨v, hv⟩
    rw [pow_succ] at hv
    rcases Nat.eq_zero_or_pos v with rfl | hvpos
    · omega
    · nlinarith

theorem card_windowBlock_top (b : ℕ) : (windowBlock b b).card = 1 := by
  rw [windowBlock_top]; simp

/-- Tie profile of the trailing-zero statistic on exact-bitlen-`(b+1)` draws. -/
def windowProfile (b : ℕ) : List ℕ := (List.range (b + 1)).map fun k => (windowBlock b k).card

/-- Closed form of the dyadic profile. -/
lemma dyadicBlocks_eq_formula (b : ℕ) :
    dyadicBlocks b = ((List.range b).map fun k => 2 ^ (b - 1 - k)) ++ [1] := by
  induction b with
  | zero => simp [dyadicBlocks]
  | succ n ih =>
      rw [dyadicBlocks, List.range_succ_eq_map, List.map_cons, List.map_map, List.cons_append]
      simp only [Nat.succ_sub_one, Nat.sub_zero]
      congr 1
      have hfun : ((fun a => 2 ^ (n - a)) ∘ Nat.succ) = (fun k : ℕ => 2 ^ (n - 1 - k)) := by
        funext k
        simp only [Function.comp_apply]
        congr 1
        omega
      rw [hfun]
      exact ih

/-- **One-bit shift law (trailing-zero dial).**  The tie profile of the trailing-zero
statistic on uniform draws of *exact* bitlen `b+1` is exactly the dyadic profile of
uniform draws on the *full range* `[0, 2^b)`. -/
theorem windowProfile_eq_dyadicBlocks (b : ℕ) : windowProfile b = dyadicBlocks b := by
  rw [windowProfile, dyadicBlocks_eq_formula, List.range_succ, List.map_append]
  congr 1
  · exact List.map_congr_left fun k hk => card_windowBlock b k (List.mem_range.1 hk)
  · simp [card_windowBlock_top]

/-! ## 2. The exact-bitlen ceiling -/

/-- **Exact-bitlen tie ceiling.**  For uniform draws of exact bitlen `b+1` the largest
Spearman coefficient attainable by the trailing-zero statistic against any refining
response satisfies `ρ² = (6/7)·(1 + 1/(2^b(2^b+1)))`. -/
theorem exact_bitlen_ceiling (b : ℕ) (hb : 1 ≤ b) :
    spearmanSq (windowProfile b) = (6 / 7) * (1 + 1 / ((2 : ℚ) ^ b * (2 ^ b + 1))) := by
  rw [windowProfile_eq_dyadicBlocks]
  exact dyadic_spearmanSq b hb

/-- **Conditioning on the bitlen raises the ceiling by exactly one bit.** -/
theorem exact_bitlen_ceiling_gt_range (b : ℕ) (hb : 1 ≤ b) :
    spearmanSq (dyadicBlocks (b + 1)) < spearmanSq (windowProfile b) := by
  rw [windowProfile_eq_dyadicBlocks]
  exact dyadic_ceiling_strict_anti hb (by omega)

/-- …but the gain is smaller than `4^{-b}`: exact-bitlen conditioning is invisible
at the resolution of any real measurement. -/
theorem exact_bitlen_ceiling_gain_small (b : ℕ) (hb : 1 ≤ b) :
    spearmanSq (windowProfile b) - spearmanSq (dyadicBlocks (b + 1)) < (1 / 4 : ℚ) ^ b := by
  have h1 : spearmanSq (windowProfile b) - 6 / 7 < (1 / 4 : ℚ) ^ b := by
    rw [windowProfile_eq_dyadicBlocks]; exact dyadic_ceiling_close b hb
  have h2 : 6 / 7 < spearmanSq (dyadicBlocks (b + 1)) := dyadic_ceiling_gt (b + 1) (by omega)
  linarith

/-! ## 3. The popcount baseline on the window: the same one-bit shift -/

/-- Weight-`(j+1)` subsets of a `(b+1)`-cube whose top coordinate is switched on: the
tie blocks of the popcount statistic restricted to words of exact bitlen `b+1`. -/
def weightWindowBlock (b j : ℕ) : Finset (Finset (Fin (b + 1))) :=
  (univ : Finset (Finset (Fin (b + 1)))).filter fun S => Fin.last b ∈ S ∧ S.card = j + 1

/-- **Combinatorial bridge for the count baseline on the window.**  Exactly `C(b,j)` of the
exact-bitlen-`(b+1)` words have popcount `j+1`. -/
theorem weightWindowBlock_card (b j : ℕ) : (weightWindowBlock b j).card = b.choose j := by
  have hb : ((univ : Finset (Fin (b + 1))).erase (Fin.last b)).card = b := by
    rw [card_erase_of_mem (mem_univ _), card_univ, Fintype.card_fin]
    omega
  have hbij : weightWindowBlock b j
      = (Finset.powersetCard j ((univ : Finset (Fin (b + 1))).erase (Fin.last b))).image
          (insert (Fin.last b)) := by
    ext S
    simp only [weightWindowBlock, mem_filter, mem_univ, true_and, mem_image,
      Finset.mem_powersetCard]
    constructor
    · rintro ⟨hmem, hcard⟩
      refine ⟨S.erase (Fin.last b), ⟨?_, ?_⟩, ?_⟩
      · intro x hx
        rw [Finset.mem_erase] at hx ⊢
        exact ⟨hx.1, mem_univ _⟩
      · rw [card_erase_of_mem hmem, hcard]; rfl
      · rw [Finset.insert_erase hmem]
    · rintro ⟨T, ⟨hsub, hcard⟩, rfl⟩
      have hnot : Fin.last b ∉ T := fun h => (Finset.mem_erase.1 (hsub h)).1 rfl
      exact ⟨Finset.mem_insert_self _ _, by rw [card_insert_of_notMem hnot, hcard]⟩
  rw [hbij, card_image_of_injOn, Finset.card_powersetCard, hb]
  intro S hS T hT hST
  rw [Finset.mem_coe, Finset.mem_powersetCard] at hS hT
  have hS' : Fin.last b ∉ S := fun h => (Finset.mem_erase.1 (hS.1 h)).1 rfl
  have hT' : Fin.last b ∉ T := fun h => (Finset.mem_erase.1 (hT.1 h)).1 rfl
  have := congrArg (fun U => Finset.erase U (Fin.last b)) hST
  simpa [Finset.erase_insert hS', Finset.erase_insert hT'] using this

/-- Tie profile of the popcount statistic on exact-bitlen-`(b+1)` draws. -/
def weightWindowProfile (b : ℕ) : List ℕ :=
  (List.range (b + 1)).map fun j => (weightWindowBlock b j).card

/-- **One-bit shift law (count baseline).**  The popcount tie profile of exact-bitlen-`(b+1)`
draws is the full-range binomial profile at bitlen `b`. -/
theorem weightWindowProfile_eq_binomBlocks (b : ℕ) : weightWindowProfile b = binomBlocks b := by
  rw [weightWindowProfile, binomBlocks]
  exact List.map_congr_left fun j _ => weightWindowBlock_card b j

/-! ## 4. The odd-bitlen half of the ceiling-inversion law -/

/-- Middle binomial of an odd row is at most twice the central binomial below it. -/
theorem choose_odd_le_two_centralBinom (m : ℕ) :
    (2 * m + 1).choose ((2 * m + 1) / 2) ≤ 2 * Nat.centralBinom m := by
  have hhalf : (2 * m + 1) / 2 = m := by omega
  rw [hhalf, Nat.centralBinom_eq_two_mul_choose]
  rcases m with _ | t
  · simp
  · have hpascal : (2 * (t + 1) + 1).choose (t + 1) = (2 * (t + 1)).choose t
        + (2 * (t + 1)).choose (t + 1) := by
      have h : 2 * (t + 1) + 1 = (2 * (t + 1)) + 1 := by ring
      rw [h, Nat.choose_succ_succ' (2 * (t + 1)) t]
    have hmid1 : (2 * (t + 1)).choose t ≤ (2 * (t + 1)).choose ((2 * (t + 1)) / 2) :=
      Nat.choose_le_middle _ _
    have hmid2 : (2 * (t + 1)).choose (t + 1) ≤ (2 * (t + 1)).choose ((2 * (t + 1)) / 2) :=
      Nat.choose_le_middle _ _
    have hd : (2 * (t + 1)) / 2 = t + 1 := by omega
    rw [hd] at hmid1 hmid2
    omega

/-- **Odd Franel bound.**  `Σⱼ C(2m+1,j)³ · (3m+1) ≤ 8^(2m+1)`, the odd counterpart of
`ZeroFitDialUnif52.franel_even_bound`. -/
theorem franel_odd_bound (m : ℕ) : franel (2 * m + 1) * (3 * m + 1) ≤ 8 ^ (2 * m + 1) := by
  have h1 : franel (2 * m + 1) ≤ (2 * Nat.centralBinom m) ^ 2 * 2 ^ (2 * m + 1) := by
    refine le_trans (franel_le (2 * m + 1)) ?_
    exact Nat.mul_le_mul_right _ (Nat.pow_le_pow_left (choose_odd_le_two_centralBinom m) 2)
  calc franel (2 * m + 1) * (3 * m + 1)
      ≤ (2 * Nat.centralBinom m) ^ 2 * 2 ^ (2 * m + 1) * (3 * m + 1) :=
        Nat.mul_le_mul_right _ h1
    _ = 4 * ((Nat.centralBinom m) ^ 2 * (3 * m + 1)) * 2 ^ (2 * m + 1) := by ring
    _ ≤ 4 * 16 ^ m * 2 ^ (2 * m + 1) := by
        exact Nat.mul_le_mul_right _ (Nat.mul_le_mul_left _ (centralBinom_sq_bound m))
    _ = 8 ^ (2 * m + 1) := by
        rw [show (16 : ℕ) = 2 ^ 4 by norm_num, show (8 : ℕ) = 2 ^ 3 by norm_num,
          show (4 : ℕ) = 2 ^ 2 by norm_num, ← pow_mul, ← pow_mul, ← pow_add, ← pow_add]
        ring_nf

/-- **Franel-to-ceiling transfer.**  Any bound of the shape `franel b · c ≤ 8^b` yields the
count ceiling `ρ² ≥ 1 - 2/c`.  (Bitlen-parity agnostic refactor of
`ZeroFitDialUnif52.count_ceiling_ge`.) -/
theorem count_ceiling_ge_of_franel (b : ℕ) (hb : 1 ≤ b) (c : ℚ) (hc : 0 < c)
    (hfr : (franel b : ℚ) * c ≤ (8 : ℚ) ^ b) :
    1 - 2 / c ≤ spearmanSq (binomBlocks b) := by
  have hsum : (binomBlocks b).sum = 2 ^ b := binomBlocks_sum b
  have h2 : 2 ≤ (binomBlocks b).sum := by
    rw [hsum]
    calc 2 = 2 ^ 1 := rfl
      _ ≤ 2 ^ b := Nat.pow_le_pow_right (by norm_num) hb
  have hcast : (((binomBlocks b).sum : ℕ) : ℚ) = (2 : ℚ) ^ b := by rw [hsum]; push_cast; ring
  have hcube : ((2 : ℚ) ^ b) ^ 3 = 8 ^ b := pow_two_cube b
  have hpow2 : (0 : ℚ) < (2 : ℚ) ^ b := by positivity
  have hmul : (2 : ℚ) ^ b * 4 ^ b = 8 ^ b := by rw [← mul_pow]; norm_num
  have h4 : (4 : ℚ) ≤ (4 : ℚ) ^ b := by
    calc (4 : ℚ) = 4 ^ 1 := (pow_one 4).symm
      _ ≤ 4 ^ b := by apply pow_le_pow_right₀ (by norm_num) hb
  have hhalf : (2 : ℚ) * 2 ^ b ≤ 8 ^ b := by nlinarith
  have hden : ((2 : ℚ) ^ b) ^ 3 - 2 ^ b > 0 := by rw [hcube]; nlinarith
  have hkey : ((franel b : ℚ) - 2 ^ b) / (((2 : ℚ) ^ b) ^ 3 - 2 ^ b) ≤ 2 / c := by
    rw [div_le_div_iff₀ hden hc, hcube]
    have h1 : ((franel b : ℚ) - 2 ^ b) * c ≤ (8 : ℚ) ^ b := by
      nlinarith [Nat.cast_nonneg (α := ℚ) (franel b)]
    rw [hcube] at hden
    nlinarith
  rw [spearmanSq_eq _ h2, hcast, tieCorr_binomBlocks]
  linarith

/-- **Count ceiling at odd bitlen.**  `ρ² ≥ 1 - 2/(3m+1)` at bitlen `2m+1`. -/
theorem count_ceiling_odd_ge (m : ℕ) :
    1 - 2 / (3 * (m : ℚ) + 1) ≤ spearmanSq (binomBlocks (2 * m + 1)) := by
  refine count_ceiling_ge_of_franel (2 * m + 1) (by omega) (3 * (m : ℚ) + 1) (by positivity) ?_
  have hn := franel_odd_bound m
  have := (Nat.cast_le (α := ℚ)).2 hn
  push_cast at this
  convert this using 2

/-- **Ceiling inversion at odd bitlen.**  For every odd bitlen `2m+1` with `m ≥ 5` the
popcount baseline has a strictly higher tie ceiling than the trailing-zero statistic. -/
theorem ceiling_inversion_odd (m : ℕ) (hm : 5 ≤ m) :
    spearmanSq (dyadicBlocks (2 * m + 1)) < spearmanSq (binomBlocks (2 * m + 1)) := by
  have hb1 : 1 ≤ 2 * m + 1 := by omega
  have hpow : (1024 : ℚ) ≤ (2 : ℚ) ^ (2 * m + 1) := by
    calc (1024 : ℚ) = 2 ^ 10 := by norm_num
      _ ≤ 2 ^ (2 * m + 1) := by apply pow_le_pow_right₀ (by norm_num) (by omega)
  have hup : spearmanSq (dyadicBlocks (2 * m + 1)) ≤ 6 / 7 + 1 / (2 : ℚ) ^ (2 * m + 1) :=
    dyadic_ceiling_le _ hb1
  have hsmall : 1 / (2 : ℚ) ^ (2 * m + 1) ≤ 1 / 1024 :=
    one_div_le_one_div_of_le (by norm_num) hpow
  have hlow := count_ceiling_odd_ge m
  have hm5 : (5 : ℚ) ≤ (m : ℚ) := by exact_mod_cast hm
  have hden : (0 : ℚ) < 3 * (m : ℚ) + 1 := by positivity
  have hfrac : 2 / (3 * (m : ℚ) + 1) ≤ 1 / 8 := by
    rw [div_le_div_iff₀ hden (by norm_num)]
    linarith
  linarith

/-- **Ceiling inversion at exact bitlen 48.**  On uniform draws of exact bitlen 48 the
popcount baseline has strictly *more* tie headroom than the trailing-zero statistic:
the tie profiles are `windowProfile 47` and `weightWindowProfile 47`. -/
theorem exact_bitlen48_ceiling_inversion :
    spearmanSq (windowProfile 47) < spearmanSq (weightWindowProfile 47) := by
  rw [windowProfile_eq_dyadicBlocks, weightWindowProfile_eq_binomBlocks]
  have h : (47 : ℕ) = 2 * 23 + 1 := by norm_num
  rw [h]
  exact ceiling_inversion_odd 23 (by norm_num)

/-! ## 5. The recorded round-57 measurement, checked against the theory -/

/-- Seed 20261110. -/
def seed10 : ℚ := 7291 / 10000
/-- Seed 20261111. -/
def seed11 : ℚ := 7286 / 10000
/-- Seed 20261112. -/
def seed12 : ℚ := 7087 / 10000
/-- Pooled dial value at exact bitlen 48. -/
def pooled48 : ℚ := (seed10 + seed11 + seed12) / 3
/-- Reported advantage of `T` over the count baseline. -/
def advantage48 : ℚ := 134 / 1000
/-- Lower confidence limit of the advantage. -/
def advLow48 : ℚ := 113 / 1000
/-- Upper confidence limit of the advantage. -/
def advHigh48 : ℚ := 158 / 1000
/-- Implied pooled value of the count baseline. -/
def countPooled48 : ℚ := pooled48 - advantage48

/-- All three seeds lie strictly inside the validation band `[0.55, 0.85]`. -/
theorem round57_inside_band :
    (55 / 100 : ℚ) < seed10 ∧ seed10 < 85 / 100 ∧
    (55 / 100 : ℚ) < seed11 ∧ seed11 < 85 / 100 ∧
    (55 / 100 : ℚ) < seed12 ∧ seed12 < 85 / 100 := by
  refine ⟨by norm_num [seed10], by norm_num [seed10], by norm_num [seed11], by norm_num [seed11],
    by norm_num [seed12], by norm_num [seed12]⟩

/-- The three seeds agree to within `0.0204`. -/
theorem round57_seed_spread : seed10 - seed12 < 21 / 1000 ∧ 0 < seed10 - seed12 := by
  constructor <;> norm_num [seed10, seed12]

/-- Every recorded seed sits strictly below the exact-bitlen-48 tie ceiling. -/
theorem round57_seeds_below_ceiling :
    seed10 ^ 2 < spearmanSq (windowProfile 47) ∧
    seed11 ^ 2 < spearmanSq (windowProfile 47) ∧
    seed12 ^ 2 < spearmanSq (windowProfile 47) := by
  have h : (6 : ℚ) / 7 < spearmanSq (windowProfile 47) := by
    rw [windowProfile_eq_dyadicBlocks]
    exact dyadic_ceiling_gt 47 (by norm_num)
  have h10 : seed10 ^ 2 ≤ 6 / 7 := by norm_num [seed10]
  have h11 : seed11 ^ 2 ≤ 6 / 7 := by norm_num [seed11]
  have h12 : seed12 ^ 2 ≤ 6 / 7 := by norm_num [seed12]
  exact ⟨lt_of_le_of_lt h10 h, lt_of_le_of_lt h11 h, lt_of_le_of_lt h12 h⟩

/-- The advantage is inside its reported CI and strictly positive. -/
theorem round57_advantage_inside_ci :
    advLow48 ≤ advantage48 ∧ advantage48 ≤ advHigh48 ∧ 0 < advLow48 := by
  refine ⟨by norm_num [advLow48, advantage48], by norm_num [advantage48, advHigh48],
    by norm_num [advLow48]⟩

/-- Even after subtracting the advantage, the count baseline stays inside the band. -/
theorem round57_count_inside_band :
    (55 / 100 : ℚ) < countPooled48 ∧ countPooled48 < 85 / 100 := by
  constructor <;> norm_num [countPooled48, pooled48, seed10, seed11, seed12, advantage48]

/-- **The advantage is not a tie artefact.**  The measured ordering (`T` above the count
baseline by `+0.134`) is the *reverse* of the tie-headroom ordering at exact bitlen 48,
where the count baseline has the strictly larger ceiling. -/
theorem round57_advantage_not_tie_artefact :
    spearmanSq (windowProfile 47) < spearmanSq (weightWindowProfile 47) ∧
    0 < pooled48 - countPooled48 := by
  refine ⟨exact_bitlen48_ceiling_inversion, ?_⟩
  norm_num [countPooled48, advantage48]

/-- **Ceiling flat, dial not.**  Passing from exact bitlen 48 to full-range bitlen 64 moves the
tie ceiling by less than `4^{-47}`, while the recorded dial moves by more than `0.07`. -/
theorem round57_ceiling_flat_but_dial_moves :
    spearmanSq (windowProfile 47) - spearmanSq (dyadicBlocks 64) < (1 / 4 : ℚ) ^ 47 ∧
    (7 / 100 : ℚ) < pooled48 - Catalog.Novelty.ZeroFitDialU64.pooled := by
  constructor
  · have h1 : spearmanSq (windowProfile 47) - 6 / 7 < (1 / 4 : ℚ) ^ 47 := by
      rw [windowProfile_eq_dyadicBlocks]
      exact dyadic_ceiling_close 47 (by norm_num)
    have h2 : 6 / 7 < spearmanSq (dyadicBlocks 64) := dyadic_ceiling_gt 64 (by norm_num)
    linarith
  · norm_num [pooled48, seed10, seed11, seed12, Catalog.Novelty.ZeroFitDialU64.pooled]

end Catalog.Novelty.ZeroFitDialExactBitlen48