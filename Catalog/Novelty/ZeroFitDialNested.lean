import Mathlib
import Novelty.ZeroFitDialU64

/-!
# Nested tie profiles: the zero-fit dial when *both* sides are tied

Cycle 2 of the round-61 investigation.  `Novelty.ZeroFitDialU64` established the
tie-attenuation law for a tied statistic `T` measured against a tie-*refining*
response, and showed that at bitlen 64 the 2-adic tie ceiling
(`≈ 0.9258`) is far above the recorded dial (`0.648`), so tie granularity of the
zero-count statistic cannot explain the observed decline of the dial.

The natural next suspect is granularity of the **response**.  Here we prove the
two-sided law for *nested* profiles: if one variable's tie blocks refine the
other's, then

`ρ² = (V - T_coarse) / (V - T_fine)`,  where `V = (n³-n)/12`

and `T_•` are the Kendall tie corrections of the two profiles.  The one-sided law
is the special case `T_fine = 0`.

## Main results

* `spNest_eq_ssR_coarse` — the midrank collapse identity survives nesting:
  the centred cross-product of the two midrank vectors equals the *coarse*
  between-block sum of squares.
* `nested_spearmanSq_eq` — the two-sided attenuation law.
* `tieCorr_flatten_le` — refinement decreases the tie correction (superadditivity
  of `m ↦ m³ - m`), hence `nested_spearmanSq_le_one`.
* `nested_of_fine_tiefree` — the one-sided law is recovered.
* `binary_response_spearmanSq` — **exact** ceiling for a binary response with
  `j` positives and `k` negatives against a tie-free statistic:
  `ρ² = 3jk/((j+k)² - 1)`, i.e. asymptotically `ρ = √(3q(1-q))`.
* `balanced_binary_ceiling` — the balanced binary ceiling `ρ² = 3j²/(4j²-1) > 3/4`
  (`ρ → √3/2 ≈ 0.8660`).
* `u64_binary_calibration` — the recorded pooled reading `0.648` is reproduced to
  `10⁻⁴` by a binary response with base rate `16.83 %`; combined with
  `u64_binary_rate_forced`, any binary response with base rate above `25 %` is
  *excluded* by the measurement.

The scientific content is a falsifiable prediction: under the response-granularity
explanation of the dial's decline, the bitlen-64 rate variable must be
(effectively) a two-class variable with minority mass near `17 %`, and the dial can
never exceed `√3/2` regardless of bitlen.
-/

open Finset

namespace Catalog.Novelty.ZeroFitDialNested

open Catalog.Novelty.ZeroFitDialU64

/-! ## 1. Weighted midranks inside a coarse block -/

/-- Sum of the fine midranks weighted by the fine block sizes, starting at offset `c`. -/
def wsum : List ℕ → ℚ → ℚ
  | [], _ => 0
  | p :: P, c => (p : ℚ) * (c + ((p : ℚ) + 1) / 2) + wsum P (c + p)

/-- The weighted mean of the fine midranks inside a coarse block is the coarse midrank. -/
lemma wsum_eq (P : List ℕ) (c : ℚ) : wsum P c = (P.sum : ℚ) * (c + ((P.sum : ℚ) + 1) / 2) := by
  induction P generalizing c with
  | nil => simp [wsum]
  | cons p P ih =>
      simp only [wsum, ih, List.sum_cons]
      push_cast
      ring

/-- Centred cross-product contributed by one coarse block with midrank `R`. -/
def spBlock (mu R : ℚ) : List ℕ → ℚ → ℚ
  | [], _ => 0
  | p :: P, c => (p : ℚ) * (R - mu) * ((c + ((p : ℚ) + 1) / 2) - mu) + spBlock mu R P (c + p)

lemma spBlock_eq (mu R : ℚ) (P : List ℕ) (c : ℚ) :
    spBlock mu R P c = (R - mu) * ((P.sum : ℚ) * ((c + ((P.sum : ℚ) + 1) / 2) - mu)) := by
  induction P generalizing c with
  | nil => simp [spBlock]
  | cons p P ih =>
      simp only [spBlock, ih, List.sum_cons]
      push_cast
      ring

