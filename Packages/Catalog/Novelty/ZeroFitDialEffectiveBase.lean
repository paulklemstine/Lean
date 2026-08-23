import Mathlib
import Novelty.ZeroFitDialU64
import Novelty.ZeroFitDialNested
import Novelty.ZeroFitDialU76

/-!
# The effective base of the zero-fit dial, and the exclusion of response granularity

Cycle 3 of the round-65 (bitlen-76) investigation.

`Novelty.ZeroFitDialU76` proved the `p`-adic ceiling law
`ρ²(p,b) = (3p/(p²+p+1))·(1+1/(p^b(p^b+1)))` and showed that the *unique* base whose
asymptotic ceiling sits inside the observed seed window at bitlen 76 is `p = 7`.
Two questions remain open after that cycle:

1. *Could response-side granularity (a coarse `rate`) explain the observed
   attenuation instead?*  Answer: **no** — `nested_ge_one_sided` shows that in the
   nested model of `Novelty.ZeroFitDialNested` a coarser *response* can only push the
   ceiling **up**, never down.  Combined with `Novelty.ZeroFitDialTruncation`
   (truncation keeps `ρ² ≥ 3/4`) and `tie_mechanism_excluded_64_76`, every purely
   *tie-theoretic* explanation of the dial is now closed off.
2. *Is `7` an artefact of the discrete search, or is the continuous inverse of the
   ceiling law genuinely near `7`?*  Answer: the continuous inverse
   `effBase r = ((3-r) + √(3(1-r)(3+r)))/(2r)` satisfies `3·effBase r/(effBase r²+effBase r+1) = r`
   exactly (`effBase_spec`), takes the value `7` exactly at `r = 7/19`
   (`effBase_seven`), and at the recorded pooled dial `r = 0.608²` lies in
   `(6.9, 7.05)` (`effBase_pooled_bracket`).

## Main results

* `nested_ge_one_sided` — response granularity raises, never lowers, the ceiling.
* `u76_not_explained_by_response_ties` — hence no nested profile over the dyadic
  bitlen-76 coarse profile can reach the recorded dial.
* `effBase_spec`, `effBase_gt_one`, `effBase_seven`, `effBase_pooled_bracket` — the
  continuous effective base.
-/

open Finset

namespace Catalog.Novelty.ZeroFitDialEffectiveBase

open Catalog.Novelty.ZeroFitDialU64 Catalog.Novelty.ZeroFitDialNested
open Catalog.Novelty.ZeroFitDialU76

/-! ## 1. Response granularity can only raise the ceiling -/

/-- **Response-granularity monotonicity.**  In the nested (two-sided) model, coarsening
the response strictly *raises* the attainable coefficient: the nested ceiling always
dominates the one-sided ceiling of the coarse profile. -/
theorem nested_ge_one_sided (L : List (List ℕ)) (h : 2 ≤ L.flatten.sum) :
    spearmanSq (L.map List.sum) ≤ nestedSpearmanSq L := by
  have hn : (2 : ℚ) ≤ (L.flatten.sum : ℚ) := by exact_mod_cast h
  have hsum : (L.map List.sum).sum = L.flatten.sum := (flatten_sum L).symm
  have h2 : 2 ≤ (L.map List.sum).sum := by rw [hsum]; exact h
  have hV : (0 : ℚ) < ((L.flatten.sum : ℚ) ^ 3 - L.flatten.sum) := cube_sub_self_pos hn
  set V : ℚ := ((L.flatten.sum : ℚ) ^ 3 - L.flatten.sum) / 12 with hVdef
  have hVpos : 0 < V := by rw [hVdef]; linarith
  -- the one-sided coefficient of the coarse profile is `(V - T_coarse)/V`
  have hone : spearmanSq (L.map List.sum) = (V - tieCorr (L.map List.sum)) / V := by
    rw [spearmanSq_eq _ h2, hsum, hVdef]
    rw [sub_div_twelve _ _ (ne_of_gt hV)]
  have hnest : nestedSpearmanSq L = (V - tieCorr (L.map List.sum)) / (V - tieCorr L.flatten) := by
    rw [nested_spearmanSq_eq L, hVdef]
  -- numerator is nonnegative, and the nested denominator is at most `V`
  have hA0 : 0 ≤ V - tieCorr (L.map List.sum) := by
    have hR : ssR (gmean L.flatten) (L.map List.sum) 0 = V - tieCorr (L.map List.sum) := by
      have hg : gmean (L.map List.sum) = gmean L.flatten := by rw [gmean, gmean, hsum]
      have hS : ssS (gmean L.flatten) (L.map List.sum) 0 = V := by
        rw [← hg, ssS_total, hsum, hVdef]
      have := ssS_eq_ssR_add (gmean L.flatten) (L.map List.sum) 0
      rw [hS] at this; linarith
    rw [← hR]; exact ssR_nonneg _ _ _
  have hfine : tieCorr L.flatten ≤ tieCorr (L.map List.sum) := tieCorr_flatten_le L
  have hfine0 : 0 ≤ tieCorr L.flatten := tieCorr_nonneg _
  rw [hone, hnest]
  rcases eq_or_lt_of_le (by linarith : (0 : ℚ) ≤ V - tieCorr L.flatten) with hB | hB
  · -- degenerate case: both coefficients vanish
    have hAzero : V - tieCorr (L.map List.sum) = 0 := by linarith
    rw [hAzero, ← hB]
    simp
  · exact div_le_div_of_nonneg_left hA0 hB (by linarith)

