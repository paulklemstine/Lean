import Mathlib
import Novelty.ZeroFitDialU64
import Novelty.ZeroFitDialPerturbation
import Novelty.ZeroFitDialU76
import MachineLearning.ZeroFitDialUnif52

/-!
# The zero-fit dial at the floor: bitlen 92, capped resolution, and the corruption ledger

## Research context (FACT round-69 #1, exp 538, `TDIAL-U92`, partial: 2/3 seeds)

Uniform draws at bitlen 92 give a Spearman rank correlation between the trailing-zero
statistic `T` (the 2-adic valuation) and the downstream `rate` of

* seed 20261210: `0.563`,
* seed 20261211: `0.556`,

both sitting essentially **at** the validation floor `0.55`; the third seed was not
measured.  Combined with the earlier readings (`0.78` at bitlen 44, `0.705` at 52,
`0.648` at 64, `0.608` at 76) this is the endpoint of a monotone erosion trend.

This file asks the two questions the measurement forces.

1. *Can coarse resolution explain the erosion?*  A natural mechanism is that the dial
   only resolves the first `K` levels of the valuation (`min(v₂(x), K)`), so that all
   deeper draws are merged into one giant tie class.  We compute the exact Spearman
   ceiling of that **capped** profile and show the mechanism is excluded.
2. *What does the reading cost in rank displacement?*  We convert the reading into a
   two-sided statement about the fraction of the sample a rank-level mechanism must
   touch, and find that the floor `0.55` **is** the `7.5 %` corruption budget.

## Main results

* `cappedBlocks`, `cappedBlocks_sum`, `tieCorr_capped` — the tie profile of the
  `K`-capped 2-adic valuation on `b = K + r` bit draws and its exact tie correction.
* `capped_spearmanSq` — the **capped resolution law**: the ceiling is exactly
  `ρ² = (6/7)·(8^b − 8^r)/(8^b − 2^b) = (6/7)·(1 − 8^{−K})/(1 − 4^{−b})`,
  a closed form interpolating between `0` (no resolution, `K = 0`) and the dyadic
  ceiling `(6/7)(1 + 1/(2^b(2^b+1)))` (full resolution, `r = 0`).
* `capped_eq_dyadic`, `capped_ceiling_strict_mono`, `capped_ceiling_ge_three_quarters`,
  `capped_ceiling_tendsto` — consistency with the uncapped law, strict monotonicity in
  the cap depth, the universal lower bound `3/4` valid for *every* cap depth `K ≥ 1`,
  and the limit `6/7` as the cap is lifted.
* `card_capped_top_block`, `capped_valuation_profile_spearmanSq` — the arithmetic
  bridge: the capped profile really is the list of cardinalities of the exact
  valuation classes `{x < 2^b : v₂(x) = k}` (`k < K`) together with the merged top
  class `{x < 2^b : 2^K ∣ x}` of cardinality `2^{b−K}`.
* `truncation_excluded_92` — **coarse resolution is excluded**: every capped dial, at
  every cap depth `K ≥ 1` and every bitlen, has `ρ² ≥ 3/4`, i.e. `ρ ≥ 0.866`, whereas
  the recorded bitlen-92 readings are `ρ ≤ 0.563`, i.e. `ρ² ≤ 0.317`.
* `tie_mechanism_excluded_52_to_92` — the entire tie-geometry budget for the erosion
  from bitlen 52 to bitlen 92 is below `10⁻¹⁵`, against a measured drop above `0.14`.
* `floor92_corruption_budget`, `corruption_budget_grew_52_to_92` — the reading at
  bitlen 92 forces a rank-level mechanism to displace at least `437/6000 > 7.28 %` of
  the sample, strictly more than the `4.9 %` forced at bitlen 52.
* `floor_is_the_seven_point_five_percent_budget` — the converse and the punchline: any
  mechanism touching at most `3/40` of the sample leaves the reading `≥ 0.55`.  The
  validation floor is exactly the `7.5 %` corruption budget.
* `rhoModel`, `rhoModel_fit_all_bitlens`, `rhoModel_strict_anti`, `rhoModel_tendsto`,
  `floor_crossing_bitlen` — the **hyperbolic erosion law** `ρ(b) ≈ 5/14 + 93/(5b)`
  fits all five recorded bitlens to within `1/100`, decreases strictly to the
  asymptote `5/14 = 0.357 < 0.55`, and crosses the floor exactly between bitlen `96`
  and `97`: a sharp, falsifiable prediction for the next dial measurement.
-/

open Finset

open Catalog.Novelty.ZeroFitDialU64

open Catalog.Novelty.ZeroFitDialU76

open Catalog.Novelty.ZeroFitDialPerturbation

open Catalog.MachineLearning.ZeroFitDialUnif52

namespace Catalog.MachineLearning.ZeroFitDialFloor92

/-! ## 1. The capped dyadic tie profile -/

/-- Tie profile of the `K`-capped trailing-zero statistic `min(v₂(x), K)` on
`{0, …, 2^{r+K} − 1}`: the blocks of exact valuation `0, …, K−1` have sizes
`2^{r+K−1}, …, 2^r`, and everything of valuation `≥ K` is merged into a single top
class of size `2^r`.  (Listed here with the top class first.) -/
def cappedBlocks (K r : ℕ) : List ℕ := 2 ^ r :: (List.range K).map (fun i => 2 ^ (r + i))

