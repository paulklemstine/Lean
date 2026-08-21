import Mathlib
import Catalog.Shared.HigherPythagorean.LorentzCore
import Catalog.Shared.HigherPythagorean.HyperbolicBoundary

/-!
# The metric growth exponent of the higher-dimensional Pythagorean trees

The catalog proves that one reflection move on the null cone of the `(n+1)`-dimensional
Lorentz form multiplies the height by at most `ρₙ = (√n+1)/(√n−1)`
(`HigherPythagorean.lorentz_move_height_bound`), that the bound is attained for `n = 3`
(`HigherPythagorean.quad_growth_bound_sharp`) and that `ρₙ` is algebraic of degree ≤ 2
(`HigherPythagorean.growth_const_quadratic`).

This file determines the arithmetic and asymptotics of `ρₙ` and the resulting **critical
growth exponent** of the trees.

Main results.

* `growth_two`, `growth_three` : the closed forms `ρ₂ = 3 + 2√2 = (1+√2)²` (silver ratio
  squared) and `ρ₃ = 2 + √3`.
* `growth_three_isUnit`, `growth_two_isUnit` : both constants are units of norm one in the
  real quadratic orders `ℤ[√3]`, `ℤ[√2]`.
* `growth_three_minimal` : `2 + √3` is the *smallest* unit `> 1` of `ℤ[√3]` with positive
  coordinates — the fundamental unit; so `log ρ₃` is the exact analogue of the silver-ratio
  exponent `log(1+√2)`.
* `growth_strictAnti` : `ρₙ` strictly decreases in `n`, and `growth_tendsto_one` : `ρₙ → 1`.
  Higher dimensions move *slower* per reflection.
* `criticalExponent_three_gt_two` : the critical exponent
  `δₙ = log(branching)/log ρₙ` satisfies `δ₂ < 1 < δ₃`.  Even though each move is slower,
  the extra branching wins: the quadruple tree has strictly larger metric growth exponent
  than the Berggren tree.
-/

namespace HigherPythagoreanGrowth

open Real

/-- The sharp one-step growth constant of the `n`-dimensional reflection move. -/
noncomputable def growth (n : ℕ) : ℝ := (Real.sqrt n + 1) / (Real.sqrt n - 1)

