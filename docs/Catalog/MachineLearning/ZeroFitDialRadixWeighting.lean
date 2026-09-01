import Mathlib
import MachineLearning.ZeroFitDialWeighted56

/-!
# The radix law of the weighted zero-fit dial

## Research context (FACT round-61 #2, exp 542, cycle 2)

Cycle 1 (`MachineLearning.ZeroFitDialWeighted56`) established, for the *binary* zero-fit
dial behind the bitlen-56 measurement `U56B-DIAL-HOLDS-COUNT-PARITY`:

* the exact ceiling law of a stratified weighting `(p,q)` of the 2-adic tie profile;
* the asymptotic ceiling `1 - (p³ + q³/7)/(p+q)³`;
* the **`√7` cap** `1 - 1/(1+√7)² ≈ 0.9247640`, attained exactly at `q = √7·p`, giving a
  hard `+0.0359` budget on what any reweighting of the dial can buy.

The `7` in that cap is not universal: it is `(2³-1)/(2-1)³`, an artefact of the radix.  This
cycle asks what the cap becomes for the base-`g` trailing-zero statistic (the `g`-adic
valuation of a uniform draw below `g^b`), and finds a clean radix law.

## Main results

* `gBlocks`, `gBlocks_sum`, `gBlocks_cubeSum` — the base-`g` trailing-zero tie profile
  `((g-1)g^{b-1}, …, (g-1), 1)` and its cubic moment
  `1 + (g-1)³(g^{3b}-1)/(g³-1)`; `gBlocks_two` identifies `g = 2` with the dyadic profile.
* `wGBlocks`, `wGBlocks_sum`, `wGBlocks_cubeSum`, `wGBlocks_spearmanSq` — the stratified
  weighting in base `g` and its **exact** finite-`b` Spearman ceiling.
* `wGBlocks_ceiling_tendsto` — the bitlen limit is `radixCeiling g p q`, which is exactly the
  two-block cubic ratio of cycle 1 with `u = p(g-1)`, `v = q` and modulus
  `kappaRadix g = (g³-1)/(g-1)³ = (g²+g+1)/(g-1)²`.
* `radixCeiling_le_cap` — **the radix cap**: no stratified weighting in base `g` beats
  `1 - 1/(1 + √(kappaRadix g))²`; `radixCeiling_eq_cap` shows it is attained, at the
  quadratic-irrational ratio `q/p = (g-1)√(kappaRadix g)`.
* `weighted_cubic_cap_strict`, `rational_weighting_strictly_suboptimal` — an arithmetic
  obstruction: since `√7` is irrational (`Nat.Prime.irrational_sqrt`), **every** rational
  weighting of the binary dial is strictly below the cap.  The optimum of a rank-statistics
  design problem is here a quadratic irrational that no experimental protocol with rational
  multiplicities can realise.
* `weightGain`, `weightGain_pos`, `weightGain_strictAnti` — the reweighting budget
  `1/K - 1/(1+√K)²` is positive and strictly decreasing in the modulus `K`.
* `kappaRadix_two`, `kappaRadix_ten`, `binary_gain_lt`, `decimal_gain_gt`,
  `decimal_gain_exceeds_binary` — since `kappaRadix` falls from `7` (binary) to `111/81`
  (decimal), the budget rises from `< 0.068` to `> 0.5`: **the higher the radix, the more a
  weighted dial can buy.**

## The scientific payload

The bitlen-56 H2 verdict turned on a `0.005` shortfall in a *weighted* advantage.  Cycle 1
showed the binary dial has a `0.0359` reweighting budget in `ρ`, seven times the shortfall.
This cycle shows *where that budget comes from*: it is governed by the single number
`kappaRadix g`, the ratio of the cubic to the linear mass of one radix step.  The binary
dial sits at the **worst** value of that parameter among all radices — `kappaRadix` is
strictly decreasing in `g` and the budget strictly decreasing in `kappaRadix`.  A falsifiable
prediction follows: the same experiment run on a base-10 trailing-zero statistic should show
a weighted edge roughly an order of magnitude larger than the binary one, and its H2 bar
should be cleared comfortably.  Conversely, the fact that the binary dial has the smallest
possible weighting budget explains why count parity is reached at binary bitlen 56 rather
than being postponed.
-/

open Finset

open Catalog.Novelty.ZeroFitDialU64
open Catalog.MachineLearning.ZeroFitDialWeighted56

