import MachineLearning.BerggrenUnitLocus

/-!
# Binet formula for the Berggren spine: the eigenvalue is the growth rate

This is the analytic complement to `MachineLearning.BerggrenUnitLocus`.  The hypotenuses
`c_n` of the all-`B` spine satisfy the Pell recursion `c_{n+2} = 6c_{n+1} − c_n`, whose
reciprocal Euler factor `1 − 6X + X²` has roots the hyperbolic eigenvalues `3 ± 2√2`.
Here we solve the recursion in closed form and read off the arithmetic consequences.

* `spine_binet` : `c_n = A λ^n + |B| λ'^n` with `λ = 3 + 2√2`, `λ' = 3 − 2√2`,
  `A = (7 + 5√2)/(2√2)`, `B = (7 − 5√2)/(2√2)`.
* `spine_nearest_integer` : since `0 < −B λ'^n < 1/2`, the hypotenuse `c_n` is the nearest
  integer to `A λ^n`; the spectral eigenvalue of the hyperbolic Berggren generator is
  literally the growth constant of the spine.
* `spine_ratio_tendsto_lambda` : `c_{n+1}/c_n → 3 + 2√2`.

Together with `BerggrenStars.Silver.spine_ratio_tendsto` (the *direction* converges to
`√2`) this pins down both the boundary point of the axis and the translation length of the
hyperbolic generator.
-/

namespace BerggrenStars

namespace Binet

open Silver UnitLocus

/-- The attracting eigenvalue `λ = 3 + 2√2`. -/
noncomputable def lamR : ℝ := 3 + 2 * Real.sqrt 2

/-- The repelling eigenvalue `λ' = 3 − 2√2`. -/
noncomputable def lamR' : ℝ := 3 - 2 * Real.sqrt 2

theorem sqrt2_bounds : 1.414 < Real.sqrt 2 ∧ Real.sqrt 2 < 1.4143 := by
  constructor
  · have h : Real.sqrt (1.414 ^ 2) < Real.sqrt 2 := by
      apply Real.sqrt_lt_sqrt <;> norm_num
    rwa [Real.sqrt_sq (by norm_num)] at h
  · have h : Real.sqrt 2 < Real.sqrt (1.4143 ^ 2) := by
      apply Real.sqrt_lt_sqrt <;> norm_num
    rwa [Real.sqrt_sq (by norm_num)] at h

theorem sqrt2_sq : Real.sqrt 2 * Real.sqrt 2 = 2 := Real.mul_self_sqrt (by norm_num)

theorem lamR_root : lamR ^ 2 = 6 * lamR - 1 := by
  simp only [lamR]
  nlinarith [sqrt2_sq]

