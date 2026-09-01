import Mathlib
import MachineLearning.ZeroFitDialRadixWeighting

/-!
# Sharpness of the `√7` cap at every finite bitlen

## Research context (FACT round-61 #2, exp 542, cycle 3)

Cycle 1 (`MachineLearning.ZeroFitDialWeighted56`) proved that the *asymptotic* ceiling of a
stratified weighting of the binary zero-fit dial is capped by `κ* = 1 - 1/(1+√7)²`, and
cycle 2 (`MachineLearning.ZeroFitDialRadixWeighting`) identified the radix law behind that
constant.  Both caps are statements about the bitlen limit, and a limit statement leaves an
obvious adversarial hole: *a finite-length ceiling is not the limit of the ceilings*.  Every
finite tie profile enjoys the discrete correction `-mⱼ` inside `Σⱼ(mⱼ³-mⱼ)`, which pushes the
finite value **above** the continuum one, so in principle some finite bitlen and some
weighting could break the cap.  This cycle closes that hole.

## Main results

* `sum_le_cubeSum`, `cubeSum_le_sum_cube` — the two elementary moment bounds
  `n ≤ Σⱼmⱼ³ ≤ n³`.
* `spearmanSq_continuum_lower`, `spearmanSq_continuum_upper`, `spearmanSq_continuum_sandwich`
  — the **continuum sandwich**: for every tie profile with `n ≥ 2` observations,
  `1 - Σⱼmⱼ³/n³ ≤ ρ² ≤ 1 - Σⱼmⱼ³/n³ + 1/n²`.
  The discrete tie-attenuation law and its continuum idealisation therefore never differ by
  more than `1/n²`, uniformly over all profiles.
* `wDyadic_finite_cap` — consequently, **at every finite bitlen** the stratified weighted
  binary dial obeys `ρ² ≤ stratCeiling p q + 1/(4·4^b)`, hence
  `ρ² ≤ κ* + 4^{-(b+1)}`: the `√7` cap of cycle 1 is not a limiting artefact.
* `u56_weighted_cap` — instantiated at the recorded cell: at bitlen 56 no stratified
  weighting whatsoever reaches `κ* + 10⁻³³`.

## The scientific payload

Taken together with cycle 1, this settles the status of the *weighted* edge for the
bitlen-56 record.  The dial's reweighting budget is real (`weighted_beats_unweighted`),
bounded (`stratCeiling_le_sqrt_seven`), and now bounded **at the actual bitlen of the
experiment**, not merely asymptotically: a weighted binary trailing-zero dial can never read
above `ρ = 0.96165` at bitlen 56, to within `10⁻³³`.  The recorded pooled reading is `0.669`.
The H2 failure at `+0.045` is therefore a fact about the *response*, with `0.29` of unused
correlation headroom under even the optimal weighting — a factor of nearly sixty more than
the `0.005` shortfall.
-/

open Finset

open Catalog.Novelty.ZeroFitDialU64
open Catalog.MachineLearning.ZeroFitDialWeighted56

namespace Catalog.MachineLearning.ZeroFitDialWeightedSharpness

/-! ## 1. Moment bounds -/

/-- The mass never exceeds the cubic moment. -/
lemma sum_le_cubeSum (L : List ℕ) : (L.sum : ℚ) ≤ cubeSum L := by
  induction L with
  | nil => simp [cubeSum]
  | cons m L ih =>
      rw [List.sum_cons, cubeSum_cons, Nat.cast_add]
      have hm : (0 : ℚ) ≤ (m : ℚ) := Nat.cast_nonneg m
      have h : (m : ℚ) ≤ (m : ℚ) ^ 3 := by
        rcases Nat.eq_zero_or_pos m with rfl | hpos
        · simp
        · have h1 : (1 : ℚ) ≤ (m : ℚ) := by exact_mod_cast hpos
          have h2 : (1 : ℚ) ≤ (m : ℚ) ^ 2 := by nlinarith
          nlinarith
      linarith

/-- The cubic moment never exceeds the cube of the mass. -/
lemma cubeSum_le_sum_cube (L : List ℕ) : cubeSum L ≤ (L.sum : ℚ) ^ 3 := by
  induction L with
  | nil => simp [cubeSum]
  | cons m L ih =>
      rw [List.sum_cons, cubeSum_cons, Nat.cast_add]
      have hm : (0 : ℚ) ≤ (m : ℚ) := Nat.cast_nonneg m
      have hs : (0 : ℚ) ≤ (L.sum : ℚ) := Nat.cast_nonneg _
      nlinarith [mul_nonneg (mul_nonneg hm hs) (add_nonneg hm hs)]

