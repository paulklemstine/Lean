import Mathlib

/-!
# The OR-dial cap `g(2) = H(3/4) - ½H(1/2)`: the one-dimensional analytic core

This file isolates the *analytic* half of the OR-DIAL-MAXIMUM principle
(Bridges catalogue, paper 73).  The semiprime OR channel attached to a class-rate
profile `r : (ℤ/m)ˣ → [0,1]` has mutual information

`Φ(r) = H(μ²) - avg_c H(f(c))`,   `f(c) = avg_a (1-r(a))(1-r(ca⁻¹))`,  `μ = avg (1-r)`,

where `H` is the binary entropy (here in *nats*: `Real.binEntropy`).  The group-theoretic
half (`Bridges.ORDialMaximum`) shows that the conditional no-fork probabilities `f(c)`
always lie in the window `[max(0, 2μ-1), μ]` and have mean exactly `μ²`.  Concavity of
`H` then reduces the whole variational problem to two one-dimensional inequalities,
which are what this file proves:

* `left_branch`  : `H(μ²) - μ H(μ) ≤ orCap`                        for `0 < μ ≤ 1/2`;
* `right_branch` : `H(μ²) - (μ H(2μ-1) + (1-μ) H(μ)) ≤ orCap`      for `1/2 ≤ μ < 1`.

Both are *sharp*: equality holds at `μ = 1/2`, which is the quadratic-character regime.
The cap is

`orCap = H(1/4) - ½ log 2 = (3/2) log 2 - (3/4) log 3 = 0.21576… nats = 0.31128… bits.`

The proofs use only the tangent-line bound `log a + 1 - a/x ≤ log x` (`log_tangent`) at
the base points `a ∈ {1/2, 1, 3/2, 2}`, together with `log x ≤ x - 1`; the base point
`a = 1/2` is exactly what makes the estimates tight at the extremal profile `μ = 1/2`.
-/

open Real

namespace ORDial

/-- The OR-dial cap `g(2) = H(3/4) - ½ H(1/2)`, in nats. -/
noncomputable def orCap : ℝ := Real.binEntropy (1/4) - Real.log 2 / 2

/-- Closed form of the cap in terms of `log 2` and `log 3`. -/
lemma orCap_eq : orCap = 3/2 * Real.log 2 - 3/4 * Real.log 3 := by
  have h4 : Real.log 4 = 2 * Real.log 2 := by
    rw [show (4:ℝ) = 2^2 by norm_num, Real.log_pow]; push_cast; ring
  have h43 : Real.log (4/3) = 2 * Real.log 2 - Real.log 3 := by
    rw [Real.log_div (by norm_num) (by norm_num), h4]
  simp only [orCap, Real.binEntropy]
  rw [show (1:ℝ)/4 = 4⁻¹ by norm_num, show (1:ℝ) - 4⁻¹ = 3/4 by norm_num]
  rw [inv_inv, show ((3:ℝ)/4)⁻¹ = 4/3 by norm_num, h4, h43]
  ring

/-- Tangent-line lower bound for the logarithm at an arbitrary base point `a > 0`,
in the cleared form `x log a + x - a ≤ x log x`. -/
lemma log_tangent (a x : ℝ) (ha : 0 < a) (hx : 0 < x) :
    x * Real.log a + x - a ≤ x * Real.log x := by
  have h := Real.log_le_sub_one_of_pos (show 0 < a / x by positivity)
  rw [Real.log_div (ne_of_gt ha) (ne_of_gt hx)] at h
  have := mul_le_mul_of_nonneg_left h hx.le
  field_simp at this
  linarith

lemma log_half : Real.log (1/2) = -Real.log 2 := by
  rw [show (1:ℝ)/2 = 2⁻¹ by norm_num, Real.log_inv]