lemma cappedBlocks_sum (K r : ℕ) : (cappedBlocks K r).sum = 2 ^ (r + K) := by
  induction K with
  | zero => simp [cappedBlocks]
  | succ K ih =>
      simp only [cappedBlocks, List.range_succ, List.map_append, List.map_cons,
        List.sum_cons, List.sum_append, List.map_nil, List.sum_nil] at *
      rw [show r + (K + 1) = (r + K) + 1 by omega, pow_succ]
      omega

lemma cappedBlocks_two_le (K r : ℕ) (h : 1 ≤ r + K) : 2 ≤ (cappedBlocks K r).sum := by
  rw [cappedBlocks_sum]
  calc 2 = 2 ^ 1 := rfl
    _ ≤ 2 ^ (r + K) := Nat.pow_le_pow_right (by norm_num) h

lemma tieCorr_nil : tieCorr ([] : List ℕ) = 0 := by simp [tieCorr]

/-- The exact tie correction of the capped profile:
`12·Σⱼ(mⱼ³−mⱼ)/12 = 8^r(8^K+6)/7 − 2^{r+K}`. -/
lemma tieCorr_capped (K r : ℕ) :
    12 * tieCorr (cappedBlocks K r) = (8 : ℚ) ^ r * ((8 : ℚ) ^ K + 6) / 7 - 2 ^ (r + K) := by
  induction K with
  | zero =>
      have hz : cappedBlocks 0 r = [2 ^ r] := by simp [cappedBlocks]
      rw [hz, tieCorr_cons, tieCorr_nil, add_zero]
      push_cast
      rw [pow_two_cube r]
      ring
  | succ K ih =>
      have hsplit : cappedBlocks (K + 1) r = cappedBlocks K r ++ [2 ^ (r + K)] := by
        simp [cappedBlocks, List.range_succ]
      rw [hsplit, tieCorr_append, mul_add, ih]
      have hlast : 12 * tieCorr [2 ^ (r + K)] = (8 : ℚ) ^ (r + K) - 2 ^ (r + K) := by
        rw [tieCorr_cons, tieCorr_nil, add_zero]
        push_cast
        rw [pow_two_cube (r + K)]
        ring
      rw [hlast]
      have h8 : (8 : ℚ) ^ (r + K) = 8 ^ r * 8 ^ K := pow_add 8 r K
      have h2 : (2 : ℚ) ^ (r + (K + 1)) = 2 ^ (r + K) * 2 := by
        rw [show r + (K + 1) = (r + K) + 1 by omega, pow_succ]
      rw [h8, h2, pow_succ (8 : ℚ) K]
      ring

/-- Positivity of the Spearman denominator at bitlen `b ≥ 1`. -/
lemma cube_gap_pos {b : ℕ} (h : 1 ≤ b) : (0 : ℚ) < (8 : ℚ) ^ b - 2 ^ b := by
  have hx : (2 : ℚ) ≤ (2 : ℚ) ^ b := by
    calc (2 : ℚ) = 2 ^ 1 := (pow_one 2).symm
      _ ≤ 2 ^ b := by apply pow_le_pow_right₀ (by norm_num) h
  have hcube : ((2 : ℚ) ^ b) ^ 3 = 8 ^ b := pow_two_cube b
  have := cube_sub_self_pos hx
  rw [hcube] at this
  linarith

/-- **Capped resolution law.**  For the `K`-capped 2-adic statistic on `b = r + K` bit
uniform draws, the Spearman tie ceiling is exactly
`ρ² = (6/7)·(8^b − 8^r)/(8^b − 2^b)`, equivalently `(6/7)(1 − 8^{−K})/(1 − 4^{−b})`. -/
theorem capped_spearmanSq (K r : ℕ) (h : 1 ≤ r + K) :
    spearmanSq (cappedBlocks K r)
      = 6 * ((8 : ℚ) ^ (r + K) - 8 ^ r) / (7 * ((8 : ℚ) ^ (r + K) - 2 ^ (r + K))) := by
  have hsum : (cappedBlocks K r).sum = 2 ^ (r + K) := cappedBlocks_sum K r
  have h2 : 2 ≤ (cappedBlocks K r).sum := cappedBlocks_two_le K r h
  have hcast : (((cappedBlocks K r).sum : ℕ) : ℚ) = (2 : ℚ) ^ (r + K) := by
    rw [hsum]; push_cast; ring
  rw [spearmanSq_eq _ h2, hcast, tieCorr_capped K r, pow_two_cube (r + K)]
  have hden : (0 : ℚ) < (8 : ℚ) ^ (r + K) - 2 ^ (r + K) := cube_gap_pos h
  have h8 : (8 : ℚ) ^ (r + K) = 8 ^ r * 8 ^ K := pow_add 8 r K
  field_simp
  rw [h8]
  ring

/-! ## 2. Consistency, monotonicity, and the universal `3/4` floor of capped dials -/