namespace Catalog.MachineLearning.ZeroFitDialRadixWeighting

/-! ## 0. Two elementary cube bounds -/

/-- `x ≥ 2 ⇒ x³ ≥ 8`, over `ℚ`. -/
lemma rat_cube_ge {x : ℚ} (h : 2 ≤ x) : 8 ≤ x ^ 3 := by
  nlinarith [mul_nonneg (by linarith : (0 : ℚ) ≤ x - 2)
    (by nlinarith : (0 : ℚ) ≤ x ^ 2 + 2 * x + 4)]

/-- `x ≥ 2 ⇒ x³ ≥ 8`, over `ℝ`. -/
lemma real_cube_ge {x : ℝ} (h : 2 ≤ x) : 8 ≤ x ^ 3 := by
  nlinarith [mul_nonneg (by linarith : (0 : ℝ) ≤ x - 2)
    (by nlinarith : (0 : ℝ) ≤ x ^ 2 + 2 * x + 4)]

/-! ## 1. The base-`g` trailing-zero tie profile -/

/-- Tie profile of the base-`g` trailing-zero statistic on `{0, …, g^b - 1}`:
blocks of sizes `(g-1)g^{b-1}, …, (g-1)g, (g-1)`, followed by the singleton `{0}`. -/
def gBlocks (g : ℕ) : ℕ → List ℕ
  | 0 => [1]
  | b + 1 => (g - 1) * g ^ b :: gBlocks g b

/-- In base two the profile is the dyadic one. -/
theorem gBlocks_two (b : ℕ) : gBlocks 2 b = dyadicBlocks b := by
  induction b with
  | zero => rfl
  | succ k ih => rw [gBlocks, dyadicBlocks, ih]; norm_num

lemma gBlocks_sum (g : ℕ) (hg : 1 ≤ g) (b : ℕ) : (gBlocks g b).sum = g ^ b := by
  induction b with
  | zero => simp [gBlocks]
  | succ k ih =>
      rw [gBlocks, List.sum_cons, ih]
      have h : (g - 1) * g ^ k + g ^ k = ((g - 1) + 1) * g ^ k := by ring
      rw [h, Nat.sub_add_cancel hg, pow_succ]
      ring

/-- The cubic moment of the base-`g` trailing-zero profile. -/
theorem gBlocks_cubeSum (g : ℕ) (hg : 2 ≤ g) (b : ℕ) :
    cubeSum (gBlocks g b)
      = 1 + ((g : ℚ) - 1) ^ 3 * ((((g : ℚ) ^ b) ^ 3 - 1) / ((g : ℚ) ^ 3 - 1)) := by
  have hg1 : (2 : ℚ) ≤ (g : ℚ) := by exact_mod_cast hg
  have hg3 : (8 : ℚ) ≤ (g : ℚ) ^ 3 := rat_cube_ge hg1
  have hne : ((g : ℚ) ^ 3 - 1) ≠ 0 := by intro hc; linarith
  have hcast : (((g - 1 : ℕ)) : ℚ) = (g : ℚ) - 1 := by
    rw [Nat.cast_sub (by omega : 1 ≤ g), Nat.cast_one]
  induction b with
  | zero => norm_num [gBlocks, cubeSum]
  | succ k ih =>
      rw [gBlocks, cubeSum_cons, ih]
      have h : (((g - 1) * g ^ k : ℕ) : ℚ) ^ 3 = ((g : ℚ) - 1) ^ 3 * ((g : ℚ) ^ k) ^ 3 := by
        push_cast [hcast]
        ring
      rw [h]
      field_simp
      ring

/-! ## 2. Stratified weighting in base `g` -/

/-- Weight the dominant base-`g` block (mass `(g-1)g^b`) by `p` and every deeper block
by `q`. -/
def wGBlocks (g b p q : ℕ) : List ℕ :=
  p * ((g - 1) * g ^ b) :: (gBlocks g b).map (fun m => q * m)

/-- In base two this is the stratified dyadic weighting of cycle 1. -/
theorem wGBlocks_two (b p q : ℕ) : wGBlocks 2 b p q = wDyadic b p q := by
  rw [wGBlocks, wDyadic, gBlocks_two]
  norm_num

lemma wGBlocks_sum (g : ℕ) (hg : 1 ≤ g) (b p q : ℕ) :
    (wGBlocks g b p q).sum = (p * (g - 1) + q) * g ^ b := by
  rw [wGBlocks, List.sum_cons, sum_map_mul, gBlocks_sum g hg]
  ring

