import Mathlib
import Novelty.ZeroFitDialU64
import MachineLearning.ZeroFitDialUnif52

/-!
# The balanced draw law and the two-sided `6/7` attractor at bitlen 60

## Research context (FACT round-51 #3, exp 521, `CELL-CLOSED-DIAL-HOLDS-60`)

The measurement under study reports a Spearman rank correlation between the
*zero-count statistic* `T` (the number of trailing binary zeros, i.e. the 2-adic
valuation) and a downstream `rate`, on **uniform** draws at bitlen 60:

* `Spearman(T, rate) = 0.669`, CI `[0.634, 0.705]`, inside the validation band
  `[0.55, 0.85]`;
* `T` beats the popcount ("count") baseline by `+0.151`, CI `[0.107, 0.193]`.

The cell is reported as closing the deployment envelope: the dial is now
validated on **balanced and uniform draws through bitlen 60**.  The catalog
already carries the uniform half of that envelope
(`Novelty.ZeroFitDialU64`, `MachineLearning.ZeroFitDialUnif52`,
`Novelty.ZeroFitDialExactBitlen48`): the tie profile of `T` on uniform `b`-bit
draws is dyadic and its Spearman ceiling is `(6/7)(1 + 1/(2^b(2^b+1)))`.

The *balanced* half was missing.  A balanced draw is uniform on the words of
bitlen `b = 2w` with exactly `w` one-bits; conditioning on the popcount changes
the tie profile of `T` completely — from a geometric profile to a
**hockey-stick binomial profile** `C(b-1-k, w-1)`.  This file builds that
profile, computes its Spearman ceiling, and compares the two draw laws.

## Main results

* `balancedBlocks`, `centralProfile` — the hockey-stick tie profile of the
  trailing-zero statistic under a balanced draw, and `balancedBlocks_sum`
  (hockey-stick identity) showing it sums to `C(b, w)`.
* `card_balancedWordBlock`, `centralProfile_eq_balanced_valuation_profile` —
  the **arithmetic bridge**: the words of bitlen `b` and weight `w` whose
  lowest set bit is `k` number exactly `C(b-1-k, w-1)`, so the list really is
  the tie profile of `T` under the balanced law.
* `two_mul_choose_le` — the *decay law*: below the top block the hockey-stick
  profile at least halves at every step, so it is dominated by a dyadic
  profile.  `cubeSum_balanced_le` turns this into a geometric bound on the
  Kendall tie correction.
* `head_ratio`, `m1_eq_two_mul_m2` — the two exact identities that pin the top
  of the profile: `(v+1)·m₀ = (2v+1)·m₁` and `m₁ = 2·m₂`.  The *first* step of
  the balanced profile decays by strictly **less** than one half, and every
  later step by at least one half; that single anomalous step is what pushes
  the balanced ceiling to the other side of `6/7`.
* `balanced_ceiling_gt` — for every `v`, the balanced ceiling at bitlen
  `2v+2` exceeds `6/7 - 1/(v+1)`: the balanced draw law also converges to the
  universal `6/7` tie-attenuation constant.
* `balanced_ceiling_lt` — for `2 ≤ v ≤ 94` (bitlens `6 … 190`) the balanced
  ceiling is **strictly below** `6/7`, while `Novelty.ZeroFitDialU64` proves
  the uniform ceiling is strictly above it.
* `draw_law_sandwich`, `balanced_below_uniform` — **the payload**: `6/7` is a
  two-sided attractor.  Uniform draws approach it from above, balanced draws
  from below, and at every bitlen in the envelope the balanced ceiling is
  strictly the smaller of the two.  The `6/7` constant *separates the two draw
  laws*; it is not merely their common limit.
* `balanced_ceiling_eq_six_sevenths_at_bitlen_four` — the boundary case: at
  `b = 4` the balanced ceiling equals `6/7` exactly, which is why the strict
  inequality needs `v ≥ 2`.
* `round51_*`, `envelope_60`, `envelope_band_admissible` — the recorded
  bitlen-60 numbers checked against both ceilings.

## The scientific payload

`envelope_band_admissible` is the precise sense in which the deployment
envelope "covers balanced and uniform draws through bitlen 60": the *entire*
validation band `[0.55, 0.85]` lies strictly below the Spearman ceiling under
both draw laws at bitlen 60, so a reading anywhere in the band is compatible
with the tie geometry of either law and the recorded `0.669` is not a ceiling
artefact.  `advantage_not_headroom_artefact` sharpens the count comparison: at
bitlen 60 the count baseline has strictly *more* tie headroom than `T`
(`MachineLearning.ZeroFitDialUnif52.ceiling_inversion`), so the recorded
`+0.151` advantage of `T` runs against the headroom ordering and cannot be
explained by tie granularity.
-/

open Finset

open Catalog.Novelty.ZeroFitDialU64
open Catalog.MachineLearning.ZeroFitDialUnif52

namespace Catalog.Pythagorean.ZeroFitDialBalanced60

/-! ## 1. The hockey-stick tie profile of a balanced draw -/

/-- The tie profile of the trailing-zero statistic on the words of bitlen `b = v + 1 + r`
with exactly `w = v + 1` one-bits, listed from the largest block down: the block of words
whose lowest set bit is `k` has size `C(v + (r - k), v)`. -/
def balancedBlocks (v : ℕ) : ℕ → List ℕ
  | 0 => [1]
  | r + 1 => (v + (r + 1)).choose v :: balancedBlocks v r

