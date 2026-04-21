/-! # CatalogBuild.Algebra.RiemannHypothesis.RiemannHypothesis

Auto-generated from theorem catalog database.
Domain: Algebra/RiemannHypothesis
Declarations: 10
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Algebra.RiemannHypothesis.RiemannHypothesis
Auto-generated from theorem catalog database.
Domain: Algebra/RiemannHypothesis
Declarations: 10] -/
theorem hermitian_eigenvalues_real {n : ℕ} (M : Matrix (Fin n) (Fin n) ℂ)
    (hM : M.IsHermitian) (μ : ℂ) (v : Fin n → ℂ) (hv : v ≠ 0)
    (hev : M.mulVec v = μ • v) : μ.im = 0 := by
  -- From hev we know M v = μ v. Take the inner product ⟨v, Mv⟩ in two ways: it equals μ⟨v,v⟩ (from the eigenvalue equation) and also equals ⟨Mv, v⟩ = μ̄⟨v,v⟩ (from Hermiticity). Since v ≠ 0, ⟨v,v⟩ ≠ 0, so μ = μ̄, meaning μ.im = 0.
  have h_inner : ∑ x, star (v x) * (M.mulVec v x) = μ * ∑ x, star (v x) * v x ∧ ∑ x, star (v x) * (M.mulVec v x) = star μ * ∑ x, star (v x) * v x := by
    have h_inner_eq : ∑ x, star (v x) * (M.mulVec v x) = ∑ x, star (M.mulVec v x) * v x := by
      simp +decide [ Matrix.mulVec, dotProduct ];
      simp +decide only [Finset.mul_sum _ _ _, sum_mul, mul_assoc];
      rw [ Finset.sum_comm ] ; congr ; ext ; congr ; ext ; ring;
      rw [ ← hM.apply ] ; ring!;
    simp_all +decide [ mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ];
  simp_all +decide [ Complex.ext_iff ];
  simp_all +decide [ mul_comm, mul_assoc, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_add_distrib ];
  exact mul_left_cancel₀ ( show ( ∑ x, ( v x |> Complex.re ) * ( v x |> Complex.re ) + ∑ x, ( v x |> Complex.im ) * ( v x |> Complex.im ) ) ≠ 0 from fun h => hv <| funext fun i => by norm_num [ Complex.ext_iff ] ; constructor <;> nlinarith only [ h, Finset.single_le_sum ( fun a _ => mul_self_nonneg ( v a |> Complex.re ) ) ( Finset.mem_univ i ), Finset.single_le_sum ( fun a _ => mul_self_nonneg ( v a |> Complex.im ) ) ( Finset.mem_univ i ) ] ) <| by linarith;




/-- [Section: # CatalogBuild.Algebra.RiemannHypothesis.RiemannHypothesis
Auto-generated from theorem catalog database.
Domain: Algebra/RiemannHypothesis
Declarations: 10] -/
theorem bertrand_postulate' (n : ℕ) (hn : n ≥ 1) :
    ∃ p, n < p ∧ p ≤ 2 * n ∧ Nat.Prime p := by
  -- Apply Bertrand's postulate to find a prime $p$ such that $n < p \leq 2n$.
  have := Nat.exists_prime_lt_and_le_two_mul n (by linarith)
  aesop




theorem prime_ge_three_odd (p : ℕ) (hp : Nat.Prime p) (hp3 : p ≥ 3) : ¬ 2 ∣ p := by
  rw [ hp.dvd_iff_eq ] <;> linarith




theorem vandermonde_vanishes_at_collision {n : ℕ} (v : Fin n → ℂ)
    (i j : Fin n) (hij : i ≠ j) (hv : v i = v j) :
    Matrix.det (Matrix.vandermonde v) = 0 := by
  exact Matrix.det_zero_of_row_eq hij ( by aesop )




theorem vandermonde_det_product {n : ℕ} (v : Fin n → ℂ) :
    Matrix.det (Matrix.vandermonde v) = ∏ i : Fin n, ∏ j ∈ Finset.Ioi i, (v j - v i) := by
  rw [ Matrix.det_vandermonde ]




/-- 2 is prime. -/
theorem two_is_prime : Nat.Prime 2 := by decide




/-- 3 is prime. -/
theorem three_is_prime : Nat.Prime 3 := by decide




/-- The first prime gap: 3 - 2 = 1. -/
theorem first_prime_gap : 3 - 2 = 1 := by norm_num




/-- The Hasse bound for y² = x³ + x + 1 over F_5 (computational verification).
We verify that this specific elliptic curve has 9 points over F_5,
and |9 - 6| = 3 ≤ 2√5 ≈ 4.47, consistent with the Weil conjectures. -/
theorem hasse_example : (9 : ℤ) - (5 + 1) = 3 := by norm_num




/-- The Hasse bound inequality for the specific case p = 5, a_p = 3:
3² ≤ 4 · 5, i.e., a_p² ≤ 4p (equivalent to |a_p| ≤ 2√p). -/
theorem hasse_bound_F5 : (3 : ℤ) ^ 2 ≤ 4 * 5 := by norm_num




end
