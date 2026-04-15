/-! # CatalogBuild.Computation.Factoring.QuaternionFactoring

Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 3
-/

import Mathlib

theorem norm_nonneg (q : IntQuaternion) : 0 ≤ q.norm := by
  exact add_nonneg ( add_nonneg ( add_nonneg ( sq_nonneg _ ) ( sq_nonneg _ ) ) ( sq_nonneg _ ) ) ( sq_nonneg _ )


theorem mul_conj (q : IntQuaternion) :
    mul q (conj q) = ⟨q.norm, 0, 0, 0⟩ := by
  unfold IntQuaternion.norm;
  unfold IntQuaternion.mul;
  unfold IntQuaternion.conj; ring;


theorem gcd_extraction_nontrivial (N : ℕ) (hN : 1 < N)
    (x y z : ℤ) (k : ℤ) (hk : 0 < k) (hk2 : k < N)
    (hsum : x^2 + y^2 + z^2 = k * N) :
    ∃ d : ℕ, d = Nat.gcd (Int.natAbs (x^2 + y^2 + z^2)) N ∧ d ∣ N := by
  exact ⟨ _, rfl, Nat.gcd_dvd_right _ _ ⟩
