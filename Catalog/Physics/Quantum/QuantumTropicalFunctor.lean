import Mathlib

/-! # CatalogBuild.Physics.Quantum.QuantumTropicalFunctor

Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 14
-/

noncomputable section

/-- [Section: # CatalogBuild.Physics.Quantum.QuantumTropicalFunctor
Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 14] -/
def qtMaslovAdd (ε : ℝ) (x y : ℝ) : ℝ :=
  ε * Real.log (Real.exp (x / ε) + Real.exp (y / ε))

/-- [Section: # CatalogBuild.Physics.Quantum.QuantumTropicalFunctor
Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 14] -/
theorem qt_logsumexp_ge_max (x y : ℝ) :
    Real.log (Real.exp x + Real.exp y) ≥ max x y := by
      rw [ ge_iff_le, max_def ];
      split_ifs <;> rw [ Real.le_log_iff_exp_le ] <;> linarith [ Real.exp_pos x, Real.exp_pos y ]

theorem qt_logsumexp_le_max_log2 (x y : ℝ) :
    Real.log (Real.exp x + Real.exp y) ≤ max x y + Real.log 2 := by
      rw [ Real.log_le_iff_le_exp ( by positivity ) ];
      rw [ Real.exp_add, Real.exp_log ] <;> cases max_cases x y <;> linarith [ Real.exp_le_exp.2 ( le_max_left x y ), Real.exp_le_exp.2 ( le_max_right x y ) ]

theorem qt_exp_sum_pos (x y : ℝ) : Real.exp x + Real.exp y > 0 := by
  linarith [Real.exp_pos x, Real.exp_pos y]

theorem qtMaslovAdd_comm (ε : ℝ) (x y : ℝ) :
    qtMaslovAdd ε x y = qtMaslovAdd ε y x := by
  simp [qtMaslovAdd, add_comm]

theorem qt_tropical_idempotent (x : ℝ) : max x x = x := by simp

theorem qt_tropical_mul_identity (x : ℝ) : x + 0 = x := by ring

theorem qt_tropical_distributive (a b c : ℝ) :
    max a b + c = max (a + c) (b + c) := by simp [max_add_add_right]

theorem qt_dequantization_threshold (n : ℕ) (hn : 5 ≤ n) : 2 ^ n > n ^ 2 := by
  induction hn with
  | refl => norm_num
  | @step k hk ih =>
    show 2 ^ (k + 1) > (k + 1) ^ 2
    have hk5 : (k : ℤ) ≥ 5 := by exact_mod_cast hk
    have h2 : 2 * k ^ 2 ≥ (k + 1) ^ 2 := by
      have : (2 : ℤ) * (k : ℤ) ^ 2 ≥ ((k : ℤ) + 1) ^ 2 := by nlinarith [sq_nonneg ((k : ℤ) - 1)]
      exact_mod_cast this
    calc (2 : ℕ) ^ (k + 1) = 2 ^ k * 2 := pow_succ 2 k
      _ ≥ (k ^ 2 + 1) * 2 := by omega
      _ = 2 * k ^ 2 + 2 := by ring
      _ > 2 * k ^ 2 := by omega
      _ ≥ (k + 1) ^ 2 := h2

theorem qt_barvinok_complexity (n r : ℕ) (hn : 0 < n) : n ^ r ≥ 1 := Nat.one_le_pow r n hn

theorem qt_holevo_bound (n : ℕ) : n ≤ 2 ^ n := by
  induction n with
  | zero => simp
  | succ k ih =>
    have h1 := Nat.one_le_pow k 2 (by omega)
    calc k + 1 ≤ 2 ^ k + 1 := by omega
      _ ≤ 2 ^ k + 2 ^ k := by omega
      _ = 2 ^ k * 2 := by ring
      _ = 2 ^ (k + 1) := (pow_succ 2 k).symm

theorem qt_quantum_advantage_superpolynomial (d : ℕ) :
    ∃ N, ∀ n, n ≥ N → 2 ^ n > n ^ d := by
      -- We'll use that exponential functions grow faster than polynomial functions.
      have h_exp_growth : Filter.Tendsto (fun n : ℕ => (n : ℝ) ^ d / 2 ^ n) Filter.atTop (nhds 0) := by
        -- We'll use the fact that $n^d / 2^n$ tends to $0$ as $n$ tends to infinity.
        have h_lim : Filter.Tendsto (fun n : ℕ => (n : ℝ) ^ d / Real.exp (n * Real.log 2)) Filter.atTop (nhds 0) := by
          -- Let $y = n \log 2$, therefore the limit becomes $\lim_{y \to \infty} \frac{y^d}{e^y}$.
          suffices h_log : Filter.Tendsto (fun y : ℝ => y ^ d / Real.exp y) Filter.atTop (nhds 0) by
            have := h_log.comp ( tendsto_natCast_atTop_atTop.atTop_mul_const ( Real.log_pos one_lt_two ) );
            convert this.div_const ( Real.log 2 ^ d ) using 2 <;> norm_num ; ring;
            norm_num [ mul_right_comm, mul_assoc, mul_left_comm, ne_of_gt, Real.log_pos ];
          simpa [ Real.exp_neg ] using Real.tendsto_pow_mul_exp_neg_atTop_nhds_zero d;
        simpa [ Real.exp_nat_mul, Real.exp_log ] using h_lim;
      exact Filter.eventually_atTop.mp ( h_exp_growth.eventually ( gt_mem_nhds zero_lt_one ) ) |> fun ⟨ N, hN ⟩ ↦ ⟨ N, fun n hn ↦ by have := hN n hn; rw [ div_lt_one ( by positivity ) ] at this; exact_mod_cast this ⟩

def qtSoftmaxKernel (ε : ℝ) (x y : ℝ) : ℝ := Real.exp (x * y / ε)

theorem qtSoftmaxKernel_pos (ε x y : ℝ) : qtSoftmaxKernel ε x y > 0 := by
  simp [qtSoftmaxKernel, Real.exp_pos]

end