/-! ## 2. The continuum sandwich -/

/-- Lower half of the sandwich: the discrete ceiling is at least the continuum one. -/
theorem spearmanSq_continuum_lower (L : List ℕ) (h : 2 ≤ L.sum) :
    1 - cubeSum L / (L.sum : ℚ) ^ 3 ≤ spearmanSq L := by
  have hn : (2 : ℚ) ≤ (L.sum : ℚ) := by exact_mod_cast h
  have hden : (0 : ℚ) < (L.sum : ℚ) ^ 3 - (L.sum : ℚ) := cube_sub_self_pos hn
  have hn3 : (0 : ℚ) < (L.sum : ℚ) ^ 3 := by nlinarith
  have hC := cubeSum_le_sum_cube L
  rw [spearmanSq_of_cubeSum L h]
  have hkey : (cubeSum L - (L.sum : ℚ)) / ((L.sum : ℚ) ^ 3 - (L.sum : ℚ))
      ≤ cubeSum L / (L.sum : ℚ) ^ 3 := by
    rw [div_le_div_iff₀ hden hn3]
    nlinarith
  linarith

/-- Upper half of the sandwich: the discrete ceiling exceeds the continuum one by at most
`1/n²`. -/
theorem spearmanSq_continuum_upper (L : List ℕ) (h : 2 ≤ L.sum) :
    spearmanSq L ≤ 1 - cubeSum L / (L.sum : ℚ) ^ 3 + 1 / (L.sum : ℚ) ^ 2 := by
  have hn : (2 : ℚ) ≤ (L.sum : ℚ) := by exact_mod_cast h
  have hden : (0 : ℚ) < (L.sum : ℚ) ^ 3 - (L.sum : ℚ) := cube_sub_self_pos hn
  have hn3 : (0 : ℚ) < (L.sum : ℚ) ^ 3 := by nlinarith
  have hn2 : (0 : ℚ) < (L.sum : ℚ) ^ 2 := by nlinarith
  have hCn := sum_le_cubeSum L
  rw [spearmanSq_of_cubeSum L h]
  have hkey : cubeSum L / (L.sum : ℚ) ^ 3 - 1 / (L.sum : ℚ) ^ 2
      ≤ (cubeSum L - (L.sum : ℚ)) / ((L.sum : ℚ) ^ 3 - (L.sum : ℚ)) := by
    have hsplit : cubeSum L / (L.sum : ℚ) ^ 3 - 1 / (L.sum : ℚ) ^ 2
        = (cubeSum L - (L.sum : ℚ)) / (L.sum : ℚ) ^ 3 := by
      field_simp
    rw [hsplit]
    apply div_le_div_of_nonneg_left (by linarith) hden
    nlinarith
  linarith

/-- **Continuum sandwich.**  The exact tie-attenuation ceiling and its continuum
idealisation `1 - Σⱼmⱼ³/n³` differ by at most `1/n²`, for every tie profile. -/
theorem spearmanSq_continuum_sandwich (L : List ℕ) (h : 2 ≤ L.sum) :
    1 - cubeSum L / (L.sum : ℚ) ^ 3 ≤ spearmanSq L ∧
      spearmanSq L ≤ 1 - cubeSum L / (L.sum : ℚ) ^ 3 + 1 / (L.sum : ℚ) ^ 2 :=
  ⟨spearmanSq_continuum_lower L h, spearmanSq_continuum_upper L h⟩

/-! ## 3. The cap holds at every finite bitlen -/