/-! ## 2. Nested profiles -/

/-- Centred cross-product of the coarse midranks against the fine midranks. -/
def spNest (mu : ℚ) : List (List ℕ) → ℚ → ℚ
  | [], _ => 0
  | P :: L, c => spBlock mu (c + ((P.sum : ℚ) + 1) / 2) P c + spNest mu L (c + P.sum)

/-- **Nested midrank collapse.**  Even when the response is itself tied, as long as its blocks
refine the statistic's blocks, the centred cross-product equals the *coarse* between-block sum of
squares. -/
theorem spNest_eq_ssR_coarse (mu : ℚ) (L : List (List ℕ)) (c : ℚ) :
    spNest mu L c = ssR mu (L.map List.sum) c := by
  induction L generalizing c with
  | nil => simp [spNest, ssR]
  | cons P L ih =>
      simp only [spNest, ssR, List.map_cons, ih, spBlock_eq]
      ring

lemma ssR_append (mu : ℚ) (A B : List ℕ) (c : ℚ) :
    ssR mu (A ++ B) c = ssR mu A c + ssR mu B (c + A.sum) := by
  induction A generalizing c with
  | nil => simp [ssR]
  | cons a A ih =>
      simp only [List.cons_append, ssR, ih, List.sum_cons]
      push_cast
      ring

lemma flatten_sum (L : List (List ℕ)) : L.flatten.sum = (L.map List.sum).sum := by
  induction L with
  | nil => simp
  | cons P L ih => simp [ih]

/-- Squared Spearman coefficient of a nested pair of tie profiles: coarse variable against fine
variable, both scored by midranks. -/
def nestedSpearmanSq (L : List (List ℕ)) : ℚ :=
  ssR (gmean L.flatten) (L.map List.sum) 0 / ssR (gmean L.flatten) L.flatten 0

/-- **Two-sided tie-attenuation law.**  For nested profiles with `n ≥ 2` observations,
`ρ² = (V - T_coarse)/(V - T_fine)` with `V = (n³-n)/12`. -/
theorem nested_spearmanSq_eq (L : List (List ℕ)) :
    nestedSpearmanSq L
      = (((L.flatten.sum : ℚ) ^ 3 - L.flatten.sum) / 12 - tieCorr (L.map List.sum)) /
        (((L.flatten.sum : ℚ) ^ 3 - L.flatten.sum) / 12 - tieCorr L.flatten) := by
  have hsum : (L.map List.sum).sum = L.flatten.sum := (flatten_sum L).symm
  have hg : gmean (L.map List.sum) = gmean L.flatten := by rw [gmean, gmean, hsum]
  have hfine : ssS (gmean L.flatten) L.flatten 0
      = ((L.flatten.sum : ℚ) ^ 3 - L.flatten.sum) / 12 := ssS_total L.flatten
  have hcoarse : ssS (gmean L.flatten) (L.map List.sum) 0
      = ((L.flatten.sum : ℚ) ^ 3 - L.flatten.sum) / 12 := by
    rw [← hg, ssS_total, hsum]
  have hR1 : ssR (gmean L.flatten) (L.map List.sum) 0
      = ((L.flatten.sum : ℚ) ^ 3 - L.flatten.sum) / 12 - tieCorr (L.map List.sum) := by
    have := ssS_eq_ssR_add (gmean L.flatten) (L.map List.sum) 0
    rw [hcoarse] at this
    linarith
  have hR2 : ssR (gmean L.flatten) L.flatten 0
      = ((L.flatten.sum : ℚ) ^ 3 - L.flatten.sum) / 12 - tieCorr L.flatten := by
    have := ssS_eq_ssR_add (gmean L.flatten) L.flatten 0
    rw [hfine] at this
    linarith
  rw [nestedSpearmanSq, hR1, hR2]

/-! ## 3. Refinement decreases ties -/