lemma wGBlocks_cubeSum (g : ℕ) (hg : 2 ≤ g) (b p q : ℕ) :
    cubeSum (wGBlocks g b p q)
      = (p : ℚ) ^ 3 * (((g : ℚ) - 1) * (g : ℚ) ^ b) ^ 3
        + (q : ℚ) ^ 3 * (1 + ((g : ℚ) - 1) ^ 3 * ((((g : ℚ) ^ b) ^ 3 - 1) / ((g : ℚ) ^ 3 - 1))) := by
  have hcast : (((g - 1 : ℕ)) : ℚ) = (g : ℚ) - 1 := by
    rw [Nat.cast_sub (by omega : 1 ≤ g), Nat.cast_one]
  rw [wGBlocks, cubeSum_cons, cubeSum_map_mul, gBlocks_cubeSum g hg]
  have h : (((p * ((g - 1) * g ^ b) : ℕ)) : ℚ) ^ 3
      = (p : ℚ) ^ 3 * (((g : ℚ) - 1) * (g : ℚ) ^ b) ^ 3 := by
    push_cast [hcast]
    ring
  rw [h]

lemma wGBlocks_two_le_sum (g : ℕ) (hg : 2 ≤ g) (b p q : ℕ) (hp : 1 ≤ p) (hq : 1 ≤ q) :
    2 ≤ (wGBlocks g b p q).sum := by
  rw [wGBlocks_sum g (by omega)]
  have hpg : 1 ≤ p * (g - 1) :=
    Nat.one_le_iff_ne_zero.2 (Nat.mul_ne_zero (by omega) (by omega))
  have h1 : 2 ≤ p * (g - 1) + q := by omega
  have h2 : 1 ≤ g ^ b := Nat.one_le_pow _ _ (by omega)
  calc 2 = 2 * 1 := by norm_num
    _ ≤ (p * (g - 1) + q) * g ^ b := Nat.mul_le_mul h1 h2

/-- **Exact base-`g` weighted ceiling law.** -/
theorem wGBlocks_spearmanSq (g : ℕ) (hg : 2 ≤ g) (b p q : ℕ) (hp : 1 ≤ p) (hq : 1 ≤ q) :
    spearmanSq (wGBlocks g b p q)
      = 1 - (cubeSum (wGBlocks g b p q) - (((p * (g - 1) + q : ℕ) : ℚ) * (g : ℚ) ^ b))
          / (((((p * (g - 1) + q : ℕ) : ℚ)) * (g : ℚ) ^ b) ^ 3
              - ((p * (g - 1) + q : ℕ) : ℚ) * (g : ℚ) ^ b) := by
  have h2 := wGBlocks_two_le_sum g hg b p q hp hq
  have hcast : (((wGBlocks g b p q).sum : ℕ) : ℚ) = ((p * (g - 1) + q : ℕ) : ℚ) * (g : ℚ) ^ b := by
    rw [wGBlocks_sum g (by omega)]
    push_cast
    ring
  rw [spearmanSq_of_cubeSum _ h2, hcast]

/-! ## 3. The radix modulus and the asymptotic ceiling -/

/-- The radix modulus `κ_g = (g³-1)/(g-1)³`; it equals `7` in base two. -/
noncomputable def kappaRadix (g : ℝ) : ℝ := (g ^ 3 - 1) / (g - 1) ^ 3

theorem kappaRadix_two : kappaRadix 2 = 7 := by norm_num [kappaRadix]

theorem kappaRadix_ten : kappaRadix 10 = 111 / 81 := by norm_num [kappaRadix]

/-- The alternative closed form `κ_g = (g²+g+1)/(g-1)²`. -/
theorem kappaRadix_eq (g : ℝ) (hg : 1 < g) :
    kappaRadix g = (g ^ 2 + g + 1) / (g - 1) ^ 2 := by
  have h : g - 1 ≠ 0 := by intro hc; nlinarith
  unfold kappaRadix
  field_simp
  ring

theorem kappaRadix_pos (g : ℝ) (hg : 1 < g) : 0 < kappaRadix g := by
  have h1 : (0 : ℝ) < g - 1 := by linarith
  have h2 : (0 : ℝ) < g ^ 3 - 1 := by
    nlinarith [mul_pos h1 (by nlinarith : (0 : ℝ) < g ^ 2 + g + 1)]
  unfold kappaRadix
  positivity