/-- **Finite-bitlen cap.**  For every bitlen and every stratified weighting, the exact
ceiling exceeds its asymptotic value by at most `1/(4·4^b)`; combined with
`stratCeiling_le_sqrt_seven` this caps the finite-bitlen ceiling by `κ* + 4^{-(b+1)}`. -/
theorem wDyadic_finite_cap (b p q : ℕ) (hp : 1 ≤ p) (hq : 1 ≤ q) :
    ((spearmanSq (wDyadic b p q) : ℚ) : ℝ) ≤ stratOptimum + (1 / 4 : ℝ) ^ (b + 1) := by
  have h2 := wDyadic_two_le_sum b p q hp hq
  have hp1 : (1 : ℚ) ≤ (p : ℚ) := by exact_mod_cast hp
  have hq1 : (1 : ℚ) ≤ (q : ℚ) := by exact_mod_cast hq
  have hcast : (((wDyadic b p q).sum : ℕ) : ℚ) = ((p : ℚ) + q) * 2 ^ b := by
    rw [wDyadic_sum]; push_cast; ring
  have hx : (1 : ℚ) ≤ (2 : ℚ) ^ b := one_le_pow₀ (by norm_num)
  have hSpos : (0 : ℚ) < (p : ℚ) + q := by linarith
  have hn3 : (0 : ℚ) < (((p : ℚ) + q) * 2 ^ b) ^ 3 := by positivity
  -- the continuum term, computed
  have hC : cubeSum (wDyadic b p q) = (p : ℚ) ^ 3 * 8 ^ b + (q : ℚ) ^ 3 * ((8 ^ b + 6) / 7) :=
    wDyadic_cubeSum b p q
  have hcube : ((2 : ℚ) ^ b) ^ 3 = 8 ^ b := pow_two_cube b
  have hQ : (0 : ℚ) ≤ (q : ℚ) ^ 3 := by positivity
  have h8 : (0 : ℚ) < (8 : ℚ) ^ b := by positivity
  -- continuum term is at least the asymptotic attenuation
  have hkey : ((p : ℚ) ^ 3 + (q : ℚ) ^ 3 / 7) / ((p : ℚ) + q) ^ 3
      ≤ cubeSum (wDyadic b p q) / (((p : ℚ) + q) * 2 ^ b) ^ 3 := by
    rw [hC]
    have hrw : (((p : ℚ) + q) * 2 ^ b) ^ 3 = ((p : ℚ) + q) ^ 3 * 8 ^ b := by
      rw [mul_pow, hcube]
    rw [hrw, div_le_div_iff₀ (by positivity) (by positivity)]
    nlinarith [mul_pos (pow_pos hSpos 3) h8]
  -- the discrete correction
  have hupper := spearmanSq_continuum_upper (wDyadic b p q) h2
  rw [hcast] at hupper
  have hbound : spearmanSq (wDyadic b p q)
      ≤ 1 - ((p : ℚ) ^ 3 + (q : ℚ) ^ 3 / 7) / ((p : ℚ) + q) ^ 3
        + 1 / (((p : ℚ) + q) * 2 ^ b) ^ 2 := by
    linarith
  -- the error term is at most 1/(4·4^b)
  have herr : 1 / (((p : ℚ) + q) * 2 ^ b) ^ 2 ≤ (1 / 4 : ℚ) ^ (b + 1) := by
    have hS2 : (2 : ℚ) ≤ (p : ℚ) + q := by linarith
    have hpow : (4 : ℚ) * 4 ^ b ≤ (((p : ℚ) + q) * 2 ^ b) ^ 2 := by
      have h4 : ((2 : ℚ) ^ b) ^ 2 = 4 ^ b := by
        rw [← pow_mul, mul_comm, pow_mul]; norm_num
      have hx0 : (0 : ℚ) < (2 : ℚ) ^ b := by positivity
      have hsq : (4 : ℚ) ≤ ((p : ℚ) + q) ^ 2 := by nlinarith
      calc (4 : ℚ) * 4 ^ b = 4 * ((2 : ℚ) ^ b) ^ 2 := by rw [h4]
        _ ≤ ((p : ℚ) + q) ^ 2 * ((2 : ℚ) ^ b) ^ 2 :=
            mul_le_mul_of_nonneg_right hsq (le_of_lt (pow_pos hx0 2))
        _ = (((p : ℚ) + q) * 2 ^ b) ^ 2 := by ring
    have hpos : (0 : ℚ) < (4 : ℚ) * 4 ^ b := by positivity
    have := one_div_le_one_div_of_le hpos hpow
    calc 1 / (((p : ℚ) + q) * 2 ^ b) ^ 2 ≤ 1 / (4 * 4 ^ b) := this
      _ = (1 / 4 : ℚ) ^ (b + 1) := by
          rw [div_pow, one_pow, pow_succ]
          ring_nf
  -- transport to ℝ and apply the asymptotic cap
  have hreal : ((spearmanSq (wDyadic b p q) : ℚ) : ℝ)
      ≤ 1 - (((p : ℚ) ^ 3 + (q : ℚ) ^ 3 / 7) / ((p : ℚ) + q) ^ 3 : ℚ)
        + ((1 / 4 : ℚ) ^ (b + 1) : ℚ) := by
    have : spearmanSq (wDyadic b p q)
        ≤ 1 - ((p : ℚ) ^ 3 + (q : ℚ) ^ 3 / 7) / ((p : ℚ) + q) ^ 3 + (1 / 4 : ℚ) ^ (b + 1) := by
      linarith
    exact_mod_cast (Rat.cast_le (K := ℝ)).2 this
  have hcapR : (1 : ℝ) - (((p : ℚ) ^ 3 + (q : ℚ) ^ 3 / 7) / ((p : ℚ) + q) ^ 3 : ℚ)
      ≤ stratOptimum := by
    have hpR : (0 : ℝ) < (p : ℝ) := by
      have : (1 : ℝ) ≤ (p : ℝ) := by exact_mod_cast hp
      linarith
    have hqR : (0 : ℝ) ≤ (q : ℝ) := Nat.cast_nonneg q
    have := stratCeiling_le_sqrt_seven (p : ℝ) (q : ℝ) hpR hqR
    unfold stratCeiling at this
    unfold stratOptimum
    push_cast
    linarith
  have hpow : (((1 / 4 : ℚ) ^ (b + 1) : ℚ) : ℝ) = (1 / 4 : ℝ) ^ (b + 1) := by push_cast; ring
  rw [hpow] at hreal
  linarith

