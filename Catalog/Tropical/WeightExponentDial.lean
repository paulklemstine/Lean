import Mathlib

/-!
# The dial weight exponent: `1/ℓ^α` families, log-convexity, and their tropical limit

Round-83 / exp-586 fitted the exponent `α` of the *product-dial weight* `ℓ ↦ ℓ^(-α)`
instead of adopting the harmonic value `α = 1` by inspection, and found an interior
optimum at `α̂ = 1/2`.  This file develops the exact mathematics of the one-parameter
weight family that the fit ranges over, in a form that is independent of the
particular data set:

* `WeightDial.dialWeight`, `WeightDial.dialSum` : the weight `ℓ^(-α)` and the
  *dial statistic* `S_α = ∑_{ℓ ∈ supp} ℓ^(-α)`, where `supp` is the set of primes
  whose indicator `c_ℓ` is on.
* `WeightDial.dialSum_strictAnti` : `α ↦ S_α` is strictly decreasing.
* `WeightDial.dialSum_sq_midpoint_le` : *midpoint log-convexity*,
  `S_{(α+β)/2}^2 ≤ S_α · S_β` (discrete Cauchy–Schwarz), so `α ↦ log S_α` is convex.
* `WeightDial.dialSum_sq_midpoint_lt_pair` : the convexity is **strict** as soon as the
  support contains two distinct primes and `α ≠ β`.  Hence the family is a genuine
  (non-degenerate) one-parameter deformation: no two exponents give proportional
  covariates, which is exactly what makes fitting `α` a well-posed problem.
* `WeightDial.dialSum_between_tropical` and `WeightDial.tendsto_log_dialSum_div`:
  the **tropical (Maslov) limit**.  `S_α` is squeezed between `m^(-α)` and
  `|supp| · m^(-α)` for the smallest active prime `m`, so
  `(log S_α)/α → -log m` as `α → ∞`: the weighted dial dequantizes to the min-plus
  statistic `min {ℓ : c_ℓ = 1}`.
* `WeightDial.ratio_half_lt`, `WeightDial.ratio_one`, `WeightDial.ratio_gain_gt`:
  the quantitative erratum statement — at the window edge `ℓ = 400` the `√`-weight
  gives the large prime more than `11` times its harmonic relative weight.
-/

open Finset

namespace WeightDial

/-- The product-dial weight of a prime `l` at exponent `α`, i.e. `1 / l ^ α`. -/
noncomputable def dialWeight (α : ℝ) (l : ℕ) : ℝ := (l : ℝ) ^ (-α)

/-- The dial statistic `S_α = ∑_{l ∈ supp} l ^ (-α)`; `supp` is the set of primes in the
window whose indicator `c_l = [jacobi (N mod l, l) = +1]` is on. -/
noncomputable def dialSum (supp : Finset ℕ) (α : ℝ) : ℝ :=
  ∑ l ∈ supp, dialWeight α l

lemma dialWeight_pos {l : ℕ} (hl : 0 < l) (α : ℝ) : 0 < dialWeight α l :=
  Real.rpow_pos_of_pos (by exact_mod_cast hl) _

lemma dialSum_pos {supp : Finset ℕ} (h2 : ∀ l ∈ supp, 2 ≤ l) (hne : supp.Nonempty) :
    0 < dialSum supp α := by
  refine Finset.sum_pos (fun l hl => dialWeight_pos (by have := h2 l hl; omega) α) hne

/-- Each individual weight is strictly decreasing in the exponent (for a base `> 1`). -/
lemma dialWeight_strictAnti {l : ℕ} (hl : 2 ≤ l) {α β : ℝ} (hab : α < β) :
    dialWeight β l < dialWeight α l := by
  have h1 : (1 : ℝ) < (l : ℝ) := by exact_mod_cast hl.trans_lt' one_lt_two
  exact Real.rpow_lt_rpow_of_exponent_lt h1 (by linarith)

/-- The dial statistic is strictly decreasing in the weight exponent. -/
theorem dialSum_strictAnti {supp : Finset ℕ} (h2 : ∀ l ∈ supp, 2 ≤ l) (hne : supp.Nonempty) :
    StrictAnti (dialSum supp) := by
  intro α β hab
  exact Finset.sum_lt_sum_of_nonempty hne (fun l hl => dialWeight_strictAnti (h2 l hl) hab)