/-- `3^2 > 2^3` gives `log 3 > (3/2) log 2`. -/
lemma log_three_gt : 3/2 * Real.log 2 < Real.log 3 := by
  have h : Real.log 8 < Real.log 9 := Real.log_lt_log (by norm_num) (by norm_num)
  rw [show (8:ℝ) = 2^3 by norm_num, show (9:ℝ) = 3^2 by norm_num, Real.log_pow,
    Real.log_pow] at h
  push_cast at h; linarith

/-- `log (9/8) ≤ 1/8` gives `log 3 ≤ (3/2) log 2 + 1/16`. -/
lemma log_three_le : Real.log 3 ≤ 3/2 * Real.log 2 + 1/16 := by
  have h : Real.log (9/8) ≤ 9/8 - 1 := Real.log_le_sub_one_of_pos (by norm_num)
  rw [Real.log_div (by norm_num) (by norm_num), show (9:ℝ) = 3^2 by norm_num,
    show (8:ℝ) = 2^3 by norm_num, Real.log_pow, Real.log_pow] at h
  push_cast at h; norm_num at h; linarith

/-- High-precision sandwich for `log 3`, obtained from `3^12 = 531441 = 2^19 · (1 + 7153/524288)`. -/
lemma log_three_sandwich :
    (19 * Real.log 2 + 7153/531441)/12 ≤ Real.log 3 ∧
      Real.log 3 ≤ (19 * Real.log 2 + 7153/524288)/12 := by
  have h12 : Real.log 3 = (19 * Real.log 2 + Real.log (531441/524288))/12 := by
    have h1 : Real.log ((531441:ℝ)/524288) = Real.log 531441 - Real.log 524288 :=
      Real.log_div (by norm_num) (by norm_num)
    have h2 : Real.log (531441:ℝ) = 12 * Real.log 3 := by
      rw [show (531441:ℝ) = 3^12 by norm_num, Real.log_pow]; push_cast; ring
    have h3 : Real.log (524288:ℝ) = 19 * Real.log 2 := by
      rw [show (524288:ℝ) = 2^19 by norm_num, Real.log_pow]; push_cast; ring
    rw [h1, h2, h3]; ring
  constructor
  · have h := Real.log_le_sub_one_of_pos (show (0:ℝ) < 524288/531441 by norm_num)
    rw [show ((524288:ℝ)/531441) = ((531441:ℝ)/524288)⁻¹ by norm_num, Real.log_inv] at h
    rw [h12]; nlinarith [h]
  · have h := Real.log_le_sub_one_of_pos (show (0:ℝ) < 531441/524288 by norm_num)
    rw [h12]; nlinarith [h]

/-- The cap is `0.2157…` nats. -/
lemma orCap_bounds : 0.2157 < orCap ∧ orCap < 0.2158 := by
  obtain ⟨hlo, hhi⟩ := log_three_sandwich
  have h2 := Real.log_two_gt_d9
  have h2' := Real.log_two_lt_d9
  rw [orCap_eq]
  constructor <;> nlinarith

lemma orCap_gt : 0.213 < orCap := by linarith [orCap_bounds.1]

/-- In bits, the cap is `0.3113…`. -/
lemma orCap_bits_bounds : 0.3111 < orCap / Real.log 2 ∧ orCap / Real.log 2 < 0.3114 := by
  obtain ⟨hlo, hhi⟩ := orCap_bounds
  have h2 := Real.log_two_gt_d9
  have h2' := Real.log_two_lt_d9
  have hpos : 0 < Real.log 2 := by linarith
  constructor
  · rw [lt_div_iff₀ hpos]; nlinarith
  · rw [div_lt_iff₀ hpos]; nlinarith

/-- `binEntropy` written with the sign convention used below. -/
lemma binEntropy_eq' (x : ℝ) :
    Real.binEntropy x = -(x * Real.log x) - (1-x) * Real.log (1-x) := by
  simp [Real.binEntropy, Real.log_inv]; ring

