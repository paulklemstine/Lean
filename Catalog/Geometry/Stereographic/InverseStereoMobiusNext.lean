import Mathlib

/-! # CatalogBuild.Geometry.Stereographic.InverseStereoMobiusNext

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 32
-/


noncomputable section

/-- The denominator of F_{a,b}(n). -/
def twoPole_den (a b n : ℤ) : ℤ := (a - b) * n + (a * b + 1)




/-- The numerator of F_{a,b}(n). -/
def twoPole_num (a b n : ℤ) : ℤ := (a * b + 1) * n + (b - a)




/-- The determinant (1+a²)(1+b²). -/
def twoPole_det (a b : ℤ) : ℤ := (1 + a ^ 2) * (1 + b ^ 2)




/-- **Complete Criterion, Forward**: If d | num then d | det.
This is Theorem Γ.1 restated with our definitions. -/
theorem complete_criterion_forward (a b n : ℤ) :
    twoPole_den a b n ∣ twoPole_num a b n →
    twoPole_den a b n ∣ twoPole_det a b := by
  intro h
  unfold twoPole_den twoPole_num twoPole_det at *
  have : (b - a) * ((a * b + 1) * n + (b - a)) +
    (a * b + 1) * ((a - b) * n + (a * b + 1)) =
    (1 + a ^ 2) * (1 + b ^ 2) := by ring
  rw [← this]
  exact dvd_add (h.mul_left (b - a)) (dvd_mul_left _ _)




/-- **Complete Criterion, Backward**: If d | det then d | (b-a)·num.
Combined with coprimality conditions, this gives sufficiency. -/
theorem complete_criterion_backward (a b n : ℤ) :
    twoPole_den a b n ∣ twoPole_det a b →
    twoPole_den a b n ∣ (b - a) * twoPole_num a b n := by
  intro h
  unfold twoPole_den twoPole_num twoPole_det at *
  have key : (b - a) * ((a * b + 1) * n + (b - a)) =
    (1 + a ^ 2) * (1 + b ^ 2) - (a * b + 1) * ((a - b) * n + (a * b + 1)) := by ring
  rw [key]
  exact dvd_sub h (dvd_mul_left _ _)




/-- **Denominator-numerator identity**: d and num satisfy a linear relation with det. -/
theorem den_num_linear_relation (a b n : ℤ) :
    (b - a) * twoPole_num a b n + (a * b + 1) * twoPole_den a b n = twoPole_det a b := by
  unfold twoPole_num twoPole_den twoPole_det; ring




/-- **Key bound**: If d | det and d ≠ 0, then |d| ≤ |det|. -/
theorem divisor_bound (a b n : ℤ)
    (hdvd : twoPole_den a b n ∣ twoPole_det a b)
    (hne0 : twoPole_den a b n ≠ 0) :
    (twoPole_den a b n).natAbs ≤ (twoPole_det a b).natAbs := by
  have hdet_pos : (0 : ℤ) < twoPole_det a b := by unfold twoPole_det; positivity
  exact Int.natAbs_le_of_dvd_ne_zero hdvd (ne_of_gt hdet_pos)




/-- [Section: # CatalogBuild.Geometry.Stereographic.InverseStereoMobiusNext
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 32] -/
theorem den_injective (a b : ℤ) (hab : a ≠ b) (n m : ℤ) :
    twoPole_den a b n = twoPole_den a b m → n = m := by
  exact fun h => mul_left_cancel₀ ( sub_ne_zero_of_ne hab ) <| by unfold twoPole_den at h; linarith;




/-- [Section: # CatalogBuild.Geometry.Stereographic.InverseStereoMobiusNext
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 32] -/
theorem integer_inputs_finite_set (a b : ℤ) (hab : a ≠ b) :
    Set.Finite {n : ℤ | twoPole_den a b n ∣ twoPole_det a b} := by
  -- The set of integers n where n divides a non-zero integer is finite.
  have finite_divisors : ∀ (d : ℤ), d ≠ 0 → Set.Finite {n : ℤ | n ∣ d} := by
    exact fun d hd => Set.Finite.subset ( Set.finite_Icc ( - |d| ) |d| ) fun n hn => ⟨ neg_le_of_abs_le <| Int.le_of_dvd ( abs_pos.mpr hd ) <| by simpa using hn, le_of_abs_le <| Int.le_of_dvd ( abs_pos.mpr hd ) <| by simpa using hn ⟩;
  by_cases h : twoPole_det a b = 0 <;> simp_all +decide [ twoPole_det ];
  · cases h <;> nlinarith;
  · exact Set.Finite.subset ( finite_divisors _ ( mul_ne_zero h.1 h.2 ) |> Set.Finite.preimage fun n => by simp +decide [ twoPole_den, sub_eq_zero, hab ] ) fun n hn => hn