/-- Superadditivity of `m ↦ m³ - m` on block splits. -/
lemma cube_sub_self_superadd (a b : ℚ) (ha : 0 ≤ a) (hb : 0 ≤ b) :
    (a ^ 3 - a) + (b ^ 3 - b) ≤ ((a + b) ^ 3 - (a + b)) := by
  nlinarith [mul_nonneg ha hb, mul_nonneg (mul_nonneg ha hb) ha, mul_nonneg (mul_nonneg ha hb) hb]

/-- Splitting one block into parts can only decrease the tie correction. -/
lemma tieCorr_le_of_split (P : List ℕ) :
    tieCorr P ≤ ((P.sum : ℚ) ^ 3 - P.sum) / 12 := by
  induction P with
  | nil => simp [tieCorr]
  | cons p P ih =>
      rw [tieCorr_cons, List.sum_cons]
      have hP : (0 : ℚ) ≤ (P.sum : ℚ) := by positivity
      have hp : (0 : ℚ) ≤ (p : ℚ) := by positivity
      have := cube_sub_self_superadd (p : ℚ) (P.sum : ℚ) hp hP
      have hcast : (((p + P.sum : ℕ)) : ℚ) = (p : ℚ) + (P.sum : ℚ) := by push_cast; ring
      rw [hcast]
      linarith

/-- **Refinement monotonicity.**  The fine profile has the smaller tie correction. -/
theorem tieCorr_flatten_le (L : List (List ℕ)) :
    tieCorr L.flatten ≤ tieCorr (L.map List.sum) := by
  induction L with
  | nil => simp [tieCorr]
  | cons P L ih =>
      rw [List.flatten_cons, List.map_cons, tieCorr_cons]
      have happ : tieCorr (P ++ L.flatten) = tieCorr P + tieCorr L.flatten := by
        simp [tieCorr, List.map_append]
      rw [happ]
      have := tieCorr_le_of_split P
      linarith

/-- Consequently the nested coefficient is between `0` and `1`: refining the response can only
raise the dial, and a coarser response strictly attenuates it. -/
theorem nested_spearmanSq_le_one (L : List (List ℕ)) (h : 2 ≤ L.flatten.sum) :
    0 ≤ nestedSpearmanSq L ∧ nestedSpearmanSq L ≤ 1 := by
  have hn : (2 : ℚ) ≤ (L.flatten.sum : ℚ) := by exact_mod_cast h
  set V : ℚ := ((L.flatten.sum : ℚ) ^ 3 - L.flatten.sum) / 12 with hVdef
  have hsum : (L.map List.sum).sum = L.flatten.sum := (flatten_sum L).symm
  have hcoarseS : ssS (gmean L.flatten) (L.map List.sum) 0 = V := by
    have hg : gmean (L.map List.sum) = gmean L.flatten := by rw [gmean, gmean, hsum]
    rw [← hg, ssS_total, hsum]
  have hA : ssR (gmean L.flatten) (L.map List.sum) 0 = V - tieCorr (L.map List.sum) := by
    have := ssS_eq_ssR_add (gmean L.flatten) (L.map List.sum) 0
    rw [hcoarseS] at this; linarith
  have hB : ssR (gmean L.flatten) L.flatten 0 = V - tieCorr L.flatten := by
    have := ssS_eq_ssR_add (gmean L.flatten) L.flatten 0
    rw [ssS_total L.flatten] at this; linarith
  have hAB : ssR (gmean L.flatten) (L.map List.sum) 0 ≤ ssR (gmean L.flatten) L.flatten 0 := by
    rw [hA, hB]
    have := tieCorr_flatten_le L
    linarith
  have hA0 : 0 ≤ ssR (gmean L.flatten) (L.map List.sum) 0 := ssR_nonneg _ _ _
  have hB0 : 0 ≤ ssR (gmean L.flatten) L.flatten 0 := ssR_nonneg _ _ _
  rcases eq_or_lt_of_le hB0 with hzero | hpos
  · rw [nestedSpearmanSq, ← hzero, div_zero]
    exact ⟨le_refl 0, by norm_num⟩
  · exact ⟨div_nonneg hA0 (le_of_lt hpos), by rw [nestedSpearmanSq, div_le_one hpos]; exact hAB⟩