/-- Chord bound: a concave function dominates its chords.  This is the inequality that
turns the window `[L,U]` for the conditional no-fork probabilities into a linear lower
bound for the conditional entropies. -/
lemma binEntropy_chord {L U x : ℝ} (hL : 0 ≤ L) (hU : U ≤ 1) (hLU : L < U)
    (hxL : L ≤ x) (hxU : x ≤ U) :
    ((U - x) * Real.binEntropy L + (x - L) * Real.binEntropy U) / (U - L)
      ≤ Real.binEntropy x := by
  have hd : 0 < U - L := by linarith
  have hmemL : L ∈ Set.Icc (0:ℝ) 1 := ⟨hL, by linarith⟩
  have hmemU : U ∈ Set.Icc (0:ℝ) 1 := ⟨by linarith, hU⟩
  have ha : 0 ≤ (U - x) / (U - L) := div_nonneg (by linarith) hd.le
  have hb : 0 ≤ (x - L) / (U - L) := div_nonneg (by linarith) hd.le
  have hab : (U - x) / (U - L) + (x - L) / (U - L) = 1 := by field_simp; ring
  have hcc := Real.strictConcave_binEntropy.concaveOn.2 hmemL hmemU ha hb hab
  simp only [smul_eq_mul] at hcc
  have hx : (U - x) / (U - L) * L + (x - L) / (U - L) * U = x := by field_simp; ring
  rw [hx] at hcc
  calc ((U - x) * Real.binEntropy L + (x - L) * Real.binEntropy U) / (U - L)
      = (U - x) / (U - L) * Real.binEntropy L + (x - L) / (U - L) * Real.binEntropy U := by
        field_simp
    _ ≤ Real.binEntropy x := hcc

/-- **Left branch of the variational bound.**  For a mean no-fork rate `μ ≤ 1/2`, the
window is `[0, μ]` and the chord bound gives `Φ ≤ H(μ²) - μ H(μ)`; this quantity never
exceeds the cap, with equality exactly at `μ = 1/2`. -/
lemma left_branch_strict (m : ℝ) (h0 : 0 < m) (h1 : m < 1/2) :
    Real.binEntropy (m^2) - m * Real.binEntropy m < orCap := by
  have hm1 : m < 1 := by linarith
  have hid : Real.binEntropy (m^2) - m * Real.binEntropy m
      = -(m^2 * Real.log m) - (1-m) * Real.log (1-m) - (1-m^2) * Real.log (1+m) := by
    rw [binEntropy_eq', binEntropy_eq', show (1:ℝ) - m^2 = (1-m)*(1+m) by ring,
      Real.log_mul (by linarith) (by linarith), Real.log_pow]
    push_cast; ring
  have hA : -(m^2 * Real.log m) ≤ m^2 * Real.log 2 - m^2 + m/2 := by
    have t := log_tangent (1/2) m (by norm_num) h0
    rw [log_half] at t
    nlinarith [mul_le_mul_of_nonneg_left t h0.le]
  rw [hid]
  rcases le_or_gt m (1/4) with hc | hc
  · -- small `μ`: crude tangent bounds at `a = 1` leave plenty of room
    have hB : -((1-m) * Real.log (1-m)) ≤ m := by
      have t := log_tangent 1 (1-m) one_pos (by linarith)
      rw [Real.log_one] at t; linarith
    have hC : -((1-m^2) * Real.log (1+m)) ≤ -(m*(1-m)) := by
      have t := log_tangent 1 (1+m) one_pos (by linarith)
      rw [Real.log_one] at t
      nlinarith [mul_le_mul_of_nonneg_left t (by linarith : (0:ℝ) ≤ 1-m)]
    have hcap := orCap_gt
    have h2 := Real.log_two_lt_d9
    nlinarith
  · -- `1/4 ≤ μ ≤ 1/2`: tangent bounds based at the extremal point
    have hB : -((1-m) * Real.log (1-m)) ≤ (1-m) * Real.log 2 - (1-m) + 1/2 := by
      have t := log_tangent (1/2) (1-m) (by norm_num) (by linarith)
      rw [log_half] at t; linarith
    have hC : -((1-m^2) * Real.log (1+m))
        ≤ -((1-m) * ((1+m) * (Real.log 3 - Real.log 2) + (1+m) - 3/2)) := by
      have t := log_tangent (3/2) (1+m) (by norm_num) (by linarith)
      rw [show Real.log (3/2) = Real.log 3 - Real.log 2 from
        Real.log_div (by norm_num) (by norm_num)] at t
      nlinarith [mul_le_mul_of_nonneg_left t (by linarith : (0:ℝ) ≤ 1-m)]
    have key : 0 < (1/2 - m) * (Real.log 3 * (m + 1/2) - Real.log 2) := by
      apply mul_pos (by linarith)
      nlinarith [log_three_gt, Real.log_two_gt_d9]
    rw [orCap_eq]
    nlinarith [hA, hB, hC, key]