/-- At the recorded bitlen 56, no stratified weighting of the dial reaches `κ* + 10⁻³³`. -/
theorem u56_weighted_cap (p q : ℕ) (hp : 1 ≤ p) (hq : 1 ≤ q) :
    ((spearmanSq (wDyadic 55 p q) : ℚ) : ℝ) ≤ stratOptimum + 1 / 10 ^ 33 := by
  have h := wDyadic_finite_cap 55 p q hp hq
  have hsmall : (1 / 4 : ℝ) ^ (55 + 1) ≤ 1 / 10 ^ 33 := by
    rw [div_pow, one_pow]
    rw [div_le_div_iff₀ (by positivity) (by positivity)]
    norm_num
  linarith

/-- The same cap on the `ρ`-scale: at bitlen 56 no stratified weighting of the dial can
read above `ρ = 0.9616467`. -/
theorem u56_weighted_rho_cap (p q : ℕ) (hp : 1 ≤ p) (hq : 1 ≤ q) :
    Real.sqrt ((spearmanSq (wDyadic 55 p q) : ℚ) : ℝ) ≤ 0.9616467 := by
  have h := u56_weighted_cap p q hp hq
  have hb := stratOptimum_bounds.2
  have h33 : (1 : ℝ) / 10 ^ 33 ≤ 0.0000001 := by norm_num
  have hlt : ((spearmanSq (wDyadic 55 p q) : ℚ) : ℝ) ≤ (0.9616467 : ℝ) ^ 2 := by
    nlinarith
  calc Real.sqrt ((spearmanSq (wDyadic 55 p q) : ℚ) : ℝ)
      ≤ Real.sqrt ((0.9616467 : ℝ) ^ 2) := Real.sqrt_le_sqrt hlt
    _ = 0.9616467 := Real.sqrt_sq (by norm_num)

/-- **The weighted edge, bounded at the recorded bitlen.**  Whatever stratified weighting the
dial had used at bitlen 56, its correlation could not have exceeded the recorded pooled
reading `0.669` by more than `0.2927`.  The reweighting budget is finite and explicitly
quantified at the length of the actual experiment, not only in the limit. -/
theorem u56_weighting_budget (p q : ℕ) (hp : 1 ≤ p) (hq : 1 ≤ q) :
    Real.sqrt ((spearmanSq (wDyadic 55 p q) : ℚ) : ℝ) - ((pooled56 : ℚ) : ℝ) < 0.2927 := by
  have h := u56_weighted_rho_cap p q hp hq
  have hp56 : ((pooled56 : ℚ) : ℝ) = 0.669 := by norm_num [pooled56]
  rw [hp56]
  linarith

end Catalog.MachineLearning.ZeroFitDialWeightedSharpness