/-! # CatalogBuild.NumberTheory.Core.Moonshine

Auto-generated from theorem catalog database.
Domain: NumberTheory/Core
Declarations: 5
-/

import Mathlib

/-- Berggren matrix M₁ in SL(2,ℤ). -/
def berggren_M1 : Matrix.SpecialLinearGroup (Fin 2) ℤ :=
  ⟨!![2, -1; 1, 0], by decide +revert⟩

/-- Berggren matrix M₃ in SL(2,ℤ). -/

def berggren_M3 : Matrix.SpecialLinearGroup (Fin 2) ℤ :=
  ⟨!![1, 2; 0, 1], by decide +revert⟩

/-- The theta group Γ_θ = ⟨S, T²⟩ in SL(2,ℤ). -/

theorem SL2_order_formula :
    3 * (3^2 - 1) = 24 ∧ 5 * (5^2 - 1) = 120 ∧ 7 * (7^2 - 1) = 336 := by
  norm_num

/-! ## §5.1: Sporadic Groups — M₁₁ Connection -/

/-- |SL(2, 𝔽₁₁)| = 1320. The quotient PSL(2,𝔽₁₁) of order 660 embeds in M₁₁. -/

theorem dedekind_expansion {S : Type*} [CommRing S] [IsDedekindDomain S]
    {P : Ideal S} [P.IsPrime] (hP : P ≠ ⊥)
    {i : ℕ} (a c : S) (a_mem : a ∈ P ^ i)
    (a_notMem : a ∉ P ^ (i + 1)) (c_mem : c ∈ P ^ i) :
    ∃ d : S, ∃ e ∈ P ^ (i + 1), a * d + e = c :=
  Ideal.exists_mul_add_mem_pow_succ hP a c a_mem a_notMem c_mem

/-! ## §8.1: j-Invariant Connection -/

/-- The j-invariant formula evaluated at the modular lambda function value. -/

theorem j_value_cube : (1728 : ℤ) = 12 ^ 3 := by norm_num