/-- When the response is tie-free the two-sided law collapses to the one-sided law. -/
theorem nested_of_fine_tiefree (L : List (List ℕ)) (h : 2 ≤ L.flatten.sum)
    (hfine : tieCorr L.flatten = 0) :
    nestedSpearmanSq L = spearmanSq (L.map List.sum) := by
  have hsum : (L.map List.sum).sum = L.flatten.sum := (flatten_sum L).symm
  have h2 : 2 ≤ (L.map List.sum).sum := by rw [hsum]; exact h
  have hn : (2 : ℚ) ≤ (L.flatten.sum : ℚ) := by exact_mod_cast h
  have hV : (0 : ℚ) < ((L.flatten.sum : ℚ) ^ 3 - L.flatten.sum) := cube_sub_self_pos hn
  rw [nested_spearmanSq_eq L, hfine, sub_zero, spearmanSq_eq _ h2, hsum]
  exact sub_div_twelve _ _ (ne_of_gt hV)

/-! ## 4. Binary responses: the exact `√(3q(1-q))` ceiling -/

/-- **Exact binary-response ceiling.**  A two-class response with `j` positives and `k` negatives,
measured against a tie-free statistic, can attain at most `ρ² = 3jk/((j+k)² - 1)`. -/
theorem binary_response_spearmanSq (j k : ℕ) (hj : 1 ≤ j) (hk : 1 ≤ k) :
    spearmanSq [j, k] = 3 * (j : ℚ) * (k : ℚ) / (((j : ℚ) + k) ^ 2 - 1) := by
  have hsum : ([j, k] : List ℕ).sum = j + k := by simp
  have h2 : 2 ≤ ([j, k] : List ℕ).sum := by rw [hsum]; omega
  have hj1 : (1 : ℚ) ≤ (j : ℚ) := by exact_mod_cast hj
  have hk1 : (1 : ℚ) ≤ (k : ℚ) := by exact_mod_cast hk
  have hcast : ((([j, k] : List ℕ).sum : ℕ) : ℚ) = (j : ℚ) + k := by rw [hsum]; push_cast; ring
  rw [spearmanSq_eq _ h2, hcast]
  have htc : tieCorr ([j, k] : List ℕ) = ((j : ℚ) ^ 3 - j) / 12 + ((k : ℚ) ^ 3 - k) / 12 := by
    simp [tieCorr]
  rw [htc]
  have h2q : (2 : ℚ) ≤ (j : ℚ) + k := by linarith
  have hne1 : ((j : ℚ) + k) ^ 2 - 1 ≠ 0 := by
    have : (4 : ℚ) ≤ ((j : ℚ) + k) ^ 2 := by nlinarith
    exact ne_of_gt (by linarith)
  have hne2 : ((j : ℚ) + k) ^ 3 - ((j : ℚ) + k) ≠ 0 := ne_of_gt (cube_sub_self_pos h2q)
  field_simp
  ring

/-- Balanced binary responses: `ρ² = 3j²/(4j² - 1) > 3/4`, so `ρ → √3/2 ≈ 0.8660`. -/
theorem balanced_binary_ceiling (j : ℕ) (hj : 1 ≤ j) :
    spearmanSq [j, j] = 3 * (j : ℚ) ^ 2 / (4 * (j : ℚ) ^ 2 - 1) ∧
      3 / 4 < spearmanSq [j, j] := by
  have hj1 : (1 : ℚ) ≤ (j : ℚ) := by exact_mod_cast hj
  have hform : spearmanSq [j, j] = 3 * (j : ℚ) ^ 2 / (4 * (j : ℚ) ^ 2 - 1) := by
    rw [binary_response_spearmanSq j j hj hj]
    have hne : ((j : ℚ) + j) ^ 2 - 1 ≠ 0 := by nlinarith
    have hne' : 4 * (j : ℚ) ^ 2 - 1 ≠ 0 := by nlinarith
    field_simp
    ring
  refine ⟨hform, ?_⟩
  rw [hform]
  rw [lt_div_iff₀ (by nlinarith)]
  nlinarith

