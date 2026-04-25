/-! # CatalogBuild.Pythagorean.Quadruples.FactoringTheory

Auto-generated from theorem catalog database.
Domain: Pythagorean/Quadruples
Declarations: 7
-/

import CatalogBuild.Pythagorean.Quadruples.Basic
import Mathlib

/-- If N = p * q and k is coprime to both p and q,
then k is coprime to N and the vector gives no factoring information. -/
theorem coprime_quotient_useless (p q k N : ℕ)
    (hN : N = p * q)
    (hkp : Nat.Coprime k p)
    (hkq : Nat.Coprime k q) :
    Nat.Coprime k N := by
  rw [hN]
  exact Nat.Coprime.mul_right hkp hkq


/-- [Section: # CatalogBuild.Pythagorean.Quadruples.FactoringTheory
Auto-generated from theorem catalog database.
Domain: Pythagorean/Quadruples
Declarations: 7] -/
theorem factoring_works_iff (p q k : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (_hpq : p ≠ q) (hk : 0 < k) (_hkN : k < p * q) :
    1 < Nat.gcd k (p * q) ↔ (p ∣ k ∨ q ∣ k) := by
  refine' ⟨ fun h => _, fun h => _ ⟩;
  · contrapose! h;
    exact Nat.le_of_eq ( Nat.Coprime.gcd_eq_one <| Nat.Coprime.mul_right ( Nat.Coprime.symm <| hp.coprime_iff_not_dvd.mpr h.1 ) ( Nat.Coprime.symm <| hq.coprime_iff_not_dvd.mpr h.2 ) );
  · rcases h with ( h | h ) <;> [ exact lt_of_lt_of_le hp.one_lt ( Nat.le_of_dvd ( Nat.gcd_pos_of_pos_left _ hk ) ( Nat.dvd_gcd h ( dvd_mul_right _ _ ) ) ) ; exact lt_of_lt_of_le hq.one_lt ( Nat.le_of_dvd ( Nat.gcd_pos_of_pos_left _ hk ) ( Nat.dvd_gcd h ( dvd_mul_left _ _ ) ) ) ]


/-- N^4 > N^3 for N ≥ 2, encoding the fact that N^{2/3} > N^{1/2}.
(Since (N^{2/3})^6 = N^4 and (N^{1/2})^6 = N^3, N^4 > N^3
implies N^{2/3} > N^{1/2}.) -/
theorem minkowski_worse_than_sqrt (N : ℕ) (hN : 2 ≤ N) :
    N ^ 3 < N ^ 4 := by
  nlinarith [Nat.one_le_pow 3 N (by omega)]


/-- The only dimension where k/d = 1/2 with k = d-1 is d = 2. -/
theorem optimal_dimension_is_two :
    ∀ d : ℕ, 2 ≤ d → (2 * (d - 1) = d ↔ d = 2) := by
  intro d hd; omega


/-- The parametrization gives vectors satisfying the sum-of-squares congruence. -/
theorem quad_param_in_L4 (m n p q : ℤ) :
    sumSqCong (m ^ 2 + n ^ 2 + p ^ 2 + q ^ 2)
      (m ^ 2 + n ^ 2 - p ^ 2 - q ^ 2)
      (2 * (m * q + n * p))
      (2 * (n * q - m * p)) := by
  simp only [sumSqCong]
  exact ⟨1, by rw [quad_param_valid]; ring⟩


/-- If coprime moduli both divide a sum of squares, their product does too. -/
theorem coprime_lattice_intersection (N₁ N₂ x y z : ℤ)
    (hcop : IsCoprime N₁ N₂)
    (h1 : N₁ ∣ (x ^ 2 + y ^ 2 + z ^ 2))
    (h2 : N₂ ∣ (x ^ 2 + y ^ 2 + z ^ 2)) :
    (N₁ * N₂) ∣ (x ^ 2 + y ^ 2 + z ^ 2) :=
  hcop.mul_dvd h1 h2


/-- A Pythagorean quadruple projects onto the rational unit sphere. -/
theorem quad_unit_sphere (a b c d : ℤ) (hd : d ≠ 0)
    (hpyth : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (a : ℚ) ^ 2 / d ^ 2 + (b : ℚ) ^ 2 / d ^ 2 + (c : ℚ) ^ 2 / d ^ 2 = 1 := by
  have hd_ne : (d : ℚ) ≠ 0 := Int.cast_ne_zero.mpr hd
  have hd2_ne : (d : ℚ) ^ 2 ≠ 0 := pow_ne_zero 2 hd_ne
  field_simp
  exact_mod_cast hpyth