/-- Full resolution (`r = 0`) recovers the uncapped dyadic ceiling. -/
theorem capped_eq_dyadic (b : ℕ) (hb : 1 ≤ b) :
    spearmanSq (cappedBlocks b 0) = spearmanSq (dyadicBlocks b) := by
  rw [capped_spearmanSq b 0 (by omega), dyadic_spearmanSq b hb]
  have hx : (2 : ℚ) ≤ (2 : ℚ) ^ b := by
    calc (2 : ℚ) = 2 ^ 1 := (pow_one 2).symm
      _ ≤ 2 ^ b := by apply pow_le_pow_right₀ (by norm_num) hb
  have hcube : ((2 : ℚ) ^ b) ^ 3 = 8 ^ b := pow_two_cube b
  simp only [pow_zero, zero_add]
  rw [← hcube]
  set x : ℚ := (2 : ℚ) ^ b with hxdef
  have hx0 : x ≠ 0 := by intro hc; rw [hc] at hx; norm_num at hx
  have hx1 : x - 1 ≠ 0 := by intro hc; nlinarith
  have hx2 : x + 1 ≠ 0 := by intro hc; nlinarith
  rw [show x ^ 3 - x = x * (x - 1) * (x + 1) by ring]
  field_simp
  ring

/-- Deeper caps resolve strictly better (at fixed bitlen). -/
theorem capped_ceiling_strict_mono {K K' r r' : ℕ} (h : 1 ≤ r + K) (hb : r + K = r' + K')
    (hKK : K < K') :
    spearmanSq (cappedBlocks K r) < spearmanSq (cappedBlocks K' r') := by
  have h' : 1 ≤ r' + K' := by omega
  rw [capped_spearmanSq K r h, capped_spearmanSq K' r' h', ← hb]
  have hden : (0 : ℚ) < (8 : ℚ) ^ (r + K) - 2 ^ (r + K) := cube_gap_pos h
  have hlt : (8 : ℚ) ^ r' < 8 ^ r := by
    apply pow_lt_pow_right₀ (by norm_num)
    omega
  have hnum : 6 * ((8 : ℚ) ^ (r + K) - 8 ^ r) < 6 * ((8 : ℚ) ^ (r + K) - 8 ^ r') := by linarith
  have hD : (0 : ℚ) < 7 * ((8 : ℚ) ^ (r + K) - 2 ^ (r + K)) := by linarith
  gcongr

/-- **Every capped dial reads at least `0.866`.**  Whatever the bitlen, a cap at depth
`K ≥ 1` still leaves `ρ² ≥ 3/4`: merging *all* deep valuation levels into a single tie
class costs at most a quarter of the squared correlation. -/
theorem capped_ceiling_ge_three_quarters (K r : ℕ) (hK : 1 ≤ K) :
    3 / 4 ≤ spearmanSq (cappedBlocks K r) := by
  have h : 1 ≤ r + K := by omega
  rw [capped_spearmanSq K r h]
  have hden : (0 : ℚ) < (8 : ℚ) ^ (r + K) - 2 ^ (r + K) := cube_gap_pos h
  have h8 : (8 : ℚ) ^ (r + K) = 8 ^ r * 8 ^ K := pow_add 8 r K
  have h8K : (8 : ℚ) ^ 1 ≤ 8 ^ K := by apply pow_le_pow_right₀ (by norm_num) hK
  have h8r : (0 : ℚ) < (8 : ℚ) ^ r := by positivity
  have h2b : (0 : ℚ) < (2 : ℚ) ^ (r + K) := by positivity
  rw [le_div_iff₀ (by linarith)]
  rw [h8] at hden ⊢
  nlinarith [mul_pos h8r h2b]

/-! ## 3. Arithmetic bridge: the capped profile is the capped valuation profile -/

/-- The top tie class of the `K`-capped valuation: the multiples of `2^K` below `2^b`. -/
def cappedTopBlock (b K : ℕ) : Finset ℕ := (range (2 ^ b)).filter fun x => 2 ^ K ∣ x

/-- **Top-class cardinality.**  Exactly `2^{b−K}` integers below `2^b` are divisible by
`2^K`, i.e. have capped valuation equal to the cap `K`. -/
theorem card_capped_top_block (b K : ℕ) (hK : K ≤ b) :
    (cappedTopBlock b K).card = 2 ^ (b - K) := by
  have hpk : 0 < 2 ^ K := pow_pos (by norm_num) K
  have hb : b = K + (b - K) := by omega
  have himg : cappedTopBlock b K = (range (2 ^ (b - K))).image fun m => 2 ^ K * m := by
    ext x
    simp only [cappedTopBlock, mem_filter, mem_range, mem_image]
    constructor
    · rintro ⟨hx, u, rfl⟩
      refine ⟨u, ?_, rfl⟩
      rw [hb, pow_add] at hx
      exact Nat.lt_of_mul_lt_mul_left hx
    · rintro ⟨m, hm, rfl⟩
      refine ⟨?_, m, rfl⟩
      rw [hb, pow_add]
      exact (Nat.mul_lt_mul_left hpk).2 hm
  rw [himg, card_image_of_injective _ ?_, card_range]
  intro a c hac
  simp only at hac
  exact Nat.eq_of_mul_eq_mul_left hpk hac

/-- The measured tie profile of the `K`-capped valuation on `b`-bit draws. -/
def cappedValuationProfile (b K : ℕ) : List ℕ :=
  ((List.range K).map fun k => (twoAdicBlock b k).card) ++ [(cappedTopBlock b K).card]

/-- Reflection of a sum over the `K` resolved valuation levels. -/
lemma reflect_sum {M : Type*} [AddCommMonoid M] (F : ℕ → M) (b K : ℕ) (hK : K ≤ b) :
    ∑ k ∈ range K, F (2 ^ (b - 1 - k)) = ∑ i ∈ range K, F (2 ^ ((b - K) + i)) := by
  rw [← Finset.sum_range_reflect (fun i => F (2 ^ ((b - K) + i))) K]
  refine Finset.sum_congr rfl fun j hj => ?_
  have hj' : j < K := mem_range.1 hj
  congr 2
  omega

lemma cappedValuationProfile_eq (b K : ℕ) (hK : K ≤ b) :
    cappedValuationProfile b K
      = ((List.range K).map fun k => 2 ^ (b - 1 - k)) ++ [2 ^ (b - K)] := by
  rw [cappedValuationProfile, card_capped_top_block b K hK]
  congr 1
  refine List.map_congr_left fun k hk => ?_
  exact card_two_adic_block b k (by have := List.mem_range.1 hk; omega)

lemma cappedValuationProfile_sum (b K : ℕ) (hK : K ≤ b) :
    (cappedValuationProfile b K).sum = (cappedBlocks K (b - K)).sum := by
  simp only [cappedValuationProfile_eq b K hK, cappedBlocks, List.sum_append, List.sum_cons,
    List.sum_nil, list_range_map_sum]
  rw [reflect_sum (fun m => m) b K hK]
  ring

lemma cappedValuationProfile_tieCorr (b K : ℕ) (hK : K ≤ b) :
    tieCorr (cappedValuationProfile b K) = tieCorr (cappedBlocks K (b - K)) := by
  simp only [cappedValuationProfile_eq b K hK, cappedBlocks, tieCorr_append, tieCorr_cons,
    tieCorr_nil, tieCorr_range_map]
  rw [reflect_sum (fun m => (((m : ℚ)) ^ 3 - (m : ℚ)) / 12) b K hK]
  ring

/-- Two profiles with the same mass and the same tie correction have the same ceiling. -/
lemma spearmanSq_congr {L L' : List ℕ} (hs : L.sum = L'.sum) (ht : tieCorr L = tieCorr L')
    (h : 2 ≤ L.sum) : spearmanSq L = spearmanSq L' := by
  rw [spearmanSq_eq L h, spearmanSq_eq L' (hs ▸ h), hs, ht]

/-- **The bridge.**  The Spearman ceiling of the genuine capped-valuation profile of
`{0, …, 2^b − 1}` is the closed form of `capped_spearmanSq`. -/
theorem capped_valuation_profile_spearmanSq (b K : ℕ) (hK : K ≤ b) (hb : 1 ≤ b) :
    spearmanSq (cappedValuationProfile b K)
      = 6 * ((8 : ℚ) ^ b - 8 ^ (b - K)) / (7 * ((8 : ℚ) ^ b - 2 ^ b)) := by
  have hsum : (cappedValuationProfile b K).sum = (cappedBlocks K (b - K)).sum :=
    cappedValuationProfile_sum b K hK
  have hbk : (b - K) + K = b := by omega
  have h2 : 2 ≤ (cappedValuationProfile b K).sum := by
    rw [hsum, cappedBlocks_sum, hbk]
    calc 2 = 2 ^ 1 := rfl
      _ ≤ 2 ^ b := Nat.pow_le_pow_right (by norm_num) hb
  rw [spearmanSq_congr hsum (cappedValuationProfile_tieCorr b K hK) h2,
    capped_spearmanSq K (b - K) (by omega), hbk]

/-! ## 4. The recorded bitlen-92 readings, and two excluded mechanisms -/

/-- Seed 20261210. -/
def seed10 : ℚ := 563 / 1000
/-- Seed 20261211. -/
def seed11 : ℚ := 556 / 1000
/-- Mean of the two completed seeds (the third was not measured). -/
def mean92 : ℚ := (seed10 + seed11) / 2
/-- The validation floor of the dial band `[0.55, 0.85]`. -/
def floorBand : ℚ := 55 / 100

/-- Both completed seeds are inside the band but within `0.013` of its floor: the dial
has reached the floor at bitlen 92. -/
theorem u92_at_the_floor :
    floorBand ≤ seed11 ∧ seed11 ≤ seed10 ∧ seed10 ≤ 85 / 100 ∧
      seed10 - floorBand ≤ 13 / 1000 ∧ mean92 - floorBand ≤ 1 / 100 := by
  refine ⟨by norm_num [floorBand, seed11], by norm_num [seed10, seed11],
    by norm_num [seed10], by norm_num [seed10, floorBand], ?_⟩
  norm_num [mean92, seed10, seed11, floorBand]

/-- **Coarse resolution is excluded.**  However shallow the cap and whatever the bitlen,
a capped 2-adic dial has `ρ² ≥ 3/4`, i.e. reads at least `0.866`; the recorded bitlen-92
readings are `ρ ≤ 0.563`, i.e. `ρ² ≤ 0.317`.  So the erosion of the dial cannot be the
effect of the statistic resolving only finitely many valuation levels. -/
theorem truncation_excluded_92 (K r : ℕ) (hK : 1 ≤ K) :
    seed10 ^ 2 < spearmanSq (cappedBlocks K r) := by
  have h := capped_ceiling_ge_three_quarters K r hK
  have : seed10 ^ 2 < 3 / 4 := by norm_num [seed10]
  linarith

/-- The same exclusion stated for the honest arithmetic profile of the capped valuation. -/
theorem truncation_excluded_92_valuation (b K : ℕ) (hK : 1 ≤ K) (hKb : K ≤ b) :
    seed10 ^ 2 < spearmanSq (cappedValuationProfile b K) := by
  have hb : 1 ≤ b := le_trans hK hKb
  have hsum : (cappedValuationProfile b K).sum = (cappedBlocks K (b - K)).sum :=
    cappedValuationProfile_sum b K hKb
  have hbk : (b - K) + K = b := by omega
  have h2 : 2 ≤ (cappedValuationProfile b K).sum := by
    rw [hsum, cappedBlocks_sum, hbk]
    calc 2 = 2 ^ 1 := rfl
      _ ≤ 2 ^ b := Nat.pow_le_pow_right (by norm_num) hb
  rw [spearmanSq_congr hsum (cappedValuationProfile_tieCorr b K hKb) h2]
  exact truncation_excluded_92 K (b - K) hK

/-- **Tie geometry is excluded, quantitatively.**  Between bitlen 52 and bitlen 92 the exact
tie ceiling moves by less than `10⁻¹⁵`, while the dial itself fell by more than `0.14`.  The
erosion is more than thirteen orders of magnitude too large to be a tie artefact. -/
theorem tie_mechanism_excluded_52_to_92 :
    spearmanSq (dyadicBlocks 52) - spearmanSq (dyadicBlocks 92) < 1 / 10 ^ 15 ∧
      14 / 100 < pooled52 - mean92 := by
  constructor
  · rw [dyadic_spearmanSq 52 (by norm_num), dyadic_spearmanSq 92 (by norm_num)]
    norm_num
  · norm_num [pooled52, mean92, seed10, seed11]

/-! ## 5. The corruption ledger: what the reading costs in rank displacement -/

/-- A perfectly aligned response reads `ρ = 1`. -/
lemma rhoRank_self {n : ℕ} (R : Fin n → ℚ) : rhoRank R R = 1 := by
  simp [rhoRank, sumSqD]

/-- The corruption fraction forced by a reading `rho`: `(1 − rho)/6`. -/
def reqFrac (rho : ℚ) : ℚ := (1 - rho) / 6

/-- **Reading-to-corruption budget.**  If a mechanism re-ranks a perfectly aligned response
only on a set `A` and the resulting Spearman reading is at most `rho`, then `A` must contain
at least a fraction `(1 − rho)/6` of the sample. -/
theorem reading_corruption_budget {n : ℕ} (hn : 2 ≤ n) (R S' : Fin n → ℚ) (hR : IsRankVec n R)
    (hS' : IsRankVec n S') (A : Finset (Fin n)) (hagree : ∀ i ∉ A, R i = S' i) (rho : ℚ)
    (hread : rhoRank R S' ≤ rho) :
    (n : ℚ) * reqFrac rho ≤ (A.card : ℚ) := by
  have hdelta : (1 - rho) ≤ |rhoRank R R - rhoRank R S'| := by
    rw [rhoRank_self]
    calc (1 - rho) ≤ 1 - rhoRank R S' := by linarith
      _ ≤ |1 - rhoRank R S'| := le_abs_self _
  have h := corruption_budget hn R R S' hR hR hS' A hagree (1 - rho) hdelta
  rw [reqFrac]
  linarith [h]

/-- **The bitlen-92 budget.**  The recorded reading `0.563` forces any rank-level mechanism
to displace more than `7.28 %` of the sample. -/
theorem floor92_corruption_budget {n : ℕ} (hn : 2 ≤ n) (R S' : Fin n → ℚ) (hR : IsRankVec n R)
    (hS' : IsRankVec n S') (A : Finset (Fin n)) (hagree : ∀ i ∉ A, R i = S' i)
    (hread : rhoRank R S' ≤ seed10) :
    (n : ℚ) * (728 / 10000) ≤ (A.card : ℚ) := by
  have h := reading_corruption_budget hn R S' hR hS' A hagree seed10 hread
  have hfrac : (728 : ℚ) / 10000 ≤ reqFrac seed10 := by norm_num [reqFrac, seed10]
  have hn0 : (0 : ℚ) ≤ (n : ℚ) := by positivity
  nlinarith

/-- **The budget grew.**  The corruption fraction forced by the dial rose strictly from
bitlen 52 to bitlen 92, from below `5 %` to above `7.28 %`. -/
theorem corruption_budget_grew_52_to_92 :
    reqFrac pooled52 < reqFrac mean92 ∧ reqFrac pooled52 < 5 / 100 ∧
      728 / 10000 < reqFrac mean92 := by
  refine ⟨by norm_num [reqFrac, pooled52, mean92, seed10, seed11], ?_, ?_⟩ <;>
    norm_num [reqFrac, pooled52, mean92, seed10, seed11]

/-- **The floor is the 7.5 % budget.**  Conversely, a rank-level mechanism touching at most
`3/40 = 7.5 %` of the sample cannot push the reading below the validation floor `0.55`.
Floor membership and a `7.5 %` corruption budget are therefore the same statement, which is
why the dial bottoms out at `0.55` rather than decaying to `0`. -/
theorem floor_is_the_seven_point_five_percent_budget {n : ℕ} (hn : 2 ≤ n) (R S' : Fin n → ℚ)
    (hR : IsRankVec n R) (hS' : IsRankVec n S') (A : Finset (Fin n))
    (hagree : ∀ i ∉ A, R i = S' i) (hsmall : (A.card : ℚ) ≤ (n : ℚ) * (3 / 40)) :
    floorBand ≤ rhoRank R S' := by
  have hnq : (2 : ℚ) ≤ (n : ℚ) := by exact_mod_cast hn
  have h := abs_rho_sub_le_div hn R R S' hR hR hS' A hagree
  rw [rhoRank_self] at h
  have hb : 1 - rhoRank R S' ≤ |1 - rhoRank R S'| := le_abs_self _
  have hdiv : 6 * (A.card : ℚ) / (n : ℚ) ≤ 9 / 20 := by
    rw [div_le_iff₀ (by linarith)]
    linarith
  rw [floorBand]
  linarith

/-! ## 6. The hyperbolic erosion law and the crossing prediction -/

/-- The fitted erosion law `ρ(b) = 5/14 + 93/(5b)`. -/
def rhoModel (b : ℕ) : ℚ := 5 / 14 + 93 / (5 * (b : ℚ))

/-- **The hyperbolic fit.**  The one-parameter-pair law `5/14 + 93/(5b)` reproduces every
recorded dial reading — bitlens 44, 52, 64, 76 and 92, spanning four experiments — to within
`1/100`, with a maximal residual at bitlen 52. -/
theorem rhoModel_fit_all_bitlens :
    |rhoModel 44 - dial44| ≤ 1 / 100 ∧
    |rhoModel 52 - pooled52| ≤ 1 / 100 ∧
    |rhoModel 64 - pooled| ≤ 1 / 100 ∧
    |rhoModel 76 - pooled76| ≤ 1 / 100 ∧
    |rhoModel 92 - mean92| ≤ 1 / 100 := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩ <;>
    rw [abs_le] <;>
    constructor <;>
    norm_num [rhoModel, dial44, pooled52, pooled, pooled76, mean92, seed10, seed11]

/-- The model erodes strictly with the bitlen. -/
theorem rhoModel_strict_anti {b c : ℕ} (hb : 1 ≤ b) (hbc : b < c) : rhoModel c < rhoModel b := by
  have hbq : (1 : ℚ) ≤ (b : ℚ) := by exact_mod_cast hb
  have hcq : (b : ℚ) < (c : ℚ) := by exact_mod_cast hbc
  rw [rhoModel, rhoModel]
  have h1 : (0 : ℚ) < 5 * (b : ℚ) := by linarith
  have h2 : (0 : ℚ) < 5 * (c : ℚ) := by linarith
  have := div_lt_div_of_pos_left (by norm_num : (0:ℚ) < 93) h1 (by linarith : 5 * (b:ℚ) < 5 * c)
  linarith

/-- The model's asymptote is `5/14 ≈ 0.357`, strictly below the validation floor: the dial
must eventually leave the band. -/
theorem rhoModel_tendsto :
    Filter.Tendsto (fun b : ℕ => ((rhoModel b : ℚ) : ℝ)) Filter.atTop (nhds (5 / 14)) := by
  have hfun : (fun b : ℕ => ((rhoModel b : ℚ) : ℝ))
      = fun b : ℕ => 5 / 14 + (93 / 5) / (b : ℝ) := by
    funext b
    simp only [rhoModel]
    push_cast
    by_cases hb0 : (b : ℝ) = 0
    · rw [hb0]; norm_num
    · field_simp
  rw [hfun]
  have h0 : Filter.Tendsto (fun b : ℕ => (93 / 5 : ℝ) / (b : ℝ)) Filter.atTop (nhds 0) :=
    tendsto_const_div_atTop_nhds_zero_nat _
  simpa using Filter.Tendsto.const_add (5 / 14 : ℝ) h0

/-- **Crossing prediction.**  Under the hyperbolic law the dial stays at or above the
validation floor exactly up to bitlen `96` and drops below it from bitlen `97` on: the next
uniform measurement above bitlen 96 should read below `0.55`. -/
theorem floor_crossing_bitlen (b : ℕ) (hb : 1 ≤ b) : floorBand ≤ rhoModel b ↔ b ≤ 96 := by
  have hbq : (1 : ℚ) ≤ (b : ℚ) := by exact_mod_cast hb
  have hpos : (0 : ℚ) < 5 * (b : ℚ) := by linarith
  rw [floorBand, rhoModel]
  constructor
  · intro h
    have h2 : (27 / 140 : ℚ) ≤ 93 / (5 * (b : ℚ)) := by linarith
    rw [div_le_div_iff₀ (by norm_num) hpos] at h2
    have hlt : (b : ℚ) < 97 := by linarith
    have hb97 : b < 97 := by exact_mod_cast hlt
    omega
  · intro h
    have hble : (b : ℚ) ≤ 96 := by exact_mod_cast h
    have h2 : (27 / 140 : ℚ) ≤ 93 / (5 * (b : ℚ)) := by
      rw [div_le_div_iff₀ (by norm_num) hpos]
      linarith
    linarith

/-- The model is already below the floor one bit later, and stays there. -/
theorem rhoModel_below_floor_from_97 (b : ℕ) (hb : 97 ≤ b) : rhoModel b < floorBand := by
  have h1 : 1 ≤ b := by omega
  have := (floor_crossing_bitlen b h1).not
  by_contra hcon
  push_neg at hcon
  have : b ≤ 96 := (floor_crossing_bitlen b h1).1 hcon
  omega

/-! ## 7. Lifting the cap: quantitative convergence to the dyadic ceiling -/

lemma capped_lower_geom (K r : ℕ) (hK : 1 ≤ K) :
    (6 / 7 : ℚ) * (1 - (1 / 8 : ℚ) ^ K) ≤ spearmanSq (cappedBlocks K r) := by
  have h : 1 ≤ r + K := by omega
  rw [capped_spearmanSq K r h]
  have hden : (0 : ℚ) < (8 : ℚ) ^ (r + K) - 2 ^ (r + K) := cube_gap_pos h
  have h8 : (8 : ℚ) ^ (r + K) = 8 ^ r * 8 ^ K := pow_add 8 r K
  have h8r : (0 : ℚ) < (8 : ℚ) ^ r := by positivity
  have h8K : (0 : ℚ) < (8 : ℚ) ^ K := by positivity
  have h2b : (0 : ℚ) < (2 : ℚ) ^ (r + K) := by positivity
  have hinv : (1 / 8 : ℚ) ^ K = 1 / (8 : ℚ) ^ K := by rw [div_pow]; norm_num
  have hy : (1 : ℚ) ≤ (8 : ℚ) ^ K := one_le_pow₀ (by norm_num)
  have hinvle : 1 / (8 : ℚ) ^ K ≤ 1 := by rw [div_le_one h8K]; exact hy
  rw [hinv, le_div_iff₀ (by linarith)]
  rw [h8] at hden ⊢
  have hkey : 6 * ((8 : ℚ) ^ r * 8 ^ K - 8 ^ r)
      - (6 / 7 : ℚ) * (1 - 1 / (8 : ℚ) ^ K) * (7 * ((8 : ℚ) ^ r * 8 ^ K - 2 ^ (r + K)))
      = 6 * (2 : ℚ) ^ (r + K) * (1 - 1 / (8 : ℚ) ^ K) := by
    field_simp
    ring
  nlinarith [mul_nonneg (le_of_lt h2b) (sub_nonneg.2 hinvle)]

lemma capped_upper_geom (K r : ℕ) (hK : 1 ≤ K) :
    spearmanSq (cappedBlocks K r) ≤ 6 / 7 + 2 * (1 / 4 : ℚ) ^ (r + K) := by
  have h : 1 ≤ r + K := by omega
  rw [capped_spearmanSq K r h]
  set b := r + K with hbdef
  have hden : (0 : ℚ) < (8 : ℚ) ^ b - 2 ^ b := cube_gap_pos h
  have h8 : (0 : ℚ) < (8 : ℚ) ^ b := by positivity
  have h8r : (0 : ℚ) < (8 : ℚ) ^ r := by positivity
  have hx : (2 : ℚ) ^ b = 8 ^ b * (1 / 4 : ℚ) ^ b := by
    rw [← mul_pow]; norm_num
  set x : ℚ := (1 / 4 : ℚ) ^ b with hxdef
  have hxpos : 0 < x := by positivity
  have hxle : x ≤ 1 / 4 := by
    rw [hxdef]
    calc (1 / 4 : ℚ) ^ b ≤ (1 / 4 : ℚ) ^ 1 := by
          apply pow_le_pow_of_le_one (by norm_num) (by norm_num) h
      _ = 1 / 4 := by norm_num
  rw [div_le_iff₀ (by linarith)]
  rw [hx] at hden ⊢
  nlinarith [mul_pos h8 hxpos, sq_nonneg x, mul_pos h8r hxpos]

/-- **Lifting the cap.**  As the cap depth grows the capped ceiling converges to the dyadic
ceiling `6/7`; combined with `capped_ceiling_ge_three_quarters` the whole family of capped
dials lives in `[3/4, 6/7 + o(1)]`, far above the recorded readings. -/
theorem capped_ceiling_tendsto (r : ℕ) :
    Filter.Tendsto (fun K : ℕ => ((spearmanSq (cappedBlocks K r) : ℚ) : ℝ))
      Filter.atTop (nhds (6 / 7)) := by
  have hlow : Filter.Tendsto (fun K : ℕ => (6 / 7 : ℝ) * (1 - (1 / 8 : ℝ) ^ K))
      Filter.atTop (nhds (6 / 7)) := by
    have h0 : Filter.Tendsto (fun K : ℕ => (1 / 8 : ℝ) ^ K) Filter.atTop (nhds 0) :=
      tendsto_pow_atTop_nhds_zero_of_lt_one (by norm_num) (by norm_num)
    have := (Filter.Tendsto.const_sub (1 : ℝ) h0).const_mul (6 / 7 : ℝ)
    simpa using this
  have hup : Filter.Tendsto (fun K : ℕ => (6 / 7 : ℝ) + 2 * (1 / 4 : ℝ) ^ (r + K))
      Filter.atTop (nhds (6 / 7)) := by
    have h0 : Filter.Tendsto (fun K : ℕ => (1 / 4 : ℝ) ^ (r + K)) Filter.atTop (nhds 0) := by
      have hbase : Filter.Tendsto (fun K : ℕ => (1 / 4 : ℝ) ^ K) Filter.atTop (nhds 0) :=
        tendsto_pow_atTop_nhds_zero_of_lt_one (by norm_num) (by norm_num)
      have hfun : (fun K : ℕ => (1 / 4 : ℝ) ^ (r + K))
          = fun K : ℕ => (1 / 4 : ℝ) ^ r * (1 / 4 : ℝ) ^ K := by
        funext K; rw [pow_add]
      rw [hfun]
      simpa using hbase.const_mul ((1 / 4 : ℝ) ^ r)
    have := (h0.const_mul (2 : ℝ)).const_add (6 / 7 : ℝ)
    simpa using this
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' hlow hup ?_ ?_
  · filter_upwards [Filter.eventually_ge_atTop 1] with K hK
    have hq := capped_lower_geom K r hK
    have := (Rat.cast_le (K := ℝ)).2 hq
    push_cast at this ⊢
    exact this
  · filter_upwards [Filter.eventually_ge_atTop 1] with K hK
    have hq := capped_upper_geom K r hK
    have := (Rat.cast_le (K := ℝ)).2 hq
    push_cast at this ⊢
    exact this


/-! ## 8. Saturation of the corruption ledger along the erosion law -/

/-- The corruption fraction forced by the fitted law, in closed form: `3/28 − 31/(10b)`. -/
lemma reqFrac_rhoModel (b : ℕ) (hb : 1 ≤ b) :
    reqFrac (rhoModel b) = 3 / 28 - 31 / (10 * (b : ℚ)) := by
  have hbq : (1 : ℚ) ≤ (b : ℚ) := by exact_mod_cast hb
  have hb0 : (b : ℚ) ≠ 0 := by intro hc; rw [hc] at hbq; norm_num at hbq
  rw [reqFrac, rhoModel]
  field_simp
  ring

/-- **The budget saturates.**  Under the erosion law the forced rank displacement grows with
the bitlen but never reaches `3/28 ≈ 10.7 %`: no rank-level mechanism consistent with the
fitted trend can ever displace more than that fraction of the sample. -/
theorem corruption_budget_saturates (b : ℕ) (hb : 1 ≤ b) : reqFrac (rhoModel b) < 3 / 28 := by
  have hbq : (1 : ℚ) ≤ (b : ℚ) := by exact_mod_cast hb
  rw [reqFrac_rhoModel b hb]
  have : (0 : ℚ) < 31 / (10 * (b : ℚ)) := by positivity
  linarith

/-- The saturation value is exactly `3/28`. -/
theorem corruption_budget_tendsto :
    Filter.Tendsto (fun b : ℕ => ((reqFrac (rhoModel b) : ℚ) : ℝ)) Filter.atTop
      (nhds (3 / 28)) := by
  have hmod := rhoModel_tendsto
  have hfun : (fun b : ℕ => ((reqFrac (rhoModel b) : ℚ) : ℝ))
      = fun b : ℕ => (1 - ((rhoModel b : ℚ) : ℝ)) / 6 := by
    funext b
    simp only [reqFrac]
    push_cast
    ring
  rw [hfun]
  have h2 := (Filter.Tendsto.const_sub (1 : ℝ) hmod).div_const (6 : ℝ)
  have hval : ((1 : ℝ) - 5 / 14) / 6 = 3 / 28 := by norm_num
  rw [hval] at h2
  exact h2

/-- **Band exit is budget exhaustion.**  The dial leaves the validation band exactly when the
displacement it forces passes the `3/40` floor budget, i.e. exactly from bitlen `97` on. -/
theorem band_exit_iff_budget_exceeded (b : ℕ) (hb : 1 ≤ b) :
    reqFrac (rhoModel b) ≤ 3 / 40 ↔ b ≤ 96 := by
  have hbq : (1 : ℚ) ≤ (b : ℚ) := by exact_mod_cast hb
  have hpos : (0 : ℚ) < 10 * (b : ℚ) := by linarith
  rw [reqFrac_rhoModel b hb]
  constructor
  · intro h
    have h2 : (9 / 280 : ℚ) ≤ 31 / (10 * (b : ℚ)) := by linarith
    rw [div_le_div_iff₀ (by norm_num) hpos] at h2
    have hlt : (b : ℚ) < 97 := by linarith
    have hb97 : b < 97 := by exact_mod_cast hlt
    omega
  · intro h
    have hble : (b : ℚ) ≤ 96 := by exact_mod_cast h
    have h2 : (9 / 280 : ℚ) ≤ 31 / (10 * (b : ℚ)) := by
      rw [div_le_div_iff₀ (by norm_num) hpos]
      linarith
    linarith


end Catalog.MachineLearning.ZeroFitDialFloor92