/-- **Right branch of the variational bound.**  For a mean no-fork rate `μ ≥ 1/2`, the
pointwise bound `xy ≥ x + y - 1` gives the window `[2μ-1, μ]`, and the chord bound gives
`Φ ≤ H(μ²) - (μ H(2μ-1) + (1-μ) H(μ))`; again this never exceeds the cap, with equality
exactly at `μ = 1/2`. -/
lemma right_branch_strict (m : ℝ) (h0 : 1/2 < m) (h1 : m < 1) :
    Real.binEntropy (m^2) - (m * Real.binEntropy (2*m-1) + (1-m) * Real.binEntropy m)
      < orCap := by
  have hmpos : 0 < m := by linarith
  have hid : Real.binEntropy (m^2)
        - (m * Real.binEntropy (2*m-1) + (1-m) * Real.binEntropy m)
      = (m - 3*m^2) * Real.log m - (1-m^2) * Real.log (1+m)
        + m * (2*m-1) * Real.log (2*m-1) + 2*m*(1-m) * Real.log 2 := by
    rw [binEntropy_eq', binEntropy_eq', binEntropy_eq',
      show (1:ℝ) - (2*m-1) = 2*(1-m) by ring,
      Real.log_mul (by norm_num) (by linarith),
      show (1:ℝ) - m^2 = (1-m)*(1+m) by ring,
      Real.log_mul (by linarith) (by linarith), Real.log_pow]
    push_cast; ring
  have hD : m * (2*m-1) * Real.log (2*m-1) ≤ m * (2*m-1) * (2*m-2) := by
    have hlog := Real.log_le_sub_one_of_pos (show 0 < 2*m-1 by linarith)
    have hnn : 0 ≤ m * (2*m-1) := by nlinarith
    nlinarith [mul_le_mul_of_nonneg_left hlog hnn]
  have hC : -((1-m^2) * Real.log (1+m))
      ≤ -((1-m) * ((1+m) * (Real.log 3 - Real.log 2) + (1+m) - 3/2)) := by
    have t := log_tangent (3/2) (1+m) (by norm_num) (by linarith)
    rw [show Real.log (3/2) = Real.log 3 - Real.log 2 from
      Real.log_div (by norm_num) (by norm_num)] at t
    nlinarith [mul_le_mul_of_nonneg_left t (by linarith : (0:ℝ) ≤ 1-m)]
  rw [hid]
  rcases le_or_gt m (4/5) with hc | hc
  · -- `1/2 ≤ μ ≤ 4/5`: tangent bounds based at the extremal point
    have hA : (m - 3*m^2) * Real.log m ≤ -((3*m-1) * (-(m * Real.log 2) + m - 1/2)) := by
      have t := log_tangent (1/2) m (by norm_num) hmpos
      rw [log_half] at t
      nlinarith [mul_le_mul_of_nonneg_left t (by linarith : (0:ℝ) ≤ 3*m-1)]
    have hQ : 0 < -(Real.log 2/2) - Real.log 3 * m/2 - Real.log 3/4 - 2*m^2 + 3*m := by
      have h2 := Real.log_two_lt_d9
      have h3 := log_three_le
      nlinarith [mul_nonneg (by linarith : (0:ℝ) ≤ m - 1/2) (by linarith : (0:ℝ) ≤ 4/5 - m)]
    have key : 0 < (2*m-1) * (-(Real.log 2/2) - Real.log 3 * m/2 - Real.log 3/4 - 2*m^2 + 3*m) :=
      mul_pos (by linarith) hQ
    rw [orCap_eq]
    nlinarith [hA, hC, hD, key]
  · -- `4/5 ≤ μ < 1`: the bound collapses to `(1-μ)²(4μ - log 2) ≤ 4/25`
    have hA : (m - 3*m^2) * Real.log m ≤ (3*m-1)*(1-m) := by
      have t := log_tangent 1 m one_pos hmpos
      rw [Real.log_one] at t
      nlinarith [mul_le_mul_of_nonneg_left t (by linarith : (0:ℝ) ≤ 3*m-1)]
    have hC2 : -((1-m^2) * Real.log (1+m)) ≤ -((1-m) * ((1+m) * Real.log 2 + m - 1)) := by
      have t := log_tangent 2 (1+m) (by norm_num) (by linarith)
      nlinarith [mul_le_mul_of_nonneg_left t (by linarith : (0:ℝ) ≤ 1-m)]
    have hfin : (3*m-1)*(1-m) - ((1-m) * ((1+m) * Real.log 2 + m - 1))
        + m * (2*m-1) * (2*m-2) + 2*m*(1-m) * Real.log 2 = (1-m)^2 * (4*m - Real.log 2) := by
      ring
    have hcap := orCap_gt
    have h2 := Real.log_two_gt_d9
    have hbnd : (1-m)^2 * (4*m - Real.log 2) ≤ 4/25 := by
      have h1' : (1-m)^2 ≤ 1/25 := by nlinarith
      nlinarith [sq_nonneg (1-m)]
    linarith [hA, hC2, hD, hbnd, hfin.le, hfin.ge]