/-- **Response ties are excluded.**  Whatever the granularity of the `rate` response,
if the zero-count statistic has the dyadic bitlen-76 tie profile then the attainable
coefficient stays above `6/7` in `ρ²` — more than twice the recorded pooled value. -/
theorem u76_not_explained_by_response_ties (L : List (List ℕ)) (h : 2 ≤ L.flatten.sum)
    (hcoarse : L.map List.sum = dyadicBlocks 76) :
    pooled76 ^ 2 < nestedSpearmanSq L := by
  have hmono := nested_ge_one_sided L h
  rw [hcoarse] at hmono
  have hceil := dyadic_ceiling_gt 76 (by norm_num)
  have : pooled76 ^ 2 < 6 / 7 := by norm_num [pooled76]
  linarith

/-! ## 2. The continuous effective base -/

/-- The continuous inverse of the asymptotic ceiling law: the unique `p ≥ 1` with
`3p/(p²+p+1) = r`. -/
noncomputable def effBase (r : ℝ) : ℝ := ((3 - r) + Real.sqrt (3 * (1 - r) * (3 + r))) / (2 * r)

lemma disc_nonneg {r : ℝ} (h0 : 0 < r) (h1 : r ≤ 1) : 0 ≤ 3 * (1 - r) * (3 + r) := by
  have : 0 ≤ 1 - r := by linarith
  nlinarith

lemma disc_sq {r : ℝ} (h0 : 0 < r) (h1 : r ≤ 1) :
    Real.sqrt (3 * (1 - r) * (3 + r)) ^ 2 = 9 - 6 * r - 3 * r ^ 2 := by
  rw [Real.sq_sqrt (disc_nonneg h0 h1)]
  ring

/-- The effective base is at least one (and exceeds one strictly below `r = 1`). -/
theorem effBase_gt_one {r : ℝ} (h0 : 0 < r) (h1 : r < 1) : 1 < effBase r := by
  have hs : 0 ≤ Real.sqrt (3 * (1 - r) * (3 + r)) := Real.sqrt_nonneg _
  have hspos : 0 < Real.sqrt (3 * (1 - r) * (3 + r)) := by
    rw [Real.lt_sqrt (by norm_num)]
    nlinarith
  rw [effBase, lt_div_iff₀ (by linarith)]
  linarith

/-- **The effective base inverts the ceiling law exactly.** -/
theorem effBase_spec {r : ℝ} (h0 : 0 < r) (h1 : r < 1) :
    3 * effBase r / ((effBase r) ^ 2 + effBase r + 1) = r := by
  have hp1 : 1 < effBase r := effBase_gt_one h0 h1
  have hden : (0 : ℝ) < (effBase r) ^ 2 + effBase r + 1 := by nlinarith
  have hsq := disc_sq h0 (le_of_lt h1)
  set s : ℝ := Real.sqrt (3 * (1 - r) * (3 + r)) with hsdef
  have hp : effBase r = ((3 - r) + s) / (2 * r) := rfl
  have hquad : r * (effBase r) ^ 2 - (3 - r) * effBase r + r = 0 := by
    rw [hp]
    field_simp
    nlinarith [hsq]
  rw [eq_comm, eq_div_iff (ne_of_gt hden)]
  nlinarith [hquad]

/-- At `r = 7/19` — the asymptotic 7-adic ceiling — the effective base is exactly `7`. -/
theorem effBase_seven : effBase (7 / 19) = 7 := by
  have hd : 3 * (1 - (7 : ℝ) / 19) * (3 + 7 / 19) = (48 / 19) ^ 2 := by norm_num
  rw [effBase, hd, Real.sqrt_sq (by norm_num)]
  norm_num