/-- The asymptotic ceiling of the base-`g` stratified weighting `(p,q)`. -/
noncomputable def radixCeiling (g p q : ℝ) : ℝ :=
  1 - ((p * (g - 1)) ^ 3 + q ^ 3 / kappaRadix g) / (p * (g - 1) + q) ^ 3

/-- In base two the radix ceiling is the `stratCeiling` of cycle 1. -/
theorem radixCeiling_two (p q : ℝ) : radixCeiling 2 p q = stratCeiling p q := by
  rw [radixCeiling, stratCeiling, kappaRadix_two]
  norm_num

/-- The closed form of the base-`g` weighted ceiling in `ℝ`, normalised by `g^{3b}`. -/
lemma wGBlocks_spearmanSq_real (g : ℕ) (hg : 2 ≤ g) (b p q : ℕ) (hp : 1 ≤ p) (hq : 1 ≤ q) :
    ((spearmanSq (wGBlocks g b p q) : ℚ) : ℝ)
      = 1 - (((p : ℝ) * ((g : ℝ) - 1)) ^ 3 + (q : ℝ) ^ 3 / kappaRadix (g : ℝ)
              + ((q : ℝ) ^ 3 * (1 - ((g : ℝ) - 1) ^ 3 / ((g : ℝ) ^ 3 - 1)))
                  * (1 / (g : ℝ) ^ 3) ^ b
              - ((p : ℝ) * ((g : ℝ) - 1) + q) * (1 / (g : ℝ) ^ 2) ^ b)
          / (((p : ℝ) * ((g : ℝ) - 1) + q) ^ 3
              - ((p : ℝ) * ((g : ℝ) - 1) + q) * (1 / (g : ℝ) ^ 2) ^ b) := by
  have hg1 : (2 : ℝ) ≤ (g : ℝ) := by exact_mod_cast hg
  have hp1 : (1 : ℝ) ≤ (p : ℝ) := by exact_mod_cast hp
  have hq1 : (1 : ℝ) ≤ (q : ℝ) := by exact_mod_cast hq
  have hgm : (1 : ℝ) ≤ (g : ℝ) - 1 := by linarith
  have hS : (2 : ℝ) ≤ (p : ℝ) * ((g : ℝ) - 1) + q := by nlinarith
  have hcast : (((g - 1 : ℕ)) : ℝ) = (g : ℝ) - 1 := by
    rw [Nat.cast_sub (by omega : 1 ≤ g), Nat.cast_one]
  have hg3 : (8 : ℝ) ≤ (g : ℝ) ^ 3 := real_cube_ge hg1
  have hgne : ((g : ℝ) ^ 3 - 1) ≠ 0 := by intro hc; linarith
  have hkap : kappaRadix (g : ℝ) = ((g : ℝ) ^ 3 - 1) / ((g : ℝ) - 1) ^ 3 := rfl
  rw [wGBlocks_spearmanSq g hg b p q hp hq, wGBlocks_cubeSum g hg]
  push_cast [hcast]
  set x : ℝ := (g : ℝ) ^ b with hxdef
  have hx1 : (1 : ℝ) ≤ x := one_le_pow₀ (by linarith)
  have hx0 : (0 : ℝ) < x := by linarith
  have h3' : (1 / (g : ℝ) ^ 3) ^ b = 1 / x ^ 3 := by
    rw [div_pow, one_pow, hxdef, ← pow_mul, mul_comm, pow_mul]
  have h2' : (1 / (g : ℝ) ^ 2) ^ b = 1 / x ^ 2 := by
    rw [div_pow, one_pow, hxdef, ← pow_mul, mul_comm, pow_mul]
  rw [h3', h2', hkap]
  set S : ℝ := (p : ℝ) * ((g : ℝ) - 1) + q with hSdef
  have hSx : (2 : ℝ) ≤ S * x := by nlinarith
  have hD1 : (0 : ℝ) < (S * x) ^ 3 - S * x := real_cube_sub_self_pos hSx
  have hD2 : (0 : ℝ) < S ^ 3 - S * (1 / x ^ 2) := by
    have h1 : (1 : ℝ) / x ^ 2 ≤ 1 := by
      rw [div_le_one (by positivity)]; nlinarith
    have h2 : S * (1 / x ^ 2) ≤ S * 1 := mul_le_mul_of_nonneg_left h1 (by linarith)
    rw [mul_one] at h2
    have h3 : (0 : ℝ) < S ^ 3 - S := real_cube_sub_self_pos hS
    linarith
  have hgm0 : ((g : ℝ) - 1) ≠ 0 := by linarith
  congr 1
  rw [div_eq_div_iff (ne_of_gt hD1) (ne_of_gt hD2)]
  field_simp
  ring