/-- The Möbius matrix for F_{a,b}.
M = [[ab+1, b-a], [a-b, ab+1]] -/
def mobiusMatrix (a b : ℤ) : Matrix (Fin 2) (Fin 2) ℤ :=
  !![a * b + 1, b - a; a - b, a * b + 1]




theorem mobius_matrix_det (a b : ℤ) :
    (mobiusMatrix a b).det = twoPole_det a b := by
  unfold mobiusMatrix twoPole_det; ring;
  simpa [ Matrix.det_fin_two ] using by ring;




theorem mobius_matrix_trace (a b : ℤ) :
    (mobiusMatrix a b).trace = 2 * (a * b + 1) := by
  simp +arith +decide [ mobiusMatrix, Matrix.trace ]




theorem mobius_elliptic (a b : ℤ) (hab : a ≠ b) :
    (2 * (a * b + 1)) ^ 2 < 4 * ((1 + a ^ 2) * (1 + b ^ 2)) := by
  nlinarith [ mul_self_pos.2 ( sub_ne_zero.2 hab ) ]




theorem orbit_pairing (a b n : ℤ)
    (hden1 : twoPole_den a b n ≠ 0)
    (hdvd : twoPole_den a b n ∣ twoPole_num a b n) :
    let m := twoPole_num a b n / twoPole_den a b n
    twoPole_den b a m ∣ twoPole_num b a m := by
  obtain ⟨ k, hk ⟩ := hdvd;
  unfold twoPole_den twoPole_num at *;
  simp_all +decide [ mul_comm ];
  exact ⟨ n, by linarith ⟩




theorem no_integer_fixed_points (a b n : ℤ) (hab : a ≠ b) :
    twoPole_den a b n ≠ 0 →
    twoPole_num a b n ≠ n * twoPole_den a b n := by
  -- If $twoPole_num a b n = n * twoPole_den a b n$, then $(b - a) * (1 + n^2) = 0$. Since $a \neq b$, this implies $1 + n^2 = 0$, which is impossible.
  by_contra h_contra
  have h_eq : (b - a) * (1 + n^2) = 0 := by
    unfold twoPole_den twoPole_num at *; push_neg at *; linarith;
  exact hab ( by nlinarith )




/-- **Alternative factorization**: The other Brahmagupta decomposition. -/
theorem gaussian_norm_multiplicative_alt (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) =
    (a * c + b * d) ^ 2 + (a * d - b * c) ^ 2 := by ring




/-- **Two representations of the determinant**: From (1,a) and (1,b). -/
theorem det_two_representations (a b : ℤ) :
    twoPole_det a b = (a * b + 1) ^ 2 + (a - b) ^ 2 ∧
    twoPole_det a b = (a * b - 1) ^ 2 + (a + b) ^ 2 := by
  unfold twoPole_det; constructor <;> ring




/-- **Det is always ≥ 1** for integer poles. -/
theorem det_pos (a b : ℤ) : 0 < twoPole_det a b := by
  unfold twoPole_det; positivity




theorem det_eq_two (a b : ℤ) :
    twoPole_det a b = 2 ↔ (a = 0 ∧ (b = 1 ∨ b = -1)) ∨ (b = 0 ∧ (a = 1 ∨ a = -1)) := by
  unfold twoPole_det;
  -- Let's split the implication into two parts: if the equation holds, then the conditions on a and b must be true, and if the conditions on a and b are true, then the equation holds.
  apply Iff.intro;
  · intro h;
    rcases lt_trichotomy a 0 with ha | rfl | ha <;> rcases lt_trichotomy b 0 with hb | rfl | hb <;> first | nlinarith | exact Or.inl ⟨ by nlinarith, eq_or_eq_neg_of_sq_eq_sq _ _ <| by nlinarith ⟩ | exact Or.inr ⟨ by nlinarith, eq_or_eq_neg_of_sq_eq_sq _ _ <| by nlinarith ⟩ ;
  · rintro ( ⟨ rfl, rfl | rfl ⟩ | ⟨ rfl, rfl | rfl ⟩ ) <;> norm_num