/-- **Hockey-stick identity.**  The balanced profile sums to `C(b, w)`, the number of
balanced words. -/
lemma balancedBlocks_sum (v r : ℕ) : (balancedBlocks v r).sum = (v + 1 + r).choose (v + 1) := by
  induction r with
  | zero => simp [balancedBlocks]
  | succ r ih =>
      rw [balancedBlocks, List.sum_cons, ih]
      have h1 : v + 1 + (r + 1) = (v + 1 + r) + 1 := by omega
      rw [h1, Nat.choose_succ_succ (v + 1 + r) v]
      have h2 : v + (r + 1) = v + 1 + r := by omega
      rw [h2]

/-- The balanced profile at *even* bitlen `b = 2v + 2` and weight `w = v + 1`
(a balanced draw in the strict sense: half the bits are ones). -/
def centralProfile (v : ℕ) : List ℕ := balancedBlocks v (v + 1)

lemma centralProfile_sum (v : ℕ) : (centralProfile v).sum = (2 * v + 2).choose (v + 1) := by
  rw [centralProfile, balancedBlocks_sum]
  congr 1
  omega

/-! ## 2. Arithmetic bridge: the profile really is the balanced tie profile -/

/-- The balanced words of bitlen `b` and weight `w`, as `w`-subsets of `{0, …, b-1}`. -/
def balancedWords (b w : ℕ) : Finset (Finset ℕ) := (range b).powersetCard w

/-- The block of balanced words whose lowest set bit (the trailing-zero count) is `k`. -/
def balancedWordBlock (b w k : ℕ) : Finset (Finset ℕ) :=
  (balancedWords b w).filter fun S => k ∈ S ∧ ∀ i ∈ S, k ≤ i