/-- **The asymptotic base-`g` weighted ceiling.** -/
theorem wGBlocks_ceiling_tendsto (g : ℕ) (hg : 2 ≤ g) (p q : ℕ) (hp : 1 ≤ p) (hq : 1 ≤ q) :
    Filter.Tendsto (fun b : ℕ => ((spearmanSq (wGBlocks g b p q) : ℚ) : ℝ)) Filter.atTop
      (nhds (radixCeiling (g : ℝ) (p : ℝ) (q : ℝ))) := by
  have hg1 : (2 : ℝ) ≤ (g : ℝ) := by exact_mod_cast hg
  have hp1 : (1 : ℝ) ≤ (p : ℝ) := by exact_mod_cast hp
  have hq1 : (1 : ℝ) ≤ (q : ℝ) := by exact_mod_cast hq
  have hgm : (1 : ℝ) ≤ (g : ℝ) - 1 := by linarith
  have hS : (0 : ℝ) < (p : ℝ) * ((g : ℝ) - 1) + q := by nlinarith
  have hg3 : (8 : ℝ) ≤ (g : ℝ) ^ 3 := real_cube_ge hg1
  have h3 : Filter.Tendsto (fun b : ℕ => (1 / (g : ℝ) ^ 3) ^ b) Filter.atTop (nhds 0) := by
    apply tendsto_pow_atTop_nhds_zero_of_lt_one
    · positivity
    · rw [div_lt_one (by positivity)]; linarith
  have h2 : Filter.Tendsto (fun b : ℕ => (1 / (g : ℝ) ^ 2) ^ b) Filter.atTop (nhds 0) := by
    apply tendsto_pow_atTop_nhds_zero_of_lt_one
    · positivity
    · rw [div_lt_one (by positivity)]; nlinarith
  have hnum : Filter.Tendsto
      (fun b : ℕ => ((p : ℝ) * ((g : ℝ) - 1)) ^ 3 + (q : ℝ) ^ 3 / kappaRadix (g : ℝ)
        + ((q : ℝ) ^ 3 * (1 - ((g : ℝ) - 1) ^ 3 / ((g : ℝ) ^ 3 - 1))) * (1 / (g : ℝ) ^ 3) ^ b
        - ((p : ℝ) * ((g : ℝ) - 1) + q) * (1 / (g : ℝ) ^ 2) ^ b) Filter.atTop
      (nhds (((p : ℝ) * ((g : ℝ) - 1)) ^ 3 + (q : ℝ) ^ 3 / kappaRadix (g : ℝ))) := by
    have := ((tendsto_const_nhds
      (x := ((p : ℝ) * ((g : ℝ) - 1)) ^ 3 + (q : ℝ) ^ 3 / kappaRadix (g : ℝ))
      (f := Filter.atTop (α := ℕ))).add
      (h3.const_mul ((q : ℝ) ^ 3 * (1 - ((g : ℝ) - 1) ^ 3 / ((g : ℝ) ^ 3 - 1))))).sub
      (h2.const_mul ((p : ℝ) * ((g : ℝ) - 1) + q))
    simpa using this
  have hden : Filter.Tendsto
      (fun b : ℕ => ((p : ℝ) * ((g : ℝ) - 1) + q) ^ 3
        - ((p : ℝ) * ((g : ℝ) - 1) + q) * (1 / (g : ℝ) ^ 2) ^ b) Filter.atTop
      (nhds (((p : ℝ) * ((g : ℝ) - 1) + q) ^ 3)) := by
    have := (tendsto_const_nhds (x := ((p : ℝ) * ((g : ℝ) - 1) + q) ^ 3)
      (f := Filter.atTop (α := ℕ))).sub (h2.const_mul ((p : ℝ) * ((g : ℝ) - 1) + q))
    simpa using this
  have hne : ((p : ℝ) * ((g : ℝ) - 1) + q) ^ 3 ≠ 0 := by positivity
  have := (tendsto_const_nhds (x := (1 : ℝ)) (f := Filter.atTop (α := ℕ))).sub
    (hnum.div hden hne)
  refine this.congr fun b => ?_
  simp only [Pi.div_apply]
  exact (wGBlocks_spearmanSq_real g hg b p q hp hq).symm

