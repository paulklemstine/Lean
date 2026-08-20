/-
# Worked examples: refined Solomon zeta coefficients of free lattices

This file instantiates the general machinery of `Shared.SolomonZeta.Core`,
`Shared.SolomonZeta.Applications` and `Shared.SolomonZeta.Multiplicativity` at concrete
quotient types, producing closed formulas that can be checked by hand.
-/
import Catalog.Shared.SolomonZeta.Applications
import Catalog.Shared.SolomonZeta.Multiplicativity

namespace SolomonZeta

open Finset IncidenceAlgebra

/-- The `Aut`-weighted count of sublattices of `ℤⁿ` with quotient `ℤ/p` is `pⁿ - 1`. -/
theorem weighted_count_zmod_prime (p : ℕ) [Fact p.Prime] (n : ℕ) :
    (autCard ℤ (ZMod p) : ℤ) * (quotIsoCount ℤ (Fin n → ℤ) (ZMod p) : ℤ) = (p : ℤ) ^ n - 1 := by
  rw [simple_quotient_count, card_hom_free]
  simp

theorem zmod_prime_annihilated (p : ℕ) (x : ZMod p) : (p : ℤ) • x = 0 := by
  rw [zsmul_eq_mul]
  simp

/-- **A two-prime Euler factorization made explicit.**  For distinct primes `p ≠ q` the
`Aut`-weighted number of sublattices of `ℤⁿ` with quotient `ℤ/p × ℤ/q ≅ ℤ/pq` is the product
`(pⁿ - 1)(qⁿ - 1)` of the two local weights. -/
theorem weighted_count_zmod_two_primes (p q : ℕ) [Fact p.Prime] [Fact q.Prime] (hpq : p ≠ q)
    (n : ℕ) :
    (autCard ℤ (ZMod p × ZMod q) : ℤ) * (quotIsoCount ℤ (Fin n → ℤ) (ZMod p × ZMod q) : ℤ)
      = ((p : ℤ) ^ n - 1) * ((q : ℤ) ^ n - 1) := by
  have hcop : Nat.Coprime p q := (Nat.coprime_primes Fact.out Fact.out).2 hpq
  rw [quotIsoCount_prod_of_coprime (M := Fin n → ℤ) p q hcop
      (zmod_prime_annihilated p) (zmod_prime_annihilated q),
    weighted_count_zmod_prime, weighted_count_zmod_prime]

/-- **The effective formula for arbitrary cyclic quotient types.**  For every `m ≥ 1` the number
of sublattices of `ℤⁿ` with quotient `ℤ/m`, weighted by Euler's totient, is the Möbius-weighted
sum `Σ_{Y ≤ ℤ/m} μ(Y, ⊤) · |Y|ⁿ` over the subgroup lattice of `ℤ/m`. -/
theorem totient_mul_quotIsoCount_zmod (m : ℕ) [NeZero m] (n : ℕ) :
    (m.totient : ℤ) * (quotIsoCount ℤ (Fin n → ℤ) (ZMod m) : ℤ)
      = ∑ Y ∈ Finset.Iic (⊤ : Submodule ℤ (ZMod m)), mu ℤ Y ⊤ * ((Nat.card Y : ℤ) ^ n) := by
  rw [← mobiusWeight_free (R := ℤ) (X := ZMod m) n, ← autCard_zmod m,
    autCard_mul_quotIsoCount_eq_mobiusWeight]

/-! ### Structural corollaries of the effective formula -/

/-- The Möbius weight of any pair `(M, X)` is a nonnegative integer. -/
theorem mobiusWeight_nonneg {R M X : Type*} [Ring R] [AddCommGroup M] [Module R M]
    [AddCommGroup X] [Module R X] [Finite X] [Module.Finite R M] :
    0 ≤ mobiusWeight R M X := by
  rw [← autCard_mul_quotIsoCount_eq_mobiusWeight]
  positivity

/-- The order of `Aut(X)` divides the Möbius weight: a divisibility constraint on Möbius sums
over submodule posets that is invisible from the combinatorial side. -/
theorem autCard_dvd_mobiusWeight {R M X : Type*} [Ring R] [AddCommGroup M] [Module R M]
    [AddCommGroup X] [Module R X] [Finite X] [Module.Finite R M] :
    (autCard R X : ℤ) ∣ mobiusWeight R M X :=
  ⟨(quotIsoCount R M X : ℤ), (autCard_mul_quotIsoCount_eq_mobiusWeight).symm⟩

/-! ### Numerical instances -/

/-- `ℤ³` has exactly `7 = 1 + 2 + 4` sublattices with quotient `ℤ/2`. -/
theorem quotIsoCount_rank_three_two : quotIsoCount ℤ (Fin 3 → ℤ) (ZMod 2) = 7 := by
  have h := card_index_p_sublattices_geom 2 3
  norm_num [Finset.sum_range_succ] at h
  exact_mod_cast h

/-- `ℤ²` has exactly `4 = 1 + 3` sublattices with quotient `ℤ/3`. -/
theorem quotIsoCount_rank_two_three : quotIsoCount ℤ (Fin 2 → ℤ) (ZMod 3) = 4 := by
  have h := card_index_p_sublattices_geom 3 2
  norm_num [Finset.sum_range_succ] at h
  exact_mod_cast h

/-- Consistency check of the general theory with the rank one case: the unique sublattice of `ℤ`
of index `p` is `pℤ`. -/
theorem quotIsoCount_rank_one_prime (p : ℕ) [Fact p.Prime] :
    quotIsoCount ℤ (Fin 1 → ℤ) (ZMod p) = 1 := by
  have h := card_index_p_sublattices_geom p 1
  simpa using h

end SolomonZeta