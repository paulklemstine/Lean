import Mathlib

/-!
# Elementary Structure of Pillai Equations

This file develops reusable facts about equations of the form
`x ^ a = y ^ b + k`.  It proves divisibility and coprimality constraints,
shows how composite exponents reduce to smaller exponents, and gives an
exact classification of the small square-cube search region
`1 ≤ k ≤ 10`, `2 ≤ x,y ≤ 20`.
-/

namespace PillaiEquations

/-- `PillaiSolution k x y a b` means that the two perfect powers differ by
exactly `k`, with the power of `x` the larger one. -/
def PillaiSolution (k x y a b : ℕ) : Prop :=
  x ^ a = y ^ b + k

/-- Every common divisor of the two bases divides the gap between their
positive powers. -/
theorem common_divisor_dvd_gap {k x y a b d : ℕ}
    (ha : 0 < a) (hb : 0 < b) (h : PillaiSolution k x y a b)
    (hdx : d ∣ x) (hdy : d ∣ y) : d ∣ k := by
  have hdxp : d ∣ x ^ a := dvd_pow hdx (by omega)
  have hdyp : d ∣ y ^ b := dvd_pow hdy (by omega)
  rw [h] at hdxp
  exact (Nat.dvd_add_iff_right hdyp).mpr hdxp

/-- The gcd of the bases in a positive-exponent Pillai equation divides its
gap. -/
theorem gcd_dvd_gap {k x y a b : ℕ}
    (ha : 0 < a) (hb : 0 < b) (h : PillaiSolution k x y a b) :
    x.gcd y ∣ k := by
  exact common_divisor_dvd_gap ha hb h
    (Nat.gcd_dvd_left x y) (Nat.gcd_dvd_right x y)

/-- Bases of consecutive positive perfect powers are coprime. -/
theorem consecutive_power_bases_coprime {x y a b : ℕ}
    (ha : 0 < a) (hb : 0 < b) (h : PillaiSolution 1 x y a b) :
    Nat.Coprime x y := by
  rw [Nat.coprime_iff_gcd_eq_one]
  exact Nat.eq_one_of_dvd_one (gcd_dvd_gap ha hb h)

/-- Multiplicatively composite exponents can be absorbed into the bases,
producing a reduced Pillai equation. -/
theorem reduce_composite_exponents {k x y a b m n : ℕ}
    (h : PillaiSolution k x y (a * m) (b * n)) :
    PillaiSolution k (x ^ a) (y ^ b) m n := by
  simpa [PillaiSolution, pow_mul] using h

/-- The classical pair `3²` and `2³` is a solution with gap one. -/
theorem catalan_witness : PillaiSolution 1 3 2 2 3 := by
  norm_num [PillaiSolution]

/-- In the box `2 ≤ x,y ≤ 20`, the only square and cube differing by one are
`3²` and `2³`. -/
theorem bounded_catalan_square_cube {x y : ℕ}
    (hx : 2 ≤ x) (hX : x ≤ 20)
    (hy : 2 ≤ y) (hY : y ≤ 20)
    (h : PillaiSolution 1 x y 2 3) :
    x = 3 ∧ y = 2 := by
  unfold PillaiSolution at h
  interval_cases x <;> interval_cases y <;> norm_num at h
  all_goals omega

/-- Exact classification of all square-cube equations in the box
`1 ≤ k ≤ 10`, `2 ≤ x,y ≤ 20`.  Only gaps `1`, `8`, and `9` occur, with the
four displayed solutions. -/
theorem small_square_cube_gap_classification {k x y : ℕ}
    (hk : 1 ≤ k) (hK : k ≤ 10)
    (hx : 2 ≤ x) (hX : x ≤ 20)
    (hy : 2 ≤ y) (hY : y ≤ 20)
    (h : PillaiSolution k x y 2 3) :
    (k = 1 ∧ x = 3 ∧ y = 2) ∨
    (k = 8 ∧ x = 4 ∧ y = 2) ∨
    (k = 9 ∧ x = 6 ∧ y = 3) ∨
    (k = 9 ∧ x = 15 ∧ y = 6) := by
  unfold PillaiSolution at h
  interval_cases k <;> interval_cases x <;> interval_cases y <;> norm_num at h
  all_goals norm_num

/-- There is no square-cube solution with gap two in the box
`2 ≤ x,y ≤ 20`. -/
theorem no_gap_two_square_cube_in_box {x y : ℕ}
    (hx : 2 ≤ x) (hX : x ≤ 20)
    (hy : 2 ≤ y) (hY : y ≤ 20) :
    ¬ PillaiSolution 2 x y 2 3 := by
  intro h
  have hc := small_square_cube_gap_classification
    (k := 2) (x := x) (y := y) (by norm_num) (by norm_num) hx hX hy hY h
  rcases hc with hc | hc | hc | hc <;> omega

/-- There is no square-cube solution with gap three in the box
`2 ≤ x,y ≤ 20`. -/
theorem no_gap_three_square_cube_in_box {x y : ℕ}
    (hx : 2 ≤ x) (hX : x ≤ 20)
    (hy : 2 ≤ y) (hY : y ≤ 20) :
    ¬ PillaiSolution 3 x y 2 3 := by
  intro h
  have hc := small_square_cube_gap_classification
    (k := 3) (x := x) (y := y) (by norm_num) (by norm_num) hx hX hy hY h
  rcases hc with hc | hc | hc | hc <;> omega

end PillaiEquations