/-! ## 4. The radix cap -/

/-- **The radix cap.**  No stratified weighting of the base-`g` trailing-zero dial can push
the asymptotic Spearman ceiling above `1 - 1/(1 + √κ_g)²`. -/
theorem radixCeiling_le_cap (g p q : ℝ) (hg : 1 < g) (hp : 0 < p) (hq : 0 ≤ q) :
    radixCeiling g p q ≤ 1 - 1 / (1 + Real.sqrt (kappaRadix g)) ^ 2 := by
  have hk : 0 < kappaRadix g := kappaRadix_pos g hg
  have hs : 0 < Real.sqrt (kappaRadix g) := Real.sqrt_pos.2 hk
  have hs2 : Real.sqrt (kappaRadix g) ^ 2 = kappaRadix g := Real.sq_sqrt (le_of_lt hk)
  have hu : 0 < p * (g - 1) := by
    have : (0 : ℝ) < g - 1 := by linarith
    positivity
  have := weighted_cubic_cap hs hu hq
  rw [hs2] at this
  unfold radixCeiling
  linarith

/-- Sharpness of the radix cap: it is attained at `q = (g-1)·√κ_g·p`. -/
theorem radixCeiling_eq_cap (g p : ℝ) (hg : 1 < g) (hp : 0 < p) :
    radixCeiling g p (Real.sqrt (kappaRadix g) * (p * (g - 1)))
      = 1 - 1 / (1 + Real.sqrt (kappaRadix g)) ^ 2 := by
  have hk : 0 < kappaRadix g := kappaRadix_pos g hg
  have hs : 0 < Real.sqrt (kappaRadix g) := Real.sqrt_pos.2 hk
  have hs2 : Real.sqrt (kappaRadix g) ^ 2 = kappaRadix g := Real.sq_sqrt (le_of_lt hk)
  have hu : (0 : ℝ) < p * (g - 1) := by
    have : (0 : ℝ) < g - 1 := by linarith
    positivity
  have hune : (p * (g - 1)) ^ 3 ≠ 0 := by positivity
  have hne : (1 : ℝ) + Real.sqrt (kappaRadix g) ≠ 0 := by positivity
  set s := Real.sqrt (kappaRadix g) with hsdef
  set u := p * (g - 1) with hudef
  have hsne : s ≠ 0 := ne_of_gt hs
  unfold radixCeiling
  have hnum : u ^ 3 + (s * u) ^ 3 / kappaRadix g = u ^ 3 * (1 + s) := by
    rw [← hs2, mul_pow]
    field_simp
    ring
  have hden : (u + s * u) ^ 3 = u ^ 3 * (1 + s) ^ 3 := by ring
  rw [hnum, hden]
  congr 1
  field_simp

/-! ## 5. Rational weightings are strictly suboptimal in base two -/

/-- Strict form of the cubic cap: away from the optimal ratio the deficit is a genuine
square. -/
theorem weighted_cubic_cap_strict {s u v : ℝ} (hs : 0 < s) (hu : 0 < u) (hv : 0 ≤ v)
    (hne : v ≠ s * u) :
    1 / (1 + s) ^ 2 < (u ^ 3 + v ^ 3 / s ^ 2) / (u + v) ^ 3 := by
  have hsum : (0 : ℝ) < u + v := by linarith
  have hcube : (0 : ℝ) < (u + v) ^ 3 := by positivity
  have hden : (0 : ℝ) < (1 + s) ^ 2 := by positivity
  have hs2 : (0 : ℝ) < s ^ 2 := by positivity
  have hsq : 0 < (v - s * u) ^ 2 := by
    have : v - s * u ≠ 0 := sub_ne_zero.2 hne
    positivity
  have hpos : 0 < (v - s * u) ^ 2 * ((1 + 2 * s) * v + s * (2 + s) * u) := by
    apply mul_pos hsq
    nlinarith
  have hkey : s ^ 2 * (u + v) ^ 3 < (1 + s) ^ 2 * (s ^ 2 * u ^ 3 + v ^ 3) := by
    have := cubic_weight_identity s u v
    linarith
  rw [div_lt_div_iff₀ hden hcube]
  have hexp : (u ^ 3 + v ^ 3 / s ^ 2) * (1 + s) ^ 2
      = ((1 + s) ^ 2 * (s ^ 2 * u ^ 3 + v ^ 3)) / s ^ 2 := by
    field_simp
  rw [hexp, one_mul, lt_div_iff₀ hs2]
  nlinarith