lemma binEntropy_half : Real.binEntropy ((1:ℝ)/2) = Real.log 2 := by
  rw [show (1:ℝ)/2 = 2⁻¹ by norm_num]; exact Real.binEntropy_two_inv

/-- The left branch is *tight* at `μ = 1/2`: this is the quadratic-character value. -/
lemma left_branch_at_half :
    Real.binEntropy (((1:ℝ)/2)^2) - (1/2) * Real.binEntropy ((1:ℝ)/2) = orCap := by
  rw [binEntropy_half, orCap]
  norm_num
  ring

/-- The right branch is tight at `μ = 1/2` as well (the two windows agree there). -/
lemma right_branch_at_half :
    Real.binEntropy (((1:ℝ)/2)^2)
      - ((1/2) * Real.binEntropy (2*(1/2)-1) + (1-1/2) * Real.binEntropy ((1:ℝ)/2)) = orCap := by
  rw [binEntropy_half, orCap]
  norm_num
  ring

lemma left_branch (m : ℝ) (h0 : 0 < m) (h1 : m ≤ 1/2) :
    Real.binEntropy (m^2) - m * Real.binEntropy m ≤ orCap := by
  rcases eq_or_lt_of_le h1 with he | hlt
  · rw [he]; exact le_of_eq left_branch_at_half
  · exact (left_branch_strict m h0 hlt).le

lemma right_branch (m : ℝ) (h0 : 1/2 ≤ m) (h1 : m < 1) :
    Real.binEntropy (m^2) - (m * Real.binEntropy (2*m-1) + (1-m) * Real.binEntropy m)
      ≤ orCap := by
  rcases eq_or_lt_of_le h0 with he | hlt
  · rw [← he]; exact le_of_eq right_branch_at_half
  · exact (right_branch_strict m hlt h1).le

end ORDial