lemma one_lt_sqrt_of_two_le {n : ℕ} (hn : 2 ≤ n) : 1 < Real.sqrt n := by
  have hn2 : (2 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have h1 : Real.sqrt 1 < Real.sqrt n := by
    apply Real.sqrt_lt_sqrt (by norm_num)
    linarith
  simpa using h1

/-- Dimension two: `ρ₂ = 3 + 2√2`, the square of the silver ratio. -/
theorem growth_two : growth 2 = 3 + 2 * Real.sqrt 2 ∧ growth 2 = (1 + Real.sqrt 2) ^ 2 := by
  have h2 : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  have h1 : 1 < Real.sqrt 2 := one_lt_sqrt_of_two_le (n := 2) le_rfl
  have hne : Real.sqrt 2 - 1 ≠ 0 := by intro h; nlinarith
  have hmain : growth 2 = 3 + 2 * Real.sqrt 2 := by
    unfold growth
    rw [div_eq_iff (by simpa using hne)]
    push_cast
    nlinarith [h2]
  exact ⟨hmain, by rw [hmain]; nlinarith [h2]⟩

/-- Dimension three: `ρ₃ = 2 + √3`. -/
theorem growth_three : growth 3 = 2 + Real.sqrt 3 := by
  have h3 : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  have h1 : 1 < Real.sqrt 3 := one_lt_sqrt_of_two_le (n := 3) (by norm_num)
  have hne : Real.sqrt 3 - 1 ≠ 0 := by intro h; nlinarith
  unfold growth
  rw [div_eq_iff (by simpa using hne)]
  push_cast
  nlinarith [h3]

/-! ## Arithmetic: the growth constants are quadratic units -/

/-- `2 + √3` is a unit of norm one of the real quadratic order `ℤ[√3]`. -/
theorem growth_three_isUnit : (2 + Real.sqrt 3) * (2 - Real.sqrt 3) = 1 := by
  have h3 : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  nlinarith [h3]

/-- `3 + 2√2` is a unit of norm one of `ℤ[√2]`. -/
theorem growth_two_isUnit : (3 + 2 * Real.sqrt 2) * (3 - 2 * Real.sqrt 2) = 1 := by
  have h2 : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  nlinarith [h2]

/-- **`2 + √3` is the fundamental unit of `ℤ[√3]`**: every unit `a + b√3 > 1` of norm one is
at least `2 + √3`.  Hence `log ρ₃ = log(2+√3)` is the exact dimension-three analogue of the
silver-ratio exponent `log(1+√2)`. -/
theorem growth_three_minimal {a b : ℤ} (hnorm : a ^ 2 - 3 * b ^ 2 = 1)
    (hu : 1 < (a : ℝ) + (b : ℝ) * Real.sqrt 3) :
    2 + Real.sqrt 3 ≤ (a : ℝ) + (b : ℝ) * Real.sqrt 3 := by
  have h3 : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  have hs : 1 < Real.sqrt 3 := one_lt_sqrt_of_two_le (n := 3) (by norm_num)
  set u : ℝ := (a : ℝ) + (b : ℝ) * Real.sqrt 3 with hudef
  set v : ℝ := (a : ℝ) - (b : ℝ) * Real.sqrt 3 with hvdef
  have hnorm' : ((a : ℝ) ^ 2 - 3 * (b : ℝ) ^ 2) = 1 := by exact_mod_cast hnorm
  have hprod : u * v = 1 := by rw [hudef, hvdef]; nlinarith [h3]
  have hv : 0 < v ∧ v < 1 := by
    constructor <;> nlinarith
  have hasum : u + v = 2 * (a : ℝ) := by rw [hudef, hvdef]; ring
  have hbsum : u - v = 2 * (b : ℝ) * Real.sqrt 3 := by rw [hudef, hvdef]; ring
  have ha1 : 1 ≤ a := by
    have hpos : (0 : ℝ) < (a : ℝ) := by linarith [hv.1]
    have : 0 < a := by exact_mod_cast hpos
    omega
  have hb1 : 1 ≤ b := by
    have hpos : (0 : ℝ) < (b : ℝ) := by nlinarith [hv.2]
    have : 0 < b := by exact_mod_cast hpos
    omega
  have ha2 : 2 ≤ a := by nlinarith
  have ha' : (2 : ℝ) ≤ (a : ℝ) := by exact_mod_cast ha2
  have hb' : (1 : ℝ) ≤ (b : ℝ) := by exact_mod_cast hb1
  rw [hudef]
  nlinarith

/-- **`1 + √2` is the fundamental unit of `ℤ[√2]`**, and `ρ₂` is its square: every unit
`a + b√2 > 1` of norm `±1` is at least `1 + √2`. -/
theorem growth_two_minimal {a b : ℤ} (hnorm : a ^ 2 - 2 * b ^ 2 = 1 ∨ a ^ 2 - 2 * b ^ 2 = -1)
    (hu : 1 < (a : ℝ) + (b : ℝ) * Real.sqrt 2) :
    1 + Real.sqrt 2 ≤ (a : ℝ) + (b : ℝ) * Real.sqrt 2 := by
  have h2 : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  have hs : 1 < Real.sqrt 2 := one_lt_sqrt_of_two_le (n := 2) le_rfl
  set u : ℝ := (a : ℝ) + (b : ℝ) * Real.sqrt 2 with hudef
  set v : ℝ := (a : ℝ) - (b : ℝ) * Real.sqrt 2 with hvdef
  have hprod : u * v = ((a : ℝ) ^ 2 - 2 * (b : ℝ) ^ 2) := by
    rw [hudef, hvdef]; nlinarith [h2]
  have hnorm' : ((a : ℝ) ^ 2 - 2 * (b : ℝ) ^ 2) = 1 ∨ ((a : ℝ) ^ 2 - 2 * (b : ℝ) ^ 2) = -1 := by
    rcases hnorm with h | h
    · left; exact_mod_cast h
    · right; exact_mod_cast h
  have hv : -1 < v ∧ v < 1 := by
    rcases hnorm' with h | h <;> rw [h] at hprod
    · constructor
      · nlinarith
      · nlinarith
    · constructor
      · nlinarith
      · nlinarith
  have hapos : (0 : ℝ) < 2 * (a : ℝ) := by
    have : u + v = 2 * (a : ℝ) := by rw [hudef, hvdef]; ring
    linarith [hv.1]
  have hbpos : (0 : ℝ) < 2 * (b : ℝ) * Real.sqrt 2 := by
    have : u - v = 2 * (b : ℝ) * Real.sqrt 2 := by rw [hudef, hvdef]; ring
    linarith [hv.2]
  have ha1 : 1 ≤ a := by
    have : (0 : ℝ) < (a : ℝ) := by linarith
    have : 0 < a := by exact_mod_cast this
    omega
  have hb1 : 1 ≤ b := by
    have hpos : (0 : ℝ) < (b : ℝ) := by nlinarith
    have : 0 < b := by exact_mod_cast hpos
    omega
  have ha' : (1 : ℝ) ≤ (a : ℝ) := by exact_mod_cast ha1
  have hb' : (1 : ℝ) ≤ (b : ℝ) := by exact_mod_cast hb1
  rw [hudef]
  nlinarith

/-! ## Asymptotics of the growth constant -/

lemma growth_eq_one_add {n : ℕ} (hn : 2 ≤ n) : growth n = 1 + 2 / (Real.sqrt n - 1) := by
  have h1 : 1 < Real.sqrt n := one_lt_sqrt_of_two_le hn
  have hne : Real.sqrt n - 1 ≠ 0 := by intro h; nlinarith
  unfold growth
  field_simp
  ring

lemma one_lt_growth {n : ℕ} (hn : 2 ≤ n) : 1 < growth n := by
  have h1 : 1 < Real.sqrt n := one_lt_sqrt_of_two_le hn
  rw [growth_eq_one_add hn]
  have h0 : 0 < Real.sqrt n - 1 := by linarith
  have : 0 < 2 / (Real.sqrt n - 1) := by positivity
  linarith

/-- **The growth constant strictly decreases with the dimension.** -/
theorem growth_strictAnti {m n : ℕ} (hm : 2 ≤ m) (hmn : m < n) : growth n < growth m := by
  have hn : 2 ≤ n := le_trans hm hmn.le
  have hs : Real.sqrt m < Real.sqrt n := by
    apply Real.sqrt_lt_sqrt (by positivity)
    exact_mod_cast hmn
  have h1 : 1 < Real.sqrt m := one_lt_sqrt_of_two_le hm
  rw [growth_eq_one_add hm, growth_eq_one_add hn]
  have hlt : 2 / (Real.sqrt n - 1) < 2 / (Real.sqrt m - 1) := by
    apply div_lt_div_of_pos_left (by norm_num) (by linarith)
    linarith
  linarith

/-- **The growth constant tends to `1`**: in high dimension a single reflection barely moves
the point in the hyperbolic metric. -/
theorem growth_tendsto_one :
    Filter.Tendsto growth Filter.atTop (nhds 1) := by
  have hsqrt : Filter.Tendsto (fun n : ℕ => Real.sqrt n - 1) Filter.atTop Filter.atTop := by
    apply Filter.tendsto_atTop_add_const_right
    exact Real.tendsto_sqrt_atTop.comp tendsto_natCast_atTop_atTop
  have hdiv : Filter.Tendsto (fun n : ℕ => 2 / (Real.sqrt n - 1)) Filter.atTop (nhds 0) :=
    Filter.Tendsto.div_atTop tendsto_const_nhds hsqrt
  have hlim : Filter.Tendsto (fun n : ℕ => 1 + 2 / (Real.sqrt n - 1)) Filter.atTop
      (nhds (1 + 0)) := tendsto_const_nhds.add hdiv
  rw [add_zero] at hlim
  refine hlim.congr' ?_
  filter_upwards [Filter.eventually_ge_atTop 2] with n hn
  exact (growth_eq_one_add hn).symm

/-! ## The critical growth exponent -/

/-- The critical exponent of a tree with `k` children per node whose one-step metric growth
constant is `ρ`: the exponent `δ` with `k = ρ^δ`. -/
noncomputable def criticalExponent (k rho : ℝ) : ℝ := Real.log k / Real.log rho

/-- Dimension two (Berggren, ternary tree): the critical exponent is `< 1`. -/
theorem criticalExponent_two_lt_one : criticalExponent 3 (growth 2) < 1 := by
  have h2 : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  have hs : 1 < Real.sqrt 2 := one_lt_sqrt_of_two_le (n := 2) le_rfl
  have hg : growth 2 = 3 + 2 * Real.sqrt 2 := growth_two.1
  have hlt : (3 : ℝ) < growth 2 := by rw [hg]; nlinarith
  have hlog3 : 0 < Real.log 3 := Real.log_pos (by norm_num)
  have hloglt : Real.log 3 < Real.log (growth 2) := Real.log_lt_log (by norm_num) hlt
  unfold criticalExponent
  rw [div_lt_one (by linarith)]
  exact hloglt

/-- Dimension three (quadruple graph, at least six children): the critical exponent is `> 1`. -/
theorem criticalExponent_three_gt_one : 1 < criticalExponent 6 (growth 3) := by
  have h3 : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  have hs : 1 < Real.sqrt 3 := one_lt_sqrt_of_two_le (n := 3) (by norm_num)
  have hs2 : Real.sqrt 3 < 2 := by nlinarith
  have hg : growth 3 = 2 + Real.sqrt 3 := growth_three
  have hlt : growth 3 < 6 := by rw [hg]; linarith
  have hg1 : 1 < growth 3 := one_lt_growth (n := 3) (by norm_num)
  have hlogpos : 0 < Real.log (growth 3) := Real.log_pos hg1
  have hloglt : Real.log (growth 3) < Real.log 6 := Real.log_lt_log (by linarith) hlt
  unfold criticalExponent
  rw [lt_div_iff₀ hlogpos]
  linarith

/-- **The quadruple tree grows faster than the Berggren tree.**  Its critical exponent
strictly exceeds the Berggren one: the loss in per-move hyperbolic displacement
(`2+√3 < 3+2√2`) is more than compensated by the jump in branching (`6 > 3`). -/
theorem criticalExponent_three_gt_two :
    criticalExponent 3 (growth 2) < criticalExponent 6 (growth 3) :=
  lt_trans criticalExponent_two_lt_one criticalExponent_three_gt_one

end HigherPythagoreanGrowth