/-- **Arithmetic obstruction.**  The optimal binary weight ratio is `√7`, which is
irrational; hence every weighting by rational multiplicities is *strictly* below the cap.
No experimental protocol with rational weights can realise the optimum. -/
theorem rational_weighting_strictly_suboptimal (p q : ℚ) (hp : 0 < p) (hq : 0 < q) :
    stratCeiling (p : ℝ) (q : ℝ) < stratOptimum := by
  have hirr : Irrational (Real.sqrt 7) := by
    have : Nat.Prime 7 := by norm_num
    simpa using this.irrational_sqrt
  have hs : (0 : ℝ) < Real.sqrt 7 := Real.sqrt_pos.2 (by norm_num)
  have hs2 : Real.sqrt 7 ^ 2 = 7 := Real.sq_sqrt (by norm_num)
  have hp0 : (0 : ℝ) < (p : ℝ) := by exact_mod_cast hp
  have hq0 : (0 : ℝ) < (q : ℝ) := by exact_mod_cast hq
  have hne : (q : ℝ) ≠ Real.sqrt 7 * (p : ℝ) := by
    intro hcon
    have hpne : (p : ℝ) ≠ 0 := ne_of_gt hp0
    have : Real.sqrt 7 = ((q / p : ℚ) : ℝ) := by
      push_cast
      field_simp at hcon ⊢
      linarith [hcon]
    exact hirr ⟨q / p, this.symm⟩
  have := weighted_cubic_cap_strict hs hp0 (le_of_lt hq0) hne
  rw [hs2] at this
  unfold stratCeiling stratOptimum
  linarith

/-! ## 6. The reweighting budget as a function of the radix -/

/-- The reweighting budget in `ρ²` units for modulus `K`: the difference between the optimal
stratified ceiling and the unweighted one. -/
noncomputable def weightGain (K : ℝ) : ℝ := 1 / K - 1 / (1 + Real.sqrt K) ^ 2

/-- The budget in terms of the square root of the modulus. -/
lemma weightGain_of_sq {s : ℝ} (hs : 0 < s) :
    weightGain (s ^ 2) = (1 + 2 * s) / (s ^ 2 * (1 + s) ^ 2) := by
  have h1 : s ≠ 0 := ne_of_gt hs
  have h2 : (1 : ℝ) + s ≠ 0 := by positivity
  unfold weightGain
  rw [Real.sqrt_sq (le_of_lt hs)]
  field_simp
  ring

theorem weightGain_pos {K : ℝ} (hK : 0 < K) : 0 < weightGain K := by
  have hs : 0 < Real.sqrt K := Real.sqrt_pos.2 hK
  have hs2 : Real.sqrt K ^ 2 = K := Real.sq_sqrt (le_of_lt hK)
  have h1 : K < (1 + Real.sqrt K) ^ 2 := by nlinarith
  have h2 : (0 : ℝ) < (1 + Real.sqrt K) ^ 2 := by positivity
  unfold weightGain
  rw [sub_pos]
  exact one_div_lt_one_div_of_lt hK h1

/-- The budget is strictly decreasing in the modulus: small modulus, large budget. -/
theorem weightGain_strictAnti {K L : ℝ} (hK : 0 < K) (hKL : K < L) :
    weightGain L < weightGain K := by
  have hL : 0 < L := lt_trans hK hKL
  have hsK : 0 < Real.sqrt K := Real.sqrt_pos.2 hK
  have hsL : 0 < Real.sqrt L := Real.sqrt_pos.2 hL
  have hsK2 : Real.sqrt K ^ 2 = K := Real.sq_sqrt (le_of_lt hK)
  have hsL2 : Real.sqrt L ^ 2 = L := Real.sq_sqrt (le_of_lt hL)
  have hlt : Real.sqrt K < Real.sqrt L := Real.sqrt_lt_sqrt (le_of_lt hK) hKL
  have hgK : weightGain K
      = (1 + 2 * Real.sqrt K) / (Real.sqrt K ^ 2 * (1 + Real.sqrt K) ^ 2) := by
    conv_lhs => rw [← hsK2]
    exact weightGain_of_sq hsK
  have hgL : weightGain L
      = (1 + 2 * Real.sqrt L) / (Real.sqrt L ^ 2 * (1 + Real.sqrt L) ^ 2) := by
    conv_lhs => rw [← hsL2]
    exact weightGain_of_sq hsL
  set a := Real.sqrt K
  set b := Real.sqrt L
  rw [hgK, hgL]
  rw [div_lt_div_iff₀ (by positivity) (by positivity)]
  nlinarith [mul_pos hsK hsL, sq_nonneg (b - a), mul_pos (mul_pos hsK hsL) hsK,
    mul_pos (mul_pos hsK hsL) hsL, mul_pos (mul_pos (mul_pos hsK hsL) hsK) hsL]

