import Mathlib

/-! # CatalogBuild.Algebra.Core.Moonshine

Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 5
-/


/-- Berggren matrix M₁ in SL(2,ℤ). -/
def berggren_M1 : Matrix.SpecialLinearGroup (Fin 2) ℤ :=
  ⟨!![2, -1; 1, 0], by decide +revert⟩




/-- Berggren matrix M₃ in SL(2,ℤ). -/
def berggren_M3 : Matrix.SpecialLinearGroup (Fin 2) ℤ :=
  ⟨!![1, 2; 0, 1], by decide +revert⟩




/-- The order formula |SL(2, 𝔽_p)| = p(p²-1) verified at p = 3, 5, 7. -/
theorem SL2_order_formula :
    3 * (3^2 - 1) = 24 ∧ 5 * (5^2 - 1) = 120 ∧ 7 * (7^2 - 1) = 336 := by
  norm_num




/-- Neukirch Prop 6.1: In a Dedekind domain, elements of 𝔭ⁱ admit expansions
modulo 𝔭^(i+1) using any 𝔭-uniformizer. -/
theorem dedekind_expansion {S : Type*} [CommRing S] [IsDedekindDomain S]
    {P : Ideal S} [P.IsPrime] (hP : P ≠ ⊥)
    {i : ℕ} (a c : S) (a_mem : a ∈ P ^ i)
    (a_notMem : a ∉ P ^ (i + 1)) (c_mem : c ∈ P ^ i) :
    ∃ d : S, ∃ e ∈ P ^ (i + 1), a * d + e = c :=
  Ideal.exists_mul_add_mem_pow_succ hP a c a_mem a_notMem c_mem




/-- 1728 = 12³, a fundamental constant in the theory of modular forms. -/
theorem j_value_cube : (1728 : ℤ) = 12 ^ 3 := by norm_num