theorem F01_at_0 : twoPole_num 0 1 0 / twoPole_den 0 1 0 = 1 := by
  unfold twoPole_num twoPole_den; norm_num




theorem F01_at_neg1 : twoPole_num 0 1 (-1) / twoPole_den 0 1 (-1) = 0 := by
  unfold twoPole_num twoPole_den; norm_num




theorem F01_at_2 : twoPole_num 0 1 2 / twoPole_den 0 1 2 = -3 := by
  unfold twoPole_num twoPole_den; norm_num




/-- F_{1,0}(-3) = 2, the reverse map takes -3 back to 2. -/
theorem F10_at_neg3 : twoPole_num 1 0 (-3) / twoPole_den 1 0 (-3) = 2 := by
  unfold twoPole_num twoPole_den; norm_num




/-- The orbit pairing {2, -3}: F_{0,1}(2) = -3 and F_{1,0}(-3) = 2. -/
theorem F01_orbit_2_neg3 :
    twoPole_num 0 1 2 / twoPole_den 0 1 2 = -3 ∧
    twoPole_num 1 0 (-3) / twoPole_den 1 0 (-3) = 2 := by
  constructor <;> (unfold twoPole_num twoPole_den; norm_num)




/-- The orbit pairing {0, 1}: F_{0,1}(0) = 1 and F_{1,0}(1) = 0. -/
theorem F01_orbit_0_1 :
    twoPole_num 0 1 0 / twoPole_den 0 1 0 = 1 ∧
    twoPole_num 1 0 1 / twoPole_den 1 0 1 = 0 := by
  constructor <;> (unfold twoPole_num twoPole_den; norm_num)




/-- Every pair of integer poles generates a sum-of-squares identity.
(ab+1)² + (a-b)² = (1+a²)(1+b²). -/
theorem pythagorean_from_poles (a b : ℤ) :
    (a * b + 1) ^ 2 + (a - b) ^ 2 = (1 + a ^ 2) * (1 + b ^ 2) := by ring




/-- Poles (1,2) give: 3² + 1² = 2 · 5 = 10. -/
theorem poles_1_2_sum_of_squares :
    ((1 : ℤ) * 2 + 1) ^ 2 + (1 - 2) ^ 2 = 10 := by norm_num




/-- Poles (1,3) give: 4² + 2² = 2 · 10 = 20. -/
theorem poles_1_3_sum_of_squares :
    ((1 : ℤ) * 3 + 1) ^ 2 + (1 - 3) ^ 2 = 20 := by norm_num




/-- Poles (2,3) give: 7² + 1² = 5 · 10 = 50. -/
theorem poles_2_3_sum_of_squares :
    ((2 : ℤ) * 3 + 1) ^ 2 + (2 - 3) ^ 2 = 50 := by norm_num




/-- When a=0, b=k: 1² + k² = 1+k². The trivial representation. -/
theorem poles_0_k_trivial (k : ℤ) :
    (0 * k + 1) ^ 2 + (0 - k) ^ 2 = (1 + 0 ^ 2) * (1 + k ^ 2) := by ring




/-- **Example**: 50 = 5 · 10 = (1+2²)(1+3²), recovering poles 2 and 3. -/
theorem factor_50_recovery :
    (50 : ℤ) = (1 + 2 ^ 2) * (1 + 3 ^ 2) := by norm_num




/-- 50 has two sum-of-squares representations from Brahmagupta. -/
theorem fifty_two_reps :
    (50 : ℤ) = 7 ^ 2 + 1 ^ 2 ∧ (50 : ℤ) = 5 ^ 2 + 5 ^ 2 := by
  constructor <;> norm_num




end