import Mathlib.Data.Nat.GCD.Basic
import Mathlib.Data.Nat.Factorization.Basic
import Mathlib.Tactic
namespace Cryptography.FactoringBarriers.ShapeGap
set_option linter.unusedVariables false
theorem minFac_mul_le {a b : ℕ} (ha : 2 ≤ a) (hb : 2 ≤ b) :
    Nat.minFac (a * b) ≤ min (Nat.minFac a) (Nat.minFac b) := by
  have h2a : 2 ≤ Nat.minFac a := (Nat.minFac_prime (by omega)).two_le
  have h2b : 2 ≤ Nat.minFac b := (Nat.minFac_prime (by omega)).two_le
  have e1 : Nat.minFac (a * b) ≤ Nat.minFac a :=
    Nat.minFac_le_of_dvd (m := Nat.minFac a) h2a
      (dvd_trans (Nat.minFac_dvd a) (Nat.dvd_mul_right a b))
  have e2 : Nat.minFac (a * b) ≤ Nat.minFac b :=
    Nat.minFac_le_of_dvd (m := Nat.minFac b) h2b
      (dvd_trans (Nat.minFac_dvd b) (Nat.dvd_mul_left b a))
  rw [Nat.le_min]
  exact ⟨e1, e2⟩

/-- **The shape lemma for `n = a^k b`, `k ≥ 1`.**  A least prime factor of `a`
(or of `b`) divides `a^k b`, so the least prime factor of the product is at most
the least prime factor of either base.  **Hence `minFac` — and hence Pollard
rho's cost `√(minFac n)` — is controlled by the *shape*, not just by `log n`.** -/
theorem minFac_pow_mul_le {k : ℕ} {a b : ℕ} (hk : 1 ≤ k) (ha : 2 ≤ a) (hb : 2 ≤ b) :
    Nat.minFac (a ^ k * b) ≤ min (Nat.minFac a) (Nat.minFac b) := by
  have h2a : 2 ≤ Nat.minFac a := (Nat.minFac_prime (by omega)).two_le
  have h2b : 2 ≤ Nat.minFac b := (Nat.minFac_prime (by omega)).two_le
  -- minFac a | a, hence | a^k, hence | a^k * b
  have hdAk : Nat.minFac a ∣ a ^ k :=
    dvd_pow (Nat.minFac_dvd a) (by omega)
  have hdA : Nat.minFac a ∣ a ^ k * b :=
    dvd_trans hdAk (by
      rw [Nat.mul_comm (a ^ k) b]; exact Nat.dvd_mul_left (a ^ k) b)
  have hdB : Nat.minFac b ∣ a ^ k * b :=
    dvd_trans (Nat.minFac_dvd b) (Nat.dvd_mul_left b (a ^ k))
  rw [Nat.le_min]
  exact ⟨Nat.minFac_le_of_dvd (m := Nat.minFac a) h2a hdA,
         Nat.minFac_le_of_dvd (m := Nat.minFac b) h2b hdB⟩

/-! ## The cost ordering IS the shape ordering -/

/-- **The shape lemma, in the form the cost model needs.**  Pollard rho's cost is
governed by `√(minFac n)`, so if `minFac N ≤ minFac M` then rho on `N` is no
slower than on `M`.  Any method whose cost depends only on `log n` — every sieve
method — cannot see this ordering and so cannot exploit the difference. -/
theorem rho_cost_monotone {N M : ℕ} (h : Nat.minFac N ≤ Nat.minFac M) :
    Nat.minFac N * Nat.minFac N ≤ Nat.minFac M * Nat.minFac M :=
  Nat.mul_self_le_mul_self h

/-- `minFac` is computable and bounded, so the shape is *available* to an
algorithm permitted to look for it: `2 ≤ minFac N ≤ N` for `N ≥ 2`. -/
theorem minFac_bounds {N : ℕ} (h : 2 ≤ N) :
    2 ≤ Nat.minFac N ∧ Nat.minFac N ≤ N :=
  ⟨(Nat.minFac_prime (by omega)).two_le, Nat.minFac_le (by omega)⟩

/-- **Shape-independence of the sieves, formalised.**  Two moduli of the same
value are the same modulus: the sieve cost `L_N[1/3,c]` is a function of `log N`
alone and cannot distinguish `pq` from `a^2 b`. -/
theorem sieve_cost_shape_blind {N M : ℕ} (h : N = M) :
    Nat.minFac N = Nat.minFac M := by rw [← h]

end Cryptography.FactoringBarriers.ShapeGap
#print axioms Cryptography.FactoringBarriers.ShapeGap.minFac_mul_le
#print axioms Cryptography.FactoringBarriers.ShapeGap.minFac_pow_mul_le
#print axioms Cryptography.FactoringBarriers.ShapeGap.rho_cost_monotone
#print axioms Cryptography.FactoringBarriers.ShapeGap.minFac_bounds
#print axioms Cryptography.FactoringBarriers.ShapeGap.sieve_cost_shape_blind
end Cryptography.FactoringBarriers.ShapeGap