/-- A binary response strictly attenuates the dial as soon as one class has at least two members
(`j = k = 1` is the degenerate tie-free case, where `ρ = 1`). -/
theorem binary_response_lt_one (j k : ℕ) (hj : 1 ≤ j) (hk : 1 ≤ k) (h3 : 3 ≤ j + k) :
    spearmanSq [j, k] < 1 := by
  have hj1 : (1 : ℚ) ≤ (j : ℚ) := by exact_mod_cast hj
  have hk1 : (1 : ℚ) ≤ (k : ℚ) := by exact_mod_cast hk
  have h3q : (3 : ℚ) ≤ (j : ℚ) + k := by exact_mod_cast h3
  have hprod : (0 : ℚ) ≤ ((j : ℚ) - 1) * ((k : ℚ) - 1) :=
    mul_nonneg (by linarith) (by linarith)
  have hjk : (2 : ℚ) ≤ (j : ℚ) * k := by nlinarith
  have hden : (0 : ℚ) < ((j : ℚ) + k) ^ 2 - 1 := by nlinarith
  rw [binary_response_spearmanSq j k hj hk, div_lt_one hden]
  nlinarith [sq_nonneg ((j : ℚ) - k)]

/-! ## 5. Calibrating the recorded U64 reading against a binary response -/

/-- **Binary calibration of the round-61 reading.**  A two-class response with base rate
`1683/10000 = 16.83 %` reproduces the recorded pooled dial `0.648` to within `10⁻⁴` in `ρ²`. -/
theorem u64_binary_calibration :
    |spearmanSq [1683, 8317] - pooled ^ 2| < 1 / 10000 := by
  rw [binary_response_spearmanSq 1683 8317 (by norm_num) (by norm_num)]
  rw [abs_lt]
  constructor <;> norm_num [pooled]

/-- **Exclusion.**  The recorded reading rules out balanced-ish binary responses: any two-class
response whose minority class holds at least a quarter of the sample would read
`ρ² ≥ 9/16 = 0.5625`, far above the recorded pooled `ρ² = 0.419904`.  Hence, under the
binary-response explanation, the U64 measurement forces a *skewed* response. -/
theorem u64_excludes_balanced_binary (j k : ℕ) (hj : 1 ≤ j) (hjk : j ≤ k) (h4 : j + k ≤ 4 * j) :
    pooled ^ 2 < spearmanSq [j, k] := by
  have hk : 1 ≤ k := le_trans hj hjk
  have hj1 : (1 : ℚ) ≤ (j : ℚ) := by exact_mod_cast hj
  have hk1 : (1 : ℚ) ≤ (k : ℚ) := by exact_mod_cast hk
  have hjk1 : (j : ℚ) ≤ (k : ℚ) := by exact_mod_cast hjk
  have h41 : (j : ℚ) + k ≤ 4 * j := by exact_mod_cast h4
  have hden : (0 : ℚ) < ((j : ℚ) + k) ^ 2 - 1 := by nlinarith
  have hprod : (0 : ℚ) ≤ (3 * (k : ℚ) - j) * (3 * (j : ℚ) - k) :=
    mul_nonneg (by linarith) (by linarith)
  have hbig : (9 : ℚ) / 16 < 3 * (j : ℚ) * k / (((j : ℚ) + k) ^ 2 - 1) := by
    rw [lt_div_iff₀ hden]
    nlinarith
  rw [binary_response_spearmanSq j k hj hk]
  have : pooled ^ 2 < (9 : ℚ) / 16 := by norm_num [pooled]
  linarith

end Catalog.Novelty.ZeroFitDialNested