/-! # CatalogBuild.OISCC.DensityTheory

Auto-generated from theorem catalog database.
Domain: OISCC
Declarations: 15
-/

import Mathlib

noncomputable section

/-- The EML operation. -/
def EMLd (a b : ℝ) : ℝ := Real.exp a - Real.log b

/-- The set of EML-reachable values from a seed set S at depth ≤ d. -/

def fullEMLClosure (S : Set ℝ) : Set ℝ := ⋃ n, EMLClosure n S

/-! ## Section 1: EML Generates Key Values -/

/-- 1 is in the seed set. -/

theorem one_in_closure : (1 : ℝ) ∈ EMLClosure 0 {1} := by
  simp [EMLClosure]

/-- EML closure is monotone in depth. -/

theorem EMLClosure_mono (S : Set ℝ) (n : ℕ) :
    EMLClosure n S ⊆ EMLClosure (n + 1) S := by
  intro x hx
  simp [EMLClosure]
  exact Or.inl hx

/-! ## Section 2: The Log-Split Identity -/

/-- Log-split: EML(x, y·z) = EML(x, y) - ln(z) for y, z > 0. -/

theorem EMLd_log_split (x y z : ℝ) (hy : 0 < y) (hz : 0 < z) :
    EMLd x (y * z) = EMLd x y - Real.log z := by
  simp [EMLd, Real.log_mul hy.ne' hz.ne']; ring

/-- EML(x, 1) = exp(x). -/

theorem EMLd_exp (x : ℝ) : EMLd x 1 = Real.exp x := by
  simp [EMLd, Real.log_one]

/-- EML(0, x) = 1 - ln(x). -/

theorem EMLd_one_minus_log (x : ℝ) : EMLd 0 x = 1 - Real.log x := by
  simp [EMLd]

/-! ## Section 3: Density Building Blocks -/

/-- EML(0, x) maps values in (1, e) to (0, 1). -/

theorem EMLd_maps_to_unit_interval (x : ℝ) (hx1 : 1 < x) (hxe : x < Real.exp 1) :
    0 < EMLd 0 x ∧ EMLd 0 x < 1 := by
  constructor
  · simp [EMLd]
    have : Real.log x < 1 := by
      rwa [← Real.log_exp 1, Real.log_lt_log_iff (by linarith) (Real.exp_pos 1)]
    linarith
  · simp [EMLd]
    linarith [Real.log_pos hx1]

/-- exp maps any positive value to a value > 1. -/

theorem EMLd_amplifies (x : ℝ) (hx : 0 < x) :
    EMLd x 1 > 1 := by
  simp [EMLd, Real.log_one]
  linarith [Real.add_one_le_exp x]

/-! ## Section 4: Key Identities for Density -/

/-- The composition EML(EML(0, x), 1) = exp(1 - ln(x)) = e/x for x > 0. -/

theorem EMLd_inv_scaled (x : ℝ) (hx : 0 < x) :
    EMLd (EMLd 0 x) 1 = Real.exp 1 / x := by
  simp [EMLd, Real.log_one, Real.exp_sub, Real.exp_log hx]

/-- ln recovery: EML(0, exp(EML(0, x))) = ln(x). -/

theorem EMLd_recovers_ln (x : ℝ) :
    EMLd 0 (Real.exp (EMLd 0 x)) = Real.log x := by
  simp [EMLd, Real.log_exp]

/-- Double negation: EML(0, exp(EML(0, exp(x)))) = x. -/

theorem EMLd_double_neg (x : ℝ) :
    EMLd 0 (Real.exp (EMLd 0 (Real.exp x))) = x := by
  simp [EMLd, Real.log_exp]

/-- Shift identity: EML(x + c, 1) = exp(c) · exp(x). -/

theorem EMLd_shift (x c : ℝ) :
    EMLd (x + c) 1 = Real.exp c * Real.exp x := by
  simp [EMLd, Real.log_one, Real.exp_add, mul_comm]

/-! ## Section 5: Irrationality of EML Values -/

/-
e is irrational.
-/