/-- **The recorded pooled dial pins the effective base at `≈ 6.97`.**  With
`r = 0.608²` the continuous inverse of the ceiling law lies strictly between
`6.9` and `7.05`, so the discrete answer `p = 7` of `effective_base_seven` is not an
artefact of restricting to integer bases. -/
theorem effBase_pooled_bracket :
    6.9 < effBase ((0.608 : ℝ) ^ 2) ∧ effBase ((0.608 : ℝ) ^ 2) < 7.05 := by
  set r : ℝ := (0.608 : ℝ) ^ 2 with hrdef
  have hr0 : 0 < r := by rw [hrdef]; norm_num
  have hr1 : r < 1 := by rw [hrdef]; norm_num
  set s : ℝ := Real.sqrt (3 * (1 - r) * (3 + r)) with hsdef
  have hlow : 2.52 < s := by
    rw [hsdef, Real.lt_sqrt (by norm_num)]
    rw [hrdef]; norm_num
  have hhigh : s < 2.53 := by
    rw [hsdef, Real.sqrt_lt' (by norm_num)]
    rw [hrdef]; norm_num
  have hpos : (0 : ℝ) < 2 * r := by linarith
  constructor
  · rw [effBase, ← hsdef, lt_div_iff₀ hpos, hrdef]
    nlinarith [hlow]
  · rw [effBase, ← hsdef, div_lt_iff₀ hpos, hrdef]
    nlinarith [hhigh]

/-! ## 3. Self-duality of the ceiling law -/

/-- **Reciprocal invariance.**  The ceiling function `x ↦ 3x/(x²+x+1)` is invariant under
`x ↦ 1/x`: a base `p` and a block-ratio `1/p` give the same asymptotic ceiling.  This is
the structural reason the inversion `effBase` is a quadratic with two roots. -/
theorem ceiling_reciprocal_invariance {x : ℝ} (hx : 0 < x) :
    3 * x / (x ^ 2 + x + 1) = 3 * (1 / x) / ((1 / x) ^ 2 + 1 / x + 1) := by
  have hx0 : x ≠ 0 := ne_of_gt hx
  have hd : x ^ 2 + x + 1 ≠ 0 := by positivity
  field_simp
  ring

/-- The conjugate root of the ceiling equation is the reciprocal of the effective base:
the two solutions of `3p/(p²+p+1) = r` multiply to `1`. -/
theorem effBase_conjugate {r : ℝ} (h0 : 0 < r) (h1 : r < 1) :
    effBase r * (((3 - r) - Real.sqrt (3 * (1 - r) * (3 + r))) / (2 * r)) = 1 := by
  have hsq := disc_sq h0 (le_of_lt h1)
  have hr0 : r ≠ 0 := ne_of_gt h0
  rw [effBase, div_mul_div_comm]
  rw [div_eq_one_iff_eq (by positivity)]
  nlinarith [hsq]

/-- The two extreme recorded seeds put the effective base inside `(6.6, 7.4)`: the
measurement pins the base to within roughly `±0.4` of `7`. -/
theorem effBase_seed_bracket :
    (6.6 < effBase ((0.593 : ℝ) ^ 2) ∧ effBase ((0.593 : ℝ) ^ 2) < 7.4) ∧
    (6.6 < effBase ((0.618 : ℝ) ^ 2) ∧ effBase ((0.618 : ℝ) ^ 2) < 7.4) := by
  constructor
  · set r : ℝ := (0.593 : ℝ) ^ 2 with hrdef
    have hpos : (0 : ℝ) < 2 * r := by rw [hrdef]; norm_num
    have hlow : 2.553 < Real.sqrt (3 * (1 - r) * (3 + r)) := by
      rw [Real.lt_sqrt (by norm_num), hrdef]; norm_num
    have hhigh : Real.sqrt (3 * (1 - r) * (3 + r)) < 2.554 := by
      rw [Real.sqrt_lt' (by norm_num), hrdef]; norm_num
    constructor
    · rw [effBase, lt_div_iff₀ hpos, hrdef]; nlinarith [hlow]
    · rw [effBase, div_lt_iff₀ hpos, hrdef]; nlinarith [hhigh]
  · set r : ℝ := (0.618 : ℝ) ^ 2 with hrdef
    have hpos : (0 : ℝ) < 2 * r := by rw [hrdef]; norm_num
    have hlow : 2.504 < Real.sqrt (3 * (1 - r) * (3 + r)) := by
      rw [Real.lt_sqrt (by norm_num), hrdef]; norm_num
    have hhigh : Real.sqrt (3 * (1 - r) * (3 + r)) < 2.505 := by
      rw [Real.sqrt_lt' (by norm_num), hrdef]; norm_num
    constructor
    · rw [effBase, lt_div_iff₀ hpos, hrdef]; nlinarith [hlow]
    · rw [effBase, div_lt_iff₀ hpos, hrdef]; nlinarith [hhigh]

end Catalog.Novelty.ZeroFitDialEffectiveBase