theorem lamR'_root : lamR' ^ 2 = 6 * lamR' - 1 := by
  simp only [lamR']
  nlinarith [sqrt2_sq]

theorem lamR_pos : 5 < lamR := by
  have h := sqrt2_bounds.1
  simp only [lamR]; linarith

theorem lamR'_bounds : 0 < lamR' ∧ lamR' < 1 / 5 := by
  obtain ⟨h1, h2⟩ := sqrt2_bounds
  simp only [lamR']
  constructor <;> linarith

/-- The Binet coefficient of the attracting eigenvalue. -/
noncomputable def coA : ℝ := (7 + 5 * Real.sqrt 2) / (2 * Real.sqrt 2)

/-- The Binet coefficient of the repelling eigenvalue (it is negative and tiny). -/
noncomputable def coB : ℝ := (7 - 5 * Real.sqrt 2) / (2 * Real.sqrt 2)

theorem coA_sub_coB : coA - coB = 5 := by
  have hs := sqrt2_sq
  have hpos : Real.sqrt 2 > 0 := Real.sqrt_pos.mpr (by norm_num)
  simp only [coA, coB]
  field_simp
  nlinarith [hs]

theorem coA_mul_lamR_sub : coA * lamR - coB * lamR' = 29 := by
  have hs := sqrt2_sq
  have hpos : Real.sqrt 2 > 0 := Real.sqrt_pos.mpr (by norm_num)
  simp only [coA, coB, lamR, lamR']
  field_simp
  nlinarith [hs]

/-- **Binet formula for the Berggren spine.** -/
theorem spine_binet (n : ℕ) :
    (((spine n).2.2 : ℤ) : ℝ) = coA * lamR ^ n - coB * lamR' ^ n := by
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    match n with
    | 0 => simpa using coA_sub_coB.symm
    | 1 =>
        have : ((spine 1).2.2 : ℤ) = 29 := by decide
        rw [this]
        simpa using coA_mul_lamR_sub.symm
    | (k + 2) =>
        have hrec := spine_hyp_recursion k
        have h1 := ih (k + 1) (by omega)
        have h0 := ih k (by omega)
        have hcast : (((spine (k + 2)).2.2 : ℤ) : ℝ)
            = 6 * (((spine (k + 1)).2.2 : ℤ) : ℝ) - (((spine k).2.2 : ℤ) : ℝ) := by
          rw [hrec]; push_cast; ring
        rw [hcast, h1, h0]
        have e1 : lamR ^ (k + 2) = 6 * lamR ^ (k + 1) - lamR ^ k := by
          have : lamR ^ (k + 2) = lamR ^ k * lamR ^ 2 := by ring
          rw [this, lamR_root]; ring
        have e2 : lamR' ^ (k + 2) = 6 * lamR' ^ (k + 1) - lamR' ^ k := by
          have : lamR' ^ (k + 2) = lamR' ^ k * lamR' ^ 2 := by ring
          rw [this, lamR'_root]; ring
        rw [e1, e2]; ring

theorem coB_neg : -1 / 2 < coB ∧ coB < 0 := by
  obtain ⟨h1, h2⟩ := sqrt2_bounds
  have hpos : (0 : ℝ) < 2 * Real.sqrt 2 := by linarith
  simp only [coB]
  refine ⟨?_, div_neg_of_neg_of_pos (by linarith) hpos⟩
  rw [lt_div_iff₀ hpos]
  linarith

/-- **The hypotenuse is the nearest integer to `A λⁿ`.**  The correction term
`−B λ'ⁿ` lies strictly between `0` and `1/2`, so the spectral eigenvalue `λ = 3 + 2√2` of
the hyperbolic Berggren generator is exactly the growth constant of the spine. -/
theorem spine_nearest_integer (n : ℕ) :
    coA * lamR ^ n < (((spine n).2.2 : ℤ) : ℝ) ∧
      (((spine n).2.2 : ℤ) : ℝ) < coA * lamR ^ n + 1 / 2 := by
  obtain ⟨hB1, hB2⟩ := coB_neg
  obtain ⟨hp, hlt⟩ := lamR'_bounds
  have hpow : 0 < lamR' ^ n := pow_pos hp n
  have hpow1 : lamR' ^ n ≤ 1 := by
    apply pow_le_one₀ (le_of_lt hp)
    linarith
  rw [spine_binet n]
  constructor
  · nlinarith [hpow, hB2]
  · nlinarith [hpow, hB1, hpow1]

theorem spine_hyp_pos_real (n : ℕ) : 0 < (((spine n).2.2 : ℤ) : ℝ) := by
  exact_mod_cast (spine_pos n).2.2

/-- **The eigenvalue is the growth rate**: consecutive hypotenuses of the spine have ratio
tending to `3 + 2√2`. -/
theorem spine_ratio_tendsto_lambda :
    Filter.Tendsto
      (fun n => (((spine (n + 1)).2.2 : ℤ) : ℝ) / (((spine n).2.2 : ℤ) : ℝ))
      Filter.atTop (nhds lamR) := by
  obtain ⟨hB1, hB2⟩ := coB_neg
  obtain ⟨hp, hlt⟩ := lamR'_bounds
  have hA : 0 < coA := by
    obtain ⟨h1, h2⟩ := sqrt2_bounds
    have hpos : (0 : ℝ) < 2 * Real.sqrt 2 := by linarith
    apply div_pos (by linarith) hpos
  have hlam : (0 : ℝ) < lamR := by have := lamR_pos; linarith
  -- write the ratio as `λ · (A − B r^{n+1}) / (A − B r^n)` with `r = λ'/λ ∈ (0,1)`
  set r : ℝ := lamR' / lamR with hr
  have hr0 : 0 < r := div_pos hp hlam
  have hr1 : r < 1 := by
    rw [hr, div_lt_one hlam]
    have := lamR_pos
    linarith
  have hrpow : Filter.Tendsto (fun n => r ^ n) Filter.atTop (nhds 0) :=
    tendsto_pow_atTop_nhds_zero_of_lt_one (le_of_lt hr0) hr1
  have hden : ∀ n : ℕ, coA - coB * r ^ n ≠ 0 := by
    intro n
    have hrp : 0 < r ^ n := pow_pos hr0 n
    nlinarith [hA, hB2, hrp]
  have hkey : ∀ n : ℕ,
      (((spine (n + 1)).2.2 : ℤ) : ℝ) / (((spine n).2.2 : ℤ) : ℝ)
        = lamR * ((coA - coB * r ^ (n + 1)) / (coA - coB * r ^ n)) := by
    intro n
    have hlamn : (0 : ℝ) < lamR ^ n := pow_pos hlam n
    have hb1 : (((spine (n + 1)).2.2 : ℤ) : ℝ) = coA * lamR ^ (n + 1) - coB * lamR' ^ (n + 1) :=
      spine_binet (n + 1)
    have hb0 : (((spine n).2.2 : ℤ) : ℝ) = coA * lamR ^ n - coB * lamR' ^ n := spine_binet n
    have hrn : lamR' ^ n = r ^ n * lamR ^ n := by
      rw [hr, div_pow]
      field_simp
    have hrn1 : lamR' ^ (n + 1) = r ^ (n + 1) * lamR ^ (n + 1) := by
      rw [hr, div_pow]
      field_simp
    rw [hb1, hb0, hrn, hrn1]
    have hne : coA * lamR ^ n - coB * (r ^ n * lamR ^ n) ≠ 0 := by
      have := hden n
      intro hc
      apply this
      have : (coA - coB * r ^ n) * lamR ^ n = 0 := by linarith [hc]
      rcases mul_eq_zero.mp this with h | h
      · exact h
      · exact absurd h (ne_of_gt hlamn)
    field_simp
    ring
  simp only [hkey]
  have hnum : Filter.Tendsto (fun n : ℕ => coA - coB * r ^ (n + 1)) Filter.atTop (nhds coA) := by
    have : Filter.Tendsto (fun n : ℕ => r ^ (n + 1)) Filter.atTop (nhds 0) := by
      simpa [pow_succ] using hrpow.mul_const r
    simpa using (tendsto_const_nhds (x := coA) (f := Filter.atTop (α := ℕ))).sub
      (this.const_mul coB)
  have hden' : Filter.Tendsto (fun n : ℕ => coA - coB * r ^ n) Filter.atTop (nhds coA) := by
    simpa using (tendsto_const_nhds (x := coA) (f := Filter.atTop (α := ℕ))).sub
      (hrpow.const_mul coB)
  have := (hnum.div hden' (ne_of_gt hA))
  simpa [div_self (ne_of_gt hA)] using this.const_mul lamR

end Binet

end BerggrenStars