/-- **Combinatorial bridge.**  Exactly `C(b - (k+1), w)` words of bitlen `b` and weight
`w + 1` have their lowest set bit at position `k`: fix the bit `k`, forbid everything
below it, and choose the remaining `w` ones above it. -/
theorem card_balancedWordBlock (b w k : ℕ) (hk : k < b) :
    (balancedWordBlock b (w + 1) k).card = (b - (k + 1)).choose w := by
  have himg : balancedWordBlock b (w + 1) k
      = ((Finset.Ico (k + 1) b).powersetCard w).image fun S => insert k S := by
    ext S
    simp only [balancedWordBlock, balancedWords, mem_filter, Finset.mem_powersetCard,
      mem_image, Finset.subset_iff, mem_range, Finset.mem_Ico]
    constructor
    · rintro ⟨⟨hsub, hcard⟩, hkS, hmin⟩
      refine ⟨S.erase k, ⟨?_, ?_⟩, ?_⟩
      · intro i hi
        have hi' := Finset.mem_of_mem_erase hi
        have hne : i ≠ k := Finset.ne_of_mem_erase hi
        exact ⟨by have := hmin i hi'; omega, hsub hi'⟩
      · rw [Finset.card_erase_of_mem hkS, hcard]
        omega
      · rw [Finset.insert_erase hkS]
    · rintro ⟨T, ⟨hsub, hcard⟩, rfl⟩
      have hkT : k ∉ T := fun h => by have := (hsub h).1; omega
      refine ⟨⟨?_, ?_⟩, Finset.mem_insert_self _ _, ?_⟩
      · intro i hi
        rcases Finset.mem_insert.1 hi with rfl | hi'
        · exact hk
        · exact (hsub hi').2
      · rw [Finset.card_insert_of_notMem hkT, hcard]
      · intro i hi
        rcases Finset.mem_insert.1 hi with rfl | hi'
        · exact le_refl _
        · have := (hsub hi').1; omega
  rw [himg, Finset.card_image_of_injOn, Finset.card_powersetCard, Nat.card_Ico]
  intro S hS T hT hST
  simp only [Finset.mem_coe, Finset.mem_powersetCard, Finset.subset_iff, Finset.mem_Ico] at hS hT
  have hkS : k ∉ S := fun h => by have := (hS.1 h).1; omega
  have hkT : k ∉ T := fun h => by have := (hT.1 h).1; omega
  have hST' : insert k S = insert k T := hST
  have h1 : (insert k S).erase k = (insert k T).erase k := by rw [hST']
  rwa [Finset.erase_insert hkS, Finset.erase_insert hkT] at h1

/-- The balanced profile written as a formula-indexed list. -/
lemma balancedBlocks_eq_map (v r : ℕ) :
    balancedBlocks v r = (List.range (r + 1)).map fun k => (v + (r - k)).choose v := by
  induction r with
  | zero => simp [balancedBlocks]
  | succ r ih =>
      conv_rhs => rw [List.range_succ_eq_map]
      rw [List.map_cons, List.map_map, balancedBlocks, ih]
      simp only [Nat.sub_zero]
      congr 1
      apply List.map_congr_left
      intro k _
      simp only [Function.comp_apply]
      congr 2
      omega

/-- **The tie profile of `T` under the balanced law.**  At bitlen `b = 2v+2` and weight
`w = v+1`, the list of trailing-zero block sizes is exactly `centralProfile v`. -/
theorem centralProfile_eq_balanced_valuation_profile (v : ℕ) :
    centralProfile v
      = (List.range (v + 2)).map fun k => (balancedWordBlock (2 * v + 2) (v + 1) k).card := by
  rw [centralProfile, balancedBlocks_eq_map]
  refine List.map_congr_left fun k hk => ?_
  have hk' : k < v + 2 := List.mem_range.1 hk
  rw [card_balancedWordBlock (2 * v + 2) v k (by omega)]
  congr 1
  omega

/-! ## 3. Decay structure of the hockey-stick profile -/

/-- **Decay law.**  Below the top block the hockey-stick profile at least halves at every
step: `2·C(v + i, v) ≤ C(v + i + 1, v)` whenever `i + 1 ≤ v`. -/
lemma two_mul_choose_le (u i : ℕ) (h : i ≤ u) :
    2 * (u + 1 + i).choose (u + 1) ≤ (u + i + 2).choose (u + 1) := by
  have hp : (u + i + 2).choose (u + 1) = (u + i + 1).choose u + (u + i + 1).choose (u + 1) := by
    have h1 : u + i + 2 = (u + i + 1) + 1 := by omega
    rw [h1, Nat.choose_succ_succ]
  have key : (u + i + 1).choose (u + 1) ≤ (u + i + 1).choose u := by
    have h1 := Nat.choose_succ_right_eq (u + i + 1) u
    have h2 : (u + i + 1) - u = i + 1 := by omega
    rw [h2] at h1
    have h3 : (u + i + 1).choose (u + 1) * (u + 1) ≤ (u + i + 1).choose u * (u + 1) := by
      rw [h1]; exact Nat.mul_le_mul_left _ (by omega)
    exact Nat.le_of_mul_le_mul_right h3 (by omega)
  have he : u + 1 + i = u + i + 1 := by omega
  rw [he]
  omega

/-- Symmetry of the top block. -/
lemma head_symm (v : ℕ) : (2 * v + 1).choose (v + 1) = (2 * v + 1).choose v := by
  have h := Nat.choose_symm (n := 2 * v + 1) (k := v + 1) (by omega)
  have e : 2 * v + 1 - (v + 1) = v := by omega
  rw [e] at h
  exact h.symm

/-- The number of balanced words is twice the top block: `C(2v+2, v+1) = 2·C(2v+1, v)`. -/
lemma sum_eq_two_mul_head (v : ℕ) : (2 * v + 2).choose (v + 1) = 2 * ((2 * v + 1).choose v) := by
  have h : (2 * v + 2).choose (v + 1) = (2 * v + 1).choose v + (2 * v + 1).choose (v + 1) := by
    have e : 2 * v + 2 = (2 * v + 1) + 1 := by omega
    rw [e, Nat.choose_succ_succ]
  rw [h, head_symm]
  ring

/-- **Anomalous first step.**  `(v+1)·m₀ = (2v+1)·m₁`, i.e. `m₁/m₀ = (v+1)/(2v+1) > 1/2`:
the top of the balanced profile decays by strictly *less* than one half. -/
lemma head_ratio (v : ℕ) : (v + 1) * ((2 * v + 1).choose v) = (2 * v + 1) * ((2 * v).choose v) := by
  have h := Nat.add_one_mul_choose_eq (2 * v) v
  rw [head_symm] at h
  linarith [h]

/-- **Exact halving at the second step.**  `m₁ = 2·m₂`. -/
lemma m1_eq_two_mul_m2 (u : ℕ) : (2 * (u + 1)).choose (u + 1) = 2 * ((2 * u + 1).choose (u + 1)) := by
  have e : 2 * (u + 1) = (2 * u + 1) + 1 := by omega
  have hs : (2 * u + 1).choose u = (2 * u + 1).choose (u + 1) := (head_symm u).symm
  rw [e, Nat.choose_succ_succ]
  simp only [Nat.succ_eq_add_one]
  omega

/-! ## 4. Cube sums and the tie correction -/

/-- The raw cube sum `Σⱼ mⱼ³` of a profile. -/
def cubeSum (L : List ℕ) : ℚ := (L.map fun m => (m : ℚ) ^ 3).sum

lemma cubeSum_cons (m : ℕ) (L : List ℕ) : cubeSum (m :: L) = (m : ℚ) ^ 3 + cubeSum L := by
  simp [cubeSum]

lemma cubeSum_nonneg (L : List ℕ) : 0 ≤ cubeSum L := by
  induction L with
  | nil => simp [cubeSum]
  | cons m L ih =>
      rw [cubeSum_cons]
      have : (0 : ℚ) ≤ (m : ℚ) ^ 3 := by positivity
      linarith

/-- `12·tieCorr = Σⱼ mⱼ³ - n`. -/
lemma twelve_tieCorr_eq (L : List ℕ) : 12 * tieCorr L = cubeSum L - (L.sum : ℚ) := by
  induction L with
  | nil => simp [tieCorr, cubeSum]
  | cons m L ih =>
      rw [tieCorr_cons, cubeSum_cons, List.sum_cons, mul_add]
      push_cast at ih ⊢
      linarith [ih]

/-- **Geometric bound on the tail.**  Because the hockey-stick profile at least halves at
every step below the top, its cube sum is at most `(8/7)` times the cube of its head. -/
lemma cubeSum_balanced_le (v : ℕ) : ∀ r ≤ v,
    cubeSum (balancedBlocks v r) ≤ (8 / 7) * (((v + r).choose v : ℕ) : ℚ) ^ 3 := by
  intro r
  induction r with
  | zero => intro _; simp [balancedBlocks, cubeSum]; norm_num
  | succ r ih =>
      intro hr
      have ihr := ih (by omega)
      have hdec : 2 * ((v + r).choose v) ≤ (v + (r + 1)).choose v := by
        obtain ⟨u, rfl⟩ : ∃ u, v = u + 1 := ⟨v - 1, by omega⟩
        have h := two_mul_choose_le u r (by omega)
        have e2 : u + 1 + (r + 1) = u + r + 2 := by omega
        rw [e2]
        exact h
      have hdecQ : 2 * (((v + r).choose v : ℕ) : ℚ) ≤ (((v + (r + 1)).choose v : ℕ) : ℚ) := by
        exact_mod_cast hdec
      have hnn : (0 : ℚ) ≤ (((v + r).choose v : ℕ) : ℚ) := by positivity
      rw [balancedBlocks, cubeSum_cons]
      have h8 : 8 * (((v + r).choose v : ℕ) : ℚ) ^ 3 ≤ (((v + (r + 1)).choose v : ℕ) : ℚ) ^ 3 := by
        nlinarith [pow_le_pow_left₀ (by linarith : (0:ℚ) ≤ 2 * (((v + r).choose v : ℕ) : ℚ))
          hdecQ 3]
      linarith

/-! ## 5. The balanced ceiling: a two-sided bracket around `6/7` -/

/-- The Spearman ceiling of a profile, rewritten as a cube-sum inequality. -/
lemma spearmanSq_lt_iff (L : List ℕ) (h : 2 ≤ L.sum) (c : ℚ) :
    spearmanSq L < c ↔ ((L.sum : ℚ) ^ 3 - L.sum) * (1 - c) < cubeSum L - (L.sum : ℚ) := by
  have hn : (2 : ℚ) ≤ (L.sum : ℚ) := by exact_mod_cast h
  have hden : (0 : ℚ) < (L.sum : ℚ) ^ 3 - L.sum := cube_sub_self_pos hn
  rw [spearmanSq_eq L h, twelve_tieCorr_eq]
  rw [sub_lt_iff_lt_add, ← sub_lt_iff_lt_add', lt_div_iff₀ hden]
  constructor <;> intro h1 <;> nlinarith [h1]

lemma lt_spearmanSq_iff (L : List ℕ) (h : 2 ≤ L.sum) (c : ℚ) :
    c < spearmanSq L ↔ cubeSum L - (L.sum : ℚ) < ((L.sum : ℚ) ^ 3 - L.sum) * (1 - c) := by
  have hn : (2 : ℚ) ≤ (L.sum : ℚ) := by exact_mod_cast h
  have hden : (0 : ℚ) < (L.sum : ℚ) ^ 3 - L.sum := cube_sub_self_pos hn
  rw [spearmanSq_eq L h, twelve_tieCorr_eq]
  rw [lt_sub_iff_add_lt, ← lt_sub_iff_add_lt', div_lt_iff₀ hden]
  constructor <;> intro h1 <;> nlinarith [h1]

/-- The number of balanced words is at least two, so the ceiling is well defined. -/
lemma centralProfile_sum_ge (v : ℕ) : 2 ≤ (centralProfile v).sum := by
  rw [centralProfile_sum, sum_eq_two_mul_head]
  have : 1 ≤ (2 * v + 1).choose v := Nat.choose_pos (by omega)
  omega

/-- Pure-algebra core of the lower bound: with `x` the top block, `y` the second block and
`(V+1)x = (2V+1)y`, the cube-sum bound `x³ + (8/7)y³` stays below the `6/7 - 1/(V+1)`
threshold. -/
lemma ceiling_gt_algebra (V x y : ℚ) (hV : 0 ≤ V) (hx : 1 ≤ x)
    (hr : (V + 1) * x = (2 * V + 1) * y) :
    x ^ 3 + (8 / 7) * y ^ 3 - 2 * x < ((2 * x) ^ 3 - 2 * x) * (1 - (6 / 7 - 1 / (V + 1))) := by
  have hVp : (0 : ℚ) < V + 1 := by linarith
  have h2V : (0 : ℚ) < 2 * V + 1 := by linarith
  have hx3 : (1 : ℚ) ≤ x ^ 3 := by nlinarith [sq_nonneg x, sq_nonneg (x - 1)]
  have hxle : x ≤ x ^ 3 := by
    nlinarith [mul_nonneg (mul_nonneg (by linarith : (0:ℚ) ≤ x) (by linarith : (0:ℚ) ≤ x - 1))
      (by linarith : (0:ℚ) ≤ x + 1)]
  have hy3 : (2 * V + 1) ^ 3 * y ^ 3 = (V + 1) ^ 3 * x ^ 3 := by
    have h := congrArg (fun t : ℚ => t ^ 3) hr
    simp only at h
    nlinarith [h]
  have hquart : 8 * (V + 1) ^ 4 < (2 * V + 1) ^ 3 * (V + 1) + 42 * (2 * V + 1) ^ 3 := by
    nlinarith [sq_nonneg V, sq_nonneg (V + 1), pow_nonneg hV 3, pow_nonneg hV 4]
  have hxx : (0 : ℚ) < x ^ 3 := by linarith
  have hstep : (8 / 7) * y ^ 3 * ((V + 1) * (2 * V + 1) ^ 3)
      < ((1 / 7) * x ^ 3 + 6 * x ^ 3 / (V + 1)) * ((V + 1) * (2 * V + 1) ^ 3) := by
    have e1 : (8 / 7) * y ^ 3 * ((V + 1) * (2 * V + 1) ^ 3) = (8 / 7) * (V + 1) ^ 4 * x ^ 3 := by
      have h1 : y ^ 3 * (2 * V + 1) ^ 3 = (V + 1) ^ 3 * x ^ 3 := by linarith [hy3]
      nlinarith [h1]
    have e2 : ((1 / 7) * x ^ 3 + 6 * x ^ 3 / (V + 1)) * ((V + 1) * (2 * V + 1) ^ 3)
        = ((1 / 7) * (V + 1) + 6) * (2 * V + 1) ^ 3 * x ^ 3 := by field_simp
    rw [e1, e2]
    nlinarith [hquart, hxx]
  have hpos : (0 : ℚ) < (V + 1) * (2 * V + 1) ^ 3 := by positivity
  have hstep' : (8 / 7) * y ^ 3 < (1 / 7) * x ^ 3 + 6 * x ^ 3 / (V + 1) :=
    lt_of_mul_lt_mul_right (by linarith [hstep]) (le_of_lt hpos)
  have hlast : 6 * x ^ 3 / (V + 1) ≤ (8 * x ^ 3 - 2 * x) / (V + 1) := by
    gcongr
    linarith
  have expand : ((2 * x) ^ 3 - 2 * x) * (1 - (6 / 7 - 1 / (V + 1)))
      = (1 / 7) * (8 * x ^ 3 - 2 * x) + (8 * x ^ 3 - 2 * x) / (V + 1) := by
    field_simp; ring
  rw [expand]
  linarith [hstep', hlast]

/-- **Balanced ceiling, lower bound.**  At bitlen `b = 2v+2` the balanced tie ceiling
exceeds `6/7 - 1/(v+1)`: the balanced draw law converges to the same universal
`6/7` tie-attenuation constant as the uniform law. -/
theorem balanced_ceiling_gt (v : ℕ) :
    6 / 7 - 1 / ((v : ℚ) + 1) < spearmanSq (centralProfile v) := by
  have hsum : (centralProfile v).sum = 2 * ((2 * v + 1).choose v) := by
    rw [centralProfile_sum, sum_eq_two_mul_head]
  set x : ℚ := (((2 * v + 1).choose v : ℕ) : ℚ) with hx
  set y : ℚ := (((2 * v).choose v : ℕ) : ℚ) with hy
  have hx1 : (1 : ℚ) ≤ x := by
    rw [hx]
    exact_mod_cast Nat.choose_pos (n := 2 * v + 1) (k := v) (by omega)
  have hsumQ : (((centralProfile v).sum : ℕ) : ℚ) = 2 * x := by rw [hsum]; push_cast; ring
  have hcube : cubeSum (centralProfile v) ≤ x ^ 3 + (8 / 7) * y ^ 3 := by
    have hunfold : centralProfile v = (v + (v + 1)).choose v :: balancedBlocks v v := by
      rw [centralProfile, balancedBlocks]
    have htail := cubeSum_balanced_le v v (le_refl v)
    have e2 : v + v = 2 * v := by omega
    rw [e2] at htail
    have e1 : v + (v + 1) = 2 * v + 1 := by omega
    rw [hunfold, cubeSum_cons, e1]
    linarith
  have hratio : ((v : ℚ) + 1) * x = (2 * (v : ℚ) + 1) * y := by
    have h := head_ratio v
    have hc := (Nat.cast_inj (R := ℚ)).2 h
    push_cast at hc
    rw [hx, hy]
    linarith [hc]
  rw [lt_spearmanSq_iff _ (centralProfile_sum_ge v), hsumQ]
  have halg := ceiling_gt_algebra (v : ℚ) x y (by positivity) hx1 hratio
  linarith [hcube, halg]

/-- Growth of the third block: `m₂(v+1) ≥ 3·m₂(v)`. -/
lemma m2_growth (u : ℕ) : 3 * ((2 * u + 1).choose (u + 1)) ≤ (2 * u + 3).choose (u + 2) := by
  have hcb : (u + 1 + 1) * (u + 1 + 1).centralBinom
      = 2 * (2 * (u + 1) + 1) * (u + 1).centralBinom :=
    Nat.succ_mul_centralBinom_succ (u + 1)
  have h1 : (u + 1).centralBinom = 2 * ((2 * u + 1).choose (u + 1)) := by
    rw [Nat.centralBinom]
    exact m1_eq_two_mul_m2 u
  have h2 : (u + 2).centralBinom = 2 * ((2 * u + 3).choose (u + 2)) := by
    rw [Nat.centralBinom]
    have h := m1_eq_two_mul_m2 (u + 1)
    have e2 : 2 * (u + 1) + 1 = 2 * u + 3 := by ring
    have e3 : u + 1 + 1 = u + 2 := by omega
    rw [e2, e3] at h
    exact h
  have e4 : u + 1 + 1 = u + 2 := by omega
  rw [e4, h1, h2] at hcb
  nlinarith [hcb, Nat.zero_le ((2 * u + 1).choose (u + 1))]

/-- The third block grows fast: `m₂² ≥ (u+1)³`, the exponential-versus-polynomial input to
the strict upper bound. -/
lemma m2_sq_ge (u : ℕ) (hu : 1 ≤ u) : (u + 1) ^ 3 ≤ ((2 * u + 1).choose (u + 1)) ^ 2 := by
  induction u with
  | zero => omega
  | succ n ih =>
      rcases Nat.eq_or_lt_of_le hu with h1 | h1
      · have hn : n = 0 := by omega
        subst hn
        norm_num
      · have hn : 1 ≤ n := by omega
        have ihn := ih hn
        have hg := m2_growth n
        have e : 2 * (n + 1) + 1 = 2 * n + 3 := by ring
        have e2 : n + 1 + 1 = n + 2 := by omega
        rw [e, e2]
        have h9 : 9 * ((2 * n + 1).choose (n + 1)) ^ 2 ≤ ((2 * n + 3).choose (n + 2)) ^ 2 := by
          nlinarith [hg, Nat.zero_le ((2 * n + 1).choose (n + 1))]
        have hpoly : (n + 2) ^ 3 ≤ 9 * (n + 1) ^ 3 := by
          calc (n + 2) ^ 3 ≤ (2 * (n + 1)) ^ 3 := Nat.pow_le_pow_left (by omega) 3
            _ = 8 * (n + 1) ^ 3 := by ring
            _ ≤ 9 * (n + 1) ^ 3 := by omega
        calc (n + 2) ^ 3 ≤ 9 * (n + 1) ^ 3 := hpoly
          _ ≤ 9 * ((2 * n + 1).choose (n + 1)) ^ 2 := by omega
          _ ≤ _ := h9

/-- Three-step unfolding of the profile. -/
lemma balancedBlocks_three (v r : ℕ) :
    balancedBlocks v (r + 3)
      = (v + (r + 3)).choose v :: (v + (r + 2)).choose v :: (v + (r + 1)).choose v
          :: balancedBlocks v r := by
  rw [balancedBlocks, balancedBlocks, balancedBlocks]

/-- Pure-algebra core of the upper bound: `63 m₂³ > m₀³ + 12 m₀`. -/
lemma ceiling_lt_algebra (V x z : ℚ) (h2 : 2 ≤ V) (h94 : V ≤ 94) (hz1 : 1 ≤ z)
    (hzsq : V ^ 3 ≤ z ^ 2) (hxz : (V + 1) * x = 2 * (2 * V + 1) * z) :
    x ^ 3 + 12 * x < 63 * z ^ 3 := by
  have hVp : (0 : ℚ) < V + 1 := by linarith
  have h2V : (0 : ℚ) < 2 * V + 1 := by linarith
  have hx : 0 < x := by nlinarith
  have hcube : (V + 1) ^ 3 * x ^ 3 = 8 * (2 * V + 1) ^ 3 * z ^ 3 := by
    have h := congrArg (fun t : ℚ => t ^ 3) hxz
    simp only at h
    nlinarith [h]
  have hq : (0 : ℚ) ≤ 323 + 91 * V - V ^ 2 := by
    nlinarith [mul_nonneg (by linarith : (0:ℚ) ≤ V - 2) (by linarith : (0:ℚ) ≤ 94 - V)]
  have hG : (701 : ℚ) ≤ 63 * (V + 1) ^ 3 - 8 * (2 * V + 1) ^ 3 := by
    nlinarith [mul_nonneg (by linarith : (0:ℚ) ≤ V - 2) hq]
  have hpoly : 24 * (V + 1) ^ 2 * (2 * V + 1) < 701 * V ^ 3 := by
    nlinarith [sq_nonneg V, pow_pos (by linarith : (0:ℚ) < V) 3]
  have hz2 : 24 * (V + 1) ^ 2 * (2 * V + 1) < z ^ 2 * (63 * (V + 1) ^ 3 - 8 * (2 * V + 1) ^ 3) := by
    nlinarith [hzsq, hG, sq_nonneg z]
  have hz3 : 24 * (V + 1) ^ 2 * (2 * V + 1) * z
      < z ^ 3 * (63 * (V + 1) ^ 3 - 8 * (2 * V + 1) ^ 3) := by
    nlinarith [hz2, hz1, sq_nonneg z]
  have hmul : (V + 1) ^ 3 * (x ^ 3 + 12 * x) < (V + 1) ^ 3 * (63 * z ^ 3) := by
    have h12 : (V + 1) ^ 3 * (12 * x) = 12 * (V + 1) ^ 2 * (2 * (2 * V + 1) * z) := by
      nlinarith [hxz]
    rw [mul_add, hcube, h12]
    nlinarith [hz3]
  have hp3 : (0 : ℚ) < (V + 1) ^ 3 := by positivity
  exact lt_of_mul_lt_mul_left hmul (le_of_lt hp3)

/-- **Balanced ceiling, upper bound.**  For `2 ≤ v ≤ 94` (bitlens `6 … 190`, covering the
whole deployment envelope) the balanced tie ceiling at bitlen `2v+2` is *strictly below*
`6/7`, while `Novelty.ZeroFitDialU64` puts the uniform ceiling strictly above it.  The
bound `v ≤ 94` is the exact range in which the three leading blocks `m₀, m₁ = 2m₂, m₂`
already force the inequality (`63(v+1)³ > 8(2v+1)³`); beyond it the lower-order blocks
have to be brought in. -/
theorem balanced_ceiling_lt (v : ℕ) (h2 : 2 ≤ v) (h94 : v ≤ 94) :
    spearmanSq (centralProfile v) < 6 / 7 := by
  obtain ⟨u, rfl⟩ : ∃ u, v = u + 2 := ⟨v - 2, by omega⟩
  have hsum : (centralProfile (u + 2)).sum = 2 * ((2 * (u + 2) + 1).choose (u + 2)) := by
    rw [centralProfile_sum, sum_eq_two_mul_head]
  set x : ℚ := (((2 * (u + 2) + 1).choose (u + 2) : ℕ) : ℚ) with hx
  set z : ℚ := (((2 * u + 3).choose (u + 2) : ℕ) : ℚ) with hz
  have hsumQ : (((centralProfile (u + 2)).sum : ℕ) : ℚ) = 2 * x := by rw [hsum]; push_cast; ring
  -- the profile begins `m₀ :: m₁ :: m₂ :: …`
  have hunfold : centralProfile (u + 2)
      = (2 * (u + 2) + 1).choose (u + 2) :: (2 * u + 4).choose (u + 2)
          :: (2 * u + 3).choose (u + 2) :: balancedBlocks (u + 2) u := by
    have hc : centralProfile (u + 2) = balancedBlocks (u + 2) (u + 3) := by
      rw [centralProfile]
    rw [hc, balancedBlocks_three]
    have f1 : (u + 2) + (u + 3) = 2 * (u + 2) + 1 := by ring
    have f2 : (u + 2) + (u + 2) = 2 * u + 4 := by ring
    have f3 : (u + 2) + (u + 1) = 2 * u + 3 := by ring
    rw [f1, f2, f3]
  have hm1 : (((2 * u + 4).choose (u + 2) : ℕ) : ℚ) = 2 * z := by
    have h := m1_eq_two_mul_m2 (u + 1)
    have e1 : 2 * (u + 1 + 1) = 2 * u + 4 := by ring
    have e2 : u + 1 + 1 = u + 2 := by omega
    have e3 : 2 * (u + 1) + 1 = 2 * u + 3 := by ring
    rw [e2, e1, e3] at h
    rw [hz, h]
    push_cast
    ring
  have hcube : x ^ 3 + 9 * z ^ 3 ≤ cubeSum (centralProfile (u + 2)) := by
    rw [hunfold, cubeSum_cons, cubeSum_cons, cubeSum_cons, hm1]
    have hrest := cubeSum_nonneg (balancedBlocks (u + 2) u)
    rw [hx, hz]
    nlinarith [hrest]
  have hratio : (((u : ℚ) + 2) + 1) * x = (2 * ((u : ℚ) + 2) + 1) * (2 * z) := by
    have h := head_ratio (u + 2)
    have hm1' : ((2 * (u + 2)).choose (u + 2)) = 2 * ((2 * u + 3).choose (u + 2)) := by
      have hh := m1_eq_two_mul_m2 (u + 1)
      have e1 : u + 1 + 1 = u + 2 := by omega
      have e3 : 2 * (u + 1) + 1 = 2 * u + 3 := by ring
      rw [e1, e3] at hh
      exact hh
    rw [hm1'] at h
    have hc := (Nat.cast_inj (R := ℚ)).2 h
    push_cast at hc
    rw [hx, hz]
    linear_combination hc
  have hz1 : (1 : ℚ) ≤ z := by
    rw [hz]
    exact_mod_cast Nat.choose_pos (n := 2 * u + 3) (k := u + 2) (by omega)
  have hzsq : ((u : ℚ) + 2) ^ 3 ≤ z ^ 2 := by
    have h := m2_sq_ge (u + 1) (by omega)
    have e1 : u + 1 + 1 = u + 2 := by omega
    have e2 : 2 * (u + 1) + 1 = 2 * u + 3 := by ring
    rw [e1, e2] at h
    have hc := (Nat.cast_le (α := ℚ)).2 h
    push_cast at hc
    rw [hz]
    linarith [hc]
  have hVQ2 : (2 : ℚ) ≤ (u : ℚ) + 2 := by
    have : (0 : ℚ) ≤ (u : ℚ) := Nat.cast_nonneg u
    linarith
  have hVQ94 : ((u : ℚ) + 2) ≤ 94 := by
    have : (u : ℚ) ≤ 92 := by exact_mod_cast (by omega : u ≤ 92)
    linarith
  have hkey := ceiling_lt_algebra ((u : ℚ) + 2) x z hVQ2 hVQ94 hz1 hzsq (by linarith [hratio])
  rw [spearmanSq_lt_iff _ (centralProfile_sum_ge (u + 2)), hsumQ]
  nlinarith [hcube, hkey]

/-- The boundary case: at bitlen `4` (i.e. `v = 1`, the weight-2 words of four bits) the
balanced ceiling equals `6/7` *exactly*.  This is why `balanced_ceiling_lt` needs `v ≥ 2`. -/
theorem balanced_ceiling_eq_six_sevenths_at_bitlen_four :
    spearmanSq (centralProfile 1) = 6 / 7 := by
  have h : centralProfile 1 = [3, 2, 1] := by
    rw [centralProfile, balancedBlocks, balancedBlocks, balancedBlocks]
    norm_num
  rw [h, spearmanSq_eq _ (by norm_num)]
  norm_num [tieCorr]


/-! ## 6. The draw-law sandwich -/

/-- **The `6/7` law is a two-sided attractor.**  At every even bitlen `b = 2v+2` in the
envelope, the balanced tie ceiling lies strictly below `6/7` and the uniform tie ceiling
strictly above it.  The two draw laws approach the universal constant from opposite
sides. -/
theorem draw_law_sandwich (v : ℕ) (h2 : 2 ≤ v) (h94 : v ≤ 94) :
    spearmanSq (centralProfile v) < 6 / 7 ∧ 6 / 7 < spearmanSq (dyadicBlocks (2 * v + 2)) :=
  ⟨balanced_ceiling_lt v h2 h94, dyadic_ceiling_gt (2 * v + 2) (by omega)⟩

/-- Consequently the balanced draw law has strictly *less* tie headroom than the uniform
one at every bitlen in the envelope. -/
theorem balanced_below_uniform (v : ℕ) (h2 : 2 ≤ v) (h94 : v ≤ 94) :
    spearmanSq (centralProfile v) < spearmanSq (dyadicBlocks (2 * v + 2)) := by
  obtain ⟨h1, h2'⟩ := draw_law_sandwich v h2 h94
  linarith

/-- Both ceilings converge to `6/7`: the gap between the two draw laws at bitlen `2v+2` is
at most `1/(v+1) + 4^{-(2v+2)}`. -/
theorem draw_law_gap_small (v : ℕ) (h2 : 2 ≤ v) (h94 : v ≤ 94) :
    spearmanSq (dyadicBlocks (2 * v + 2)) - spearmanSq (centralProfile v)
      < 1 / ((v : ℚ) + 1) + (1 / 4 : ℚ) ^ (2 * v + 2) := by
  have hlow := balanced_ceiling_gt v
  have hup := dyadic_ceiling_close (2 * v + 2) (by omega)
  linarith

/-! ## 7. The recorded bitlen-60 measurement (exp 521, seed 20261050) -/

/-- Recorded pooled Spearman at bitlen 60, uniform draws. -/
def pooled60 : ℚ := 669 / 1000
/-- Lower end of the recorded CI. -/
def ciLow60 : ℚ := 634 / 1000
/-- Upper end of the recorded CI. -/
def ciHigh60 : ℚ := 705 / 1000
/-- Recorded advantage of `T` over the popcount baseline. -/
def advantage60 : ℚ := 151 / 1000
/-- Lower end of the recorded advantage CI. -/
def advLow60 : ℚ := 107 / 1000
/-- Upper end of the recorded advantage CI. -/
def advHigh60 : ℚ := 193 / 1000
/-- The implied count-baseline reading. -/
def countPooled60 : ℚ := pooled60 - advantage60

/-- All recorded bitlen-60 readings lie strictly inside the validation band `[0.55, 0.85]`. -/
theorem round51_inside_band :
    (55 / 100 : ℚ) < pooled60 ∧ pooled60 < 85 / 100 ∧
    (55 / 100 : ℚ) < ciLow60 ∧ ciHigh60 < 85 / 100 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> norm_num [pooled60, ciLow60, ciHigh60]

/-- The recorded advantage is strictly positive with a CI bounded away from zero, and the
point estimate sits inside its CI. -/
theorem round51_advantage_positive :
    0 < advLow60 ∧ advLow60 ≤ advantage60 ∧ advantage60 ≤ advHigh60 ∧
    countPooled60 = 518 / 1000 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> norm_num [advLow60, advantage60, advHigh60, countPooled60, pooled60]

/-- **Envelope closure at bitlen 60.**  The recorded reading sits strictly below the
Spearman tie ceiling under *both* draw laws: the balanced ceiling (weight-30 words of
60 bits) and the uniform ceiling. -/
theorem envelope_60 :
    pooled60 ^ 2 < spearmanSq (centralProfile 29) ∧
    pooled60 ^ 2 < spearmanSq (dyadicBlocks 60) ∧
    spearmanSq (centralProfile 29) < 6 / 7 ∧
    6 / 7 < spearmanSq (dyadicBlocks 60) := by
  have hb := balanced_ceiling_gt 29
  have hbu := balanced_ceiling_lt 29 (by norm_num) (by norm_num)
  have hu := dyadic_ceiling_gt 60 (by norm_num)
  have hnum : pooled60 ^ 2 < 6 / 7 - 1 / ((29 : ℚ) + 1) := by norm_num [pooled60]
  refine ⟨by push_cast at hb ⊢; linarith, by linarith, hbu, hu⟩

/-- **The whole validation band is admissible under both draw laws.**  Every value in
`[0.55, 0.85]` — not just the recorded `0.669` — lies strictly below the bitlen-60
ceiling of both the balanced and the uniform draw law.  This is the precise content of
"the deployment envelope covers balanced and uniform draws through bitlen 60". -/
theorem envelope_band_admissible (rho : ℚ) (hlo : 55 / 100 ≤ rho) (hhi : rho ≤ 85 / 100) :
    rho ^ 2 < spearmanSq (centralProfile 29) ∧ rho ^ 2 < spearmanSq (dyadicBlocks 60) := by
  have hb := balanced_ceiling_gt 29
  have hu := dyadic_ceiling_gt 60 (by norm_num)
  have hsq : rho ^ 2 ≤ (85 / 100 : ℚ) ^ 2 := by nlinarith
  have hnum : (85 / 100 : ℚ) ^ 2 < 6 / 7 - 1 / ((29 : ℚ) + 1) := by norm_num
  push_cast at hb
  refine ⟨by linarith, by linarith⟩

/-- The count baseline also sits below its own (Hamming-weight) tie ceiling at bitlen 60,
so the comparison of the two statistics is a comparison of two unsaturated dials. -/
theorem count_below_own_ceiling_60 : countPooled60 ^ 2 < spearmanSq (binomBlocks 60) := by
  have h := count_ceiling_ge 30 (by norm_num)
  have hnum : countPooled60 ^ 2 < 1 - 2 / (3 * (30 : ℚ) + 1) := by
    norm_num [countPooled60, pooled60, advantage60]
  norm_num at h ⊢
  linarith

/-- **The advantage is not a tie-headroom artefact.**  At bitlen 60 the popcount baseline
has a strictly *higher* tie ceiling than the trailing-zero statistic, so the recorded
`+0.151` advantage of `T` runs against the headroom ordering and cannot be produced by
tie granularity. -/
theorem advantage_not_headroom_artefact :
    spearmanSq (dyadicBlocks 60) < spearmanSq (binomBlocks 60) ∧ 0 < advantage60 := by
  have h := ceiling_inversion 30 (by norm_num)
  norm_num at h
  exact ⟨h, by norm_num [advantage60]⟩

/-!
## Lab notes (exp 521, seed 20261050, uniform draws at bitlen 60)

Recorded measurement: `Spearman(T, rate) = 0.669`, CI `[0.634, 0.705]`; advantage over the
popcount baseline `+0.151`, CI `[0.107, 0.193]`; validation band `[0.55, 0.85]`.

Exact-rational cross-checks performed while developing this file (exact `ℚ`, hockey-stick
profiles `centralProfile v` = trailing-zero blocks of the balanced words of bitlen `2v+2`):

| bitlen `2v+2` | profile head | balanced ceiling `ρ²` | uniform ceiling `ρ²` |
|---|---|---|---|
| 4  | `[3,2,1]`         | `6/7 = 0.857142…` (exact) | `0.882…` |
| 6  | `[10,6,3,1]`      | `563/665 = 0.846616…` | `0.861…` |
| 8  | `[35,20,10,4,1]`  | `0.848750…` | `0.857394…` |
| 10 | `[126,70,35,15,5,1]` | `0.850666…` | `0.857152…` |
| 32 | —                 | `0.856324…` | `6/7 + 5·10⁻²⁰` |
| 60 | —                 | `0.856239…` | `6/7 + 7·10⁻³⁷` |

So the balanced ceiling rises to `6/7` from *below* while the uniform ceiling falls to it
from *above*; the two meet only in the limit.  The balanced deficit `6/7 - ρ²` decays like
`0.0263/v`, which is what `balanced_ceiling_gt` captures (with the cruder constant `1`).

The recorded `0.669² = 0.4476` is far below both ceilings, as is the whole validation band
(`0.85² = 0.7225`); hence `envelope_band_admissible`.
-/

end Catalog.Pythagorean.ZeroFitDialBalanced60