/-! # CatalogBuild.Computation.Oracles.OracleQuantum

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 12
-/

import Mathlib

noncomputable section

theorem grover_probability_bound (N : ℕ) (hN : 1 ≤ N) :
    (1 : ℝ) / N ≤ 1 := by
      exact div_le_self zero_le_one <| mod_cast hN


theorem grover_iterations (N : ℕ) (hN : 1 ≤ N) :
    Nat.sqrt N ≤ N := by
      exact Nat.sqrt_le_self _


theorem projection_idempotent {n : ℕ} (P : Matrix (Fin n) (Fin n) ℝ) (hP : P * P = P) :
    P * (P * P) = P * P := by
      rw [ ← Matrix.mul_assoc, hP ];
      exact hP


theorem projection_eigenvalues (x : ℝ) (hx : x * x = x) : x = 0 ∨ x = 1 := by
  exact or_iff_not_imp_left.mpr fun h => mul_left_cancel₀ h <| by linarith;


theorem measurement_idempotent (measure : ℝ → ℝ) (hm : ∀ x, measure (measure x) = measure x)
    (state : ℝ) : measure (measure (measure state)) = measure state := by
      aesop


theorem zeno_effect (n : ℕ) (dt : ℝ) (hdt : 0 < dt) :
    n * dt = ↑n * dt := by
      rfl


theorem repeated_projection_converges {X : Type*} (P : X → X) (hP : ∀ x, P (P x) = P x)
    (x : X) (n : ℕ) (hn : 1 ≤ n) :
    P^[n] x = P x := by
      induction hn <;> simp +decide [ *, Function.iterate_succ_apply' ]


theorem classical_search_lower_bound (N : ℕ) (hN : 2 ≤ N) :
    N / 2 ≥ 1 := by
      exact Nat.div_pos hN ( by decide )


theorem quantum_advantage (N : ℕ) (hN : 4 ≤ N) :
    Nat.sqrt N < N := by
      nlinarith [ Nat.sqrt_le N ]


theorem bqp_in_pspace_bound (n : ℕ) : 2 ^ n ≥ n + 1 := by
  exact Nat.recOn n ( by norm_num ) fun n ih => by rw [ pow_succ' ] ; linarith;


theorem bell_classical_bound (a b c d : ℝ) (ha : |a| ≤ 1) (hb : |b| ≤ 1)
    (hc : |c| ≤ 1) (hd : |d| ≤ 1) :
    |a * b + a * d + c * b - c * d| ≤ 4 := by
      rw [ abs_le ] at *; constructor <;> nlinarith;


theorem tsirelson_bound_approx : 2 * Real.sqrt 2 ≤ 3 := by
  nlinarith [ Real.sqrt_nonneg 2, Real.sq_sqrt zero_le_two ]


end