/-! ## 7. Binary versus decimal -/

theorem binary_gain_lt : weightGain 7 < 0.068 := by
  obtain ⟨h1, h2⟩ := sqrt_seven_bounds
  have hpos : (0 : ℝ) < (1 + Real.sqrt 7) ^ 2 := by positivity
  have hlow : (0.0752360 : ℝ) < 1 / (1 + Real.sqrt 7) ^ 2 := by
    rw [lt_div_iff₀ hpos]; nlinarith
  have hone : (1 : ℝ) / 7 < 0.1428572 := by norm_num
  unfold weightGain
  linarith

lemma sqrt_kappa_ten_bounds :
    (1.1706 : ℝ) < Real.sqrt (111 / 81) ∧ Real.sqrt (111 / 81) < 1.1707 := by
  constructor
  · have h : (1.1706 : ℝ) ^ 2 < 111 / 81 := by norm_num
    nlinarith [Real.sq_sqrt (by norm_num : (111 / 81 : ℝ) ≥ 0),
      Real.sqrt_nonneg (111 / 81 : ℝ)]
  · have h : (111 / 81 : ℝ) < 1.1707 ^ 2 := by norm_num
    nlinarith [Real.sq_sqrt (by norm_num : (111 / 81 : ℝ) ≥ 0),
      Real.sqrt_nonneg (111 / 81 : ℝ)]

theorem decimal_gain_gt : 0.5 < weightGain (111 / 81) := by
  obtain ⟨h1, h2⟩ := sqrt_kappa_ten_bounds
  have hpos : (0 : ℝ) < (1 + Real.sqrt (111 / 81)) ^ 2 := by positivity
  have hup : 1 / (1 + Real.sqrt (111 / 81)) ^ 2 < 0.2123 := by
    rw [div_lt_iff₀ hpos]; nlinarith
  have hone : (0.7297 : ℝ) < 1 / (111 / 81 : ℝ) := by norm_num
  unfold weightGain
  linarith

/-- **The radix prediction.**  The decimal dial has more than seven times the reweighting
budget of the binary dial: the `√7` cap of cycle 1 is the *worst case* over all radices. -/
theorem decimal_gain_exceeds_binary :
    7 * weightGain 7 < weightGain (kappaRadix 10) := by
  have hb := binary_gain_lt
  have hd := decimal_gain_gt
  rw [kappaRadix_ten]
  linarith

/-- The radix modulus is strictly decreasing in the radix, so by `weightGain_strictAnti`
the reweighting budget strictly increases with the radix. -/
theorem kappaRadix_strictAnti {g h : ℝ} (hg : 1 < g) (hgh : g < h) :
    kappaRadix h < kappaRadix g := by
  have hg1 : (0 : ℝ) < g - 1 := by linarith
  have hh1 : (0 : ℝ) < h - 1 := by linarith
  rw [kappaRadix_eq g hg, kappaRadix_eq h (by linarith)]
  rw [div_lt_div_iff₀ (by positivity) (by positivity)]
  nlinarith [mul_pos hg1 hh1, sq_nonneg (h - g), mul_pos (mul_pos hg1 hh1) hg1,
    mul_pos (mul_pos hg1 hh1) hh1]

/-- **Monotone radix law.**  Larger radix ⇒ strictly larger reweighting budget. -/
theorem weightGain_radix_strictMono {g h : ℝ} (hg : 1 < g) (hgh : g < h) :
    weightGain (kappaRadix g) < weightGain (kappaRadix h) :=
  weightGain_strictAnti (kappaRadix_pos h (by linarith)) (kappaRadix_strictAnti hg hgh)

end Catalog.MachineLearning.ZeroFitDialRadixWeighting