theorem e_irrational : Irrational (Real.exp 1) := by
  by_contra h;
  -- Assume that $e$ is rational, so there exist positive integers $p$ and $q$ such that $e = p/q$.
  obtain ⟨p, q, hpq⟩ : ∃ p q : ℕ, p > 0 ∧ q > 0 ∧ Real.exp 1 = p / q := by
    -- Since $e$ is not irrational, it must be rational. Therefore, there exist positive integers $p$ and $q$ such that $e = p/q$.
    obtain ⟨p, q, hpq⟩ : ∃ p q : ℤ, p > 0 ∧ q > 0 ∧ Real.exp 1 = p / q := by
      obtain ⟨ q, hq ⟩ := Classical.not_not.mp h;
      exact ⟨ q.num, q.den, mod_cast Rat.num_pos.mpr ( show 0 < q by exact_mod_cast hq.symm ▸ Real.exp_pos 1 ), mod_cast q.pos, by simpa only [ Rat.cast_def ] using hq.symm ⟩;
    cases p <;> cases q <;> aesop;
  -- Multiply both sides of the equation $e = p/q$ by $q!$ to obtain $q! \cdot e = p \cdot (q-1)! + p \cdot (q-2)! + \cdots + p + \frac{p}{q+1} + \cdots$.
  have h_mul_factorial : q.factorial * Real.exp 1 = ∑ k ∈ Finset.range (q + 1), (q.factorial : ℝ) / (k.factorial : ℝ) + ∑' k : ℕ, (q.factorial : ℝ) / ((q + 1 + k).factorial : ℝ) := by
    have h_mul_factorial : q.factorial * Real.exp 1 = ∑' k : ℕ, (q.factorial : ℝ) / ((k).factorial : ℝ) := by
      norm_num [ div_eq_mul_inv, Real.exp_eq_exp_ℝ, NormedSpace.exp_eq_tsum ];
      rw [ NormedSpace.exp_eq_tsum_div, ← tsum_mul_left ] ; exact tsum_congr fun _ => by ring;
    rw [ h_mul_factorial, ← Summable.sum_add_tsum_nat_add ];
    congr! 2;
    · ac_rfl;
    · exact Summable.mul_left _ <| by simpa using Real.summable_pow_div_factorial 1;
  -- The series $\sum_{k=q+1}^{\infty} \frac{q!}{k!}$ is strictly less than 1.
  have h_series_lt_one : ∑' k : ℕ, (q.factorial : ℝ) / ((q + 1 + k).factorial : ℝ) < 1 := by
    -- We can bound the series $\sum_{k=q+1}^{\infty} \frac{q!}{k!}$ above by a geometric series.
    have h_geo_series : ∑' k : ℕ, (q.factorial : ℝ) / ((q + 1 + k).factorial : ℝ) ≤ ∑' k : ℕ, (q.factorial : ℝ) / ((q + 1).factorial : ℝ) * (1 / (q + 2)) ^ k := by
      refine' Summable.tsum_le_tsum _ _ _;
      · field_simp;
        intro i; rw [ div_pow ] ; rw [ mul_div, le_div_iff₀ ] <;> norm_cast <;> induction' i with i ih <;> norm_num [ Nat.factorial, pow_succ' ] at *;
        nlinarith [ Nat.factorial_succ ( q + 1 + i ) ];
      · exact Summable.mul_left _ <| by simpa using Summable.comp_injective ( Real.summable_pow_div_factorial 1 ) <| by intros a b; aesop;
      · exact Summable.mul_left _ <| summable_geometric_of_lt_one ( by positivity ) <| by rw [ div_lt_iff₀ ] <;> norm_cast <;> linarith;
    refine lt_of_le_of_lt h_geo_series ?_;
    rw [ tsum_mul_left, tsum_geometric_of_lt_one ( by positivity ) ( by rw [ div_lt_iff₀ ] <;> norm_cast <;> linarith ) ];
    field_simp;
    rw [ div_lt_iff₀ ] <;> norm_num [ Nat.factorial_succ ] <;> ring <;> norm_cast <;> nlinarith [ Nat.factorial_pos q ];
  -- Since $q! \cdot e$ is an integer, the second sum must also be an integer.
  have h_second_sum_int : ∃ m : ℤ, ∑' k : ℕ, (q.factorial : ℝ) / ((q + 1 + k).factorial : ℝ) = m := by
    use q.factorial * p / q - ∑ k ∈ Finset.range (q + 1), (q.factorial : ℤ) / (k.factorial : ℤ);
    rw [ Int.cast_sub, Int.cast_div ] <;> norm_num;
    · simp_all +decide [ mul_div_assoc, Finset.sum_div _ _ _ ];
      exact eq_sub_of_add_eq <| by rw [ Finset.sum_congr rfl fun i hi => by rw [ Int.cast_div ( by exact_mod_cast Nat.factorial_dvd_factorial <| by linarith [ Finset.mem_range.mp hi ] ) ( by positivity ) ] ] ; push_cast ; ring;
    · exact dvd_mul_of_dvd_left ( mod_cast Nat.dvd_factorial ( by linarith ) ( by linarith ) ) _;
    · linarith;
  obtain ⟨ m, hm ⟩ := h_second_sum_int; rcases m with ⟨ _ | _ | m ⟩ <;> norm_num at hm <;> try linarith;
  · exact absurd hm <| ne_of_gt <| lt_of_lt_of_le ( by positivity ) <| Summable.le_tsum ( by exact ( by simpa using Summable.mul_left _ <| Real.summable_pow_div_factorial 1 |> Summable.comp_injective <| by intros a b; aesop ) ) 0 <| by intros; positivity;
  · linarith [ show ( 0 : ℝ ) ≤ ∑' k : ℕ, ( q.factorial : ℝ ) / ( q + 1 + k ).factorial by exact tsum_nonneg fun _ => by positivity ]

/-- exp(exp(1)) is irrational. -/

theorem exp_e_irrational : Irrational (Real.exp (Real.exp 1)) := by
  sorry

end

end