private lemma rpow_half_sq {x : ℝ} (hx : 0 ≤ x) (α : ℝ) :
    (x ^ (-α / 2)) ^ 2 = x ^ (-α) := by
  rw [← Real.rpow_natCast (x ^ (-α / 2)) 2, ← Real.rpow_mul hx]
  norm_num

/-- **Midpoint log-convexity of the dial family** (discrete Cauchy–Schwarz):
`S_{(α+β)/2}^2 ≤ S_α · S_β`.  Consequently `α ↦ log S_α` is a convex function, so the
dial statistic cannot be matched by any log-linear surrogate. -/
theorem dialSum_sq_midpoint_le {supp : Finset ℕ} (h2 : ∀ l ∈ supp, 2 ≤ l) (α β : ℝ) :
    dialSum supp ((α + β) / 2) ^ 2 ≤ dialSum supp α * dialSum supp β := by
  have key := Finset.sum_mul_sq_le_sq_mul_sq supp
    (fun l : ℕ => (l : ℝ) ^ (-α / 2)) (fun l : ℕ => (l : ℝ) ^ (-β / 2))
  have hmid : ∀ l ∈ supp,
      ((l : ℝ) ^ (-α / 2)) * ((l : ℝ) ^ (-β / 2)) = dialWeight ((α + β) / 2) l := by
    intro l hl
    have hl0 : (0 : ℝ) < (l : ℝ) := by
      have := h2 l hl; exact_mod_cast (by omega : 0 < l)
    rw [← Real.rpow_add hl0]
    unfold dialWeight
    ring_nf
  have hsq : ∀ l ∈ supp, ((l : ℝ) ^ (-α / 2)) ^ 2 = dialWeight α l := by
    intro l _; exact rpow_half_sq (Nat.cast_nonneg l) α
  have hsq' : ∀ l ∈ supp, ((l : ℝ) ^ (-β / 2)) ^ 2 = dialWeight β l := by
    intro l _; exact rpow_half_sq (Nat.cast_nonneg l) β
  calc dialSum supp ((α + β) / 2) ^ 2
      = (∑ l ∈ supp, ((l : ℝ) ^ (-α / 2)) * ((l : ℝ) ^ (-β / 2))) ^ 2 := by
        rw [Finset.sum_congr rfl hmid]; rfl
    _ ≤ (∑ l ∈ supp, ((l : ℝ) ^ (-α / 2)) ^ 2) * ∑ l ∈ supp, ((l : ℝ) ^ (-β / 2)) ^ 2 := key
    _ = dialSum supp α * dialSum supp β := by
        rw [Finset.sum_congr rfl hsq, Finset.sum_congr rfl hsq']; rfl

/-- **Strict** midpoint log-convexity on a two-prime support: for `a ≠ b` (both `≥ 2`)
and `α ≠ β`, `S_{(α+β)/2}^2 < S_α · S_β`.  So distinct exponents really do produce
non-proportional covariates; the fitted exponent is identifiable in principle. -/
theorem dialSum_sq_midpoint_lt_pair {a b : ℕ} (ha : 2 ≤ a) (hb : 2 ≤ b) (hab : a ≠ b)
    {α β : ℝ} (hαβ : α ≠ β) :
    dialSum {a, b} ((α + β) / 2) ^ 2 < dialSum {a, b} α * dialSum {a, b} β := by
  have ha0 : (0 : ℝ) < (a : ℝ) := by exact_mod_cast (by omega : 0 < a)
  have hb0 : (0 : ℝ) < (b : ℝ) := by exact_mod_cast (by omega : 0 < b)
  have hab' : (a : ℝ) ≠ (b : ℝ) := by exact_mod_cast hab
  set u := Real.log a with hu
  set v := Real.log b with hv
  have huv : u ≠ v := by
    intro h
    refine hab' ?_
    have := congrArg Real.exp h
    rwa [hu, hv, Real.exp_log ha0, Real.exp_log hb0] at this
  have hpair : ∀ x : ℝ, dialSum {a, b} x = Real.exp (-x * u) + Real.exp (-x * v) := by
    intro x
    rw [dialSum, Finset.sum_pair hab]
    simp [dialWeight, Real.rpow_def_of_pos ha0, Real.rpow_def_of_pos hb0, hu, hv, mul_comm]
  set A := Real.exp (-α / 2 * u) with hA
  set A' := Real.exp (-β / 2 * u) with hA'
  set B := Real.exp (-α / 2 * v) with hB
  set B' := Real.exp (-β / 2 * v) with hB'
  have hmid : dialSum {a, b} ((α + β) / 2) = A * A' + B * B' := by
    rw [hpair, hA, hA', hB, hB', ← Real.exp_add, ← Real.exp_add]
    ring_nf
  have hα' : dialSum {a, b} α = A ^ 2 + B ^ 2 := by
    rw [hpair, hA, hB, ← Real.exp_nat_mul, ← Real.exp_nat_mul]
    norm_num
    ring_nf
  have hβ' : dialSum {a, b} β = A' ^ 2 + B' ^ 2 := by
    rw [hpair, hA', hB', ← Real.exp_nat_mul, ← Real.exp_nat_mul]
    norm_num
    ring_nf
  have hne : A * B' - A' * B ≠ 0 := by
    intro h
    have h1 : A * B' = A' * B := by linarith
    rw [hA, hA', hB, hB', ← Real.exp_add, ← Real.exp_add, Real.exp_eq_exp] at h1
    have : (β - α) / 2 * (u - v) = 0 := by linarith
    rcases mul_eq_zero.1 this with h2 | h2
    · exact hαβ (by linarith [div_eq_zero_iff.1 h2])
    · exact huv (by linarith)
  have hpos : 0 < (A * B' - A' * B) ^ 2 := pow_two_pos_of_ne_zero hne
  rw [hmid, hα', hβ']
  nlinarith [hpos]

/-- **Hölder form of log-convexity.**  For every weight `t ∈ [0,1]`,
`S_{tα + (1-t)β} ≤ S_α^t · S_β^{1-t}`. -/
theorem dialSum_le_rpow_mul_rpow {supp : Finset ℕ} (h2 : ∀ l ∈ supp, 2 ≤ l)
    (hne : supp.Nonempty) {t : ℝ} (ht0 : 0 ≤ t) (ht1 : t ≤ 1) (α β : ℝ) :
    dialSum supp (t * α + (1 - t) * β)
      ≤ dialSum supp α ^ t * dialSum supp β ^ (1 - t) := by
  have hA : 0 < dialSum supp α := dialSum_pos h2 hne
  have hB : 0 < dialSum supp β := dialSum_pos h2 hne
  have hAt : 0 < dialSum supp α ^ t := Real.rpow_pos_of_pos hA t
  have hBt : 0 < dialSum supp β ^ (1 - t) := Real.rpow_pos_of_pos hB (1 - t)
  have ht1' : 0 ≤ 1 - t := by linarith
  have hterm : ∀ l ∈ supp, dialWeight (t * α + (1 - t) * β) l
      ≤ dialSum supp α ^ t * dialSum supp β ^ (1 - t) *
        (t * (dialWeight α l / dialSum supp α)
          + (1 - t) * (dialWeight β l / dialSum supp β)) := by
    intro l hl
    have hlpos : 0 < l := by have := h2 l hl; omega
    have hl0 : (0 : ℝ) < (l : ℝ) := by exact_mod_cast hlpos
    have hfact : dialWeight (t * α + (1 - t) * β) l
        = dialWeight α l ^ t * dialWeight β l ^ (1 - t) := by
      unfold dialWeight
      rw [← Real.rpow_mul (le_of_lt hl0), ← Real.rpow_mul (le_of_lt hl0),
        ← Real.rpow_add hl0]
      ring_nf
    have hyoung := Real.geom_mean_le_arith_mean2_weighted ht0 ht1'
      (le_of_lt (div_pos (dialWeight_pos hlpos α) hA))
      (le_of_lt (div_pos (dialWeight_pos hlpos β) hB))
      (by ring)
    rw [Real.div_rpow (le_of_lt (dialWeight_pos hlpos α))
        (le_of_lt hA), Real.div_rpow
        (le_of_lt (dialWeight_pos hlpos β)) (le_of_lt hB)] at hyoung
    rw [hfact]
    have hmul := mul_le_mul_of_nonneg_left hyoung (le_of_lt (mul_pos hAt hBt))
    calc dialWeight α l ^ t * dialWeight β l ^ (1 - t)
        = dialSum supp α ^ t * dialSum supp β ^ (1 - t) *
            (dialWeight α l ^ t / dialSum supp α ^ t *
              (dialWeight β l ^ (1 - t) / dialSum supp β ^ (1 - t))) := by
          field_simp
      _ ≤ _ := hmul
  calc dialSum supp (t * α + (1 - t) * β)
      ≤ ∑ l ∈ supp, dialSum supp α ^ t * dialSum supp β ^ (1 - t) *
          (t * (dialWeight α l / dialSum supp α)
            + (1 - t) * (dialWeight β l / dialSum supp β)) :=
        Finset.sum_le_sum hterm
    _ = dialSum supp α ^ t * dialSum supp β ^ (1 - t) := by
        rw [← Finset.mul_sum]
        have hsum : ∑ l ∈ supp, (t * (dialWeight α l / dialSum supp α)
            + (1 - t) * (dialWeight β l / dialSum supp β)) = 1 := by
          rw [Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum,
            ← Finset.sum_div, ← Finset.sum_div]
          show t * (dialSum supp α / dialSum supp α)
            + (1 - t) * (dialSum supp β / dialSum supp β) = 1
          rw [div_self (ne_of_gt hA), div_self (ne_of_gt hB)]
          ring
        rw [hsum, mul_one]

/-- **`α ↦ log S_α` is convex.**  The dial family is a log-convex one-parameter
deformation; in particular its `R²`-landscape cannot be reduced to a monotone
reparametrization of the exponent. -/
theorem convexOn_log_dialSum {supp : Finset ℕ} (h2 : ∀ l ∈ supp, 2 ≤ l)
    (hne : supp.Nonempty) :
    ConvexOn ℝ Set.univ (fun α : ℝ => Real.log (dialSum supp α)) := by
  refine ⟨convex_univ, fun α _ β _ a b ha hb hab => ?_⟩
  have hA : 0 < dialSum supp α := dialSum_pos h2 hne
  have hB : 0 < dialSum supp β := dialSum_pos h2 hne
  have hb' : b = 1 - a := by linarith
  subst hb'
  have hkey := dialSum_le_rpow_mul_rpow h2 hne ha (by linarith) α β
  have hpos : 0 < dialSum supp (a * α + (1 - a) * β) := dialSum_pos h2 hne
  have hlog := Real.log_le_log hpos hkey
  rwa [Real.log_mul (ne_of_gt (Real.rpow_pos_of_pos hA a))
      (ne_of_gt (Real.rpow_pos_of_pos hB (1 - a))), Real.log_rpow hA, Real.log_rpow hB] at hlog

/-! ### The tropical (Maslov) limit of the dial -/

/-- Two-sided tropical squeeze: with `m` the smallest active prime and `α ≥ 0`,
`m^(-α) ≤ S_α ≤ |supp| · m^(-α)`.  The left endpoint is the min-plus (tropical) value of
the dial and the right endpoint differs from it by a factor independent of `α`. -/
theorem dialSum_between_tropical {supp : Finset ℕ} (hne : supp.Nonempty)
    (h2 : ∀ l ∈ supp, 2 ≤ l) {α : ℝ} (hα : 0 ≤ α) :
    ((supp.min' hne : ℕ) : ℝ) ^ (-α) ≤ dialSum supp α ∧
      dialSum supp α ≤ supp.card * ((supp.min' hne : ℕ) : ℝ) ^ (-α) := by
  set m := supp.min' hne with hm
  have hm2 : 2 ≤ m := h2 m (supp.min'_mem hne)
  have hmpos : (0 : ℝ) < (m : ℝ) := by exact_mod_cast (by omega : 0 < m)
  have hle : ∀ l ∈ supp, dialWeight α l ≤ (m : ℝ) ^ (-α) := by
    intro l hl
    have hml : (m : ℝ) ≤ (l : ℝ) := by exact_mod_cast supp.min'_le l hl
    unfold dialWeight
    rw [Real.rpow_neg (le_of_lt hmpos), Real.rpow_neg (by positivity)]
    have : (m : ℝ) ^ α ≤ (l : ℝ) ^ α := Real.rpow_le_rpow (le_of_lt hmpos) hml hα
    exact inv_anti₀ (Real.rpow_pos_of_pos hmpos α) this
  constructor
  · calc (m : ℝ) ^ (-α) = dialWeight α m := rfl
      _ ≤ dialSum supp α := by
          refine Finset.single_le_sum (f := dialWeight α) (fun l hl => ?_) (supp.min'_mem hne)
          exact le_of_lt (dialWeight_pos (by have := h2 l hl; omega) α)
  · calc dialSum supp α ≤ ∑ _l ∈ supp, (m : ℝ) ^ (-α) := Finset.sum_le_sum hle
      _ = supp.card * (m : ℝ) ^ (-α) := by rw [Finset.sum_const, nsmul_eq_mul]

/-- Two-sided bound on the normalized log-dial: it lies between the tropical value
`-log m` and `-log m + (log |supp|)/α`. -/
theorem log_dialSum_div_bounds {supp : Finset ℕ} (hne : supp.Nonempty)
    (h2 : ∀ l ∈ supp, 2 ≤ l) {α : ℝ} (hα : 0 < α) :
    -Real.log (supp.min' hne) ≤ Real.log (dialSum supp α) / α ∧
      Real.log (dialSum supp α) / α ≤ Real.log supp.card / α + -Real.log (supp.min' hne) := by
  obtain ⟨hlow, hhigh⟩ := dialSum_between_tropical hne h2 (le_of_lt hα)
  set m := supp.min' hne with hm
  have hm2 : 2 ≤ m := h2 m (supp.min'_mem hne)
  have hmpos : (0 : ℝ) < (m : ℝ) := by exact_mod_cast (by omega : 0 < m)
  have hSpos : 0 < dialSum supp α := dialSum_pos h2 hne
  have hcard : (1 : ℝ) ≤ supp.card := by exact_mod_cast hne.card_pos
  have hrpow : Real.log ((m : ℝ) ^ (-α)) = -α * Real.log m := Real.log_rpow hmpos _
  have h1 : -α * Real.log m ≤ Real.log (dialSum supp α) := by
    rw [← hrpow]
    exact Real.log_le_log (Real.rpow_pos_of_pos hmpos _) hlow
  have h2' : Real.log (dialSum supp α) ≤ Real.log supp.card + -α * Real.log m := by
    have := Real.log_le_log hSpos hhigh
    rwa [Real.log_mul (by positivity) (by positivity), hrpow] at this
  have hlogcard : 0 ≤ Real.log supp.card := Real.log_nonneg hcard
  constructor
  · rw [le_div_iff₀ hα]; nlinarith [h1]
  · rw [div_le_iff₀ hα]
    have hexp : (Real.log supp.card / α + -Real.log m) * α
        = Real.log supp.card - α * Real.log m := by field_simp; ring
    rw [hexp]; linarith

/-- Quantitative dequantization: for `α > 0` the normalized log-dial `(log S_α)/α` differs
from the tropical value `-log m` by at most `(log |supp|)/α`. -/
theorem abs_log_dialSum_div_add_log_min_le {supp : Finset ℕ} (hne : supp.Nonempty)
    (h2 : ∀ l ∈ supp, 2 ≤ l) {α : ℝ} (hα : 0 < α) :
    |Real.log (dialSum supp α) / α + Real.log (supp.min' hne)| ≤ Real.log supp.card / α := by
  obtain ⟨h1, h2'⟩ := log_dialSum_div_bounds hne h2 hα
  have hcard : (1 : ℝ) ≤ supp.card := by exact_mod_cast hne.card_pos
  have hlogcard : 0 ≤ Real.log supp.card / α :=
    div_nonneg (Real.log_nonneg hcard) (le_of_lt hα)
  rw [abs_le]
  constructor <;> linarith

/-- **Tropical (Maslov) limit of the dial**: as the weight exponent grows, the normalized
log of the dial statistic converges to the min-plus value `-log (min supp)`.  The whole
`α`-family therefore interpolates between the counting statistic (`α = 0`) and the
tropical minimum statistic (`α → ∞`); the fitted exponent `α̂ = 1/2` sits strictly inside
this interpolation. -/
theorem tendsto_log_dialSum_div {supp : Finset ℕ} (hne : supp.Nonempty)
    (h2 : ∀ l ∈ supp, 2 ≤ l) :
    Filter.Tendsto (fun α : ℝ => Real.log (dialSum supp α) / α) Filter.atTop
      (nhds (-Real.log (supp.min' hne))) := by
  have hupper : Filter.Tendsto
      (fun α : ℝ => Real.log supp.card / α + -Real.log (supp.min' hne)) Filter.atTop
      (nhds (0 + -Real.log (supp.min' hne))) := by
    exact ((Filter.Tendsto.div_atTop tendsto_const_nhds Filter.tendsto_id).add
      tendsto_const_nhds)
  rw [zero_add] at hupper
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' (g := fun _ : ℝ =>
      -Real.log (supp.min' hne)) tendsto_const_nhds hupper ?_ ?_
  · filter_upwards [Filter.eventually_gt_atTop (0 : ℝ)] with α hα
    exact (log_dialSum_div_bounds hne h2 hα).1
  · filter_upwards [Filter.eventually_gt_atTop (0 : ℝ)] with α hα
    exact (log_dialSum_div_bounds hne h2 hα).2

/-! ### The erratum in numbers: `1/ℓ` versus `1/√ℓ` at the window edge -/

/-- Relative weight carried by the window-edge prime `400` compared to the smallest odd
prime `3`, as a function of the exponent. -/
noncomputable def edgeRatio (α : ℝ) : ℝ := dialWeight α 400 / dialWeight α 3

lemma edgeRatio_pos (α : ℝ) : 0 < edgeRatio α :=
  div_pos (dialWeight_pos (by norm_num) α) (dialWeight_pos (by norm_num) α)

/-- Under the harmonic weight adopted by inspection, the edge prime carries `3/400` of the
weight of `ℓ = 3` (i.e. about `1/133`). -/
theorem edgeRatio_one : edgeRatio 1 = 3 / 400 := by
  unfold edgeRatio dialWeight
  rw [Real.rpow_neg_one, Real.rpow_neg_one]
  norm_num

lemma edgeRatio_half_sq : edgeRatio (1 / 2) ^ 2 = 3 / 400 := by
  have h400 : (0 : ℝ) < ((400 : ℕ) : ℝ) := by norm_num
  have h3 : (0 : ℝ) < ((3 : ℕ) : ℝ) := by norm_num
  unfold edgeRatio dialWeight
  rw [div_pow, ← Real.rpow_natCast (((400 : ℕ) : ℝ) ^ (-(1 / 2) : ℝ)) 2,
    ← Real.rpow_natCast ((((3 : ℕ)) : ℝ) ^ (-(1 / 2) : ℝ)) 2,
    ← Real.rpow_mul (le_of_lt h400), ← Real.rpow_mul (le_of_lt h3)]
  norm_num

/-- Under the fitted `√`-weight the edge prime carries strictly more than `1/12` of the
weight of `ℓ = 3` (numerically `≈ 1/11.5`), against `1/133` under the harmonic weight. -/
theorem edgeRatio_half_bounds : 1 / 12 < edgeRatio (1 / 2) ∧ edgeRatio (1 / 2) < 1 / 11 := by
  have hp := edgeRatio_pos (1 / 2)
  have hs := edgeRatio_half_sq
  constructor <;> nlinarith [hs, hp]

/-- **The erratum, quantified.**  Passing from the inspection-chosen harmonic weight to the
fitted `√`-weight multiplies the relative weight of the window-edge prime `400` by more
than `11.5`. -/
theorem edgeRatio_gain_gt : 11.5 * edgeRatio 1 < edgeRatio (1 / 2) := by
  have hp := edgeRatio_pos (1 / 2)
  have hs := edgeRatio_half_sq
  rw [edgeRatio_one]
  nlinarith [hs, hp]

end WeightDial