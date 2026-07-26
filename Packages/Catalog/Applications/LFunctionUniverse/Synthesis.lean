import Mathlib

/-!
# A rigorous countability criterion for arithmetic L-function families

This file isolates the exact logical content of a “finite arithmetic census”.  It
does **not** assume that every analytic Selberg-class function has such an encoding.
Instead, it proves that whenever a family admits a faithful encoding by finite lists
over countable alphabets, that family is countable.  If it also contains a faithful
copy of `ℕ`, then it is countably infinite.

The distinction matters: proving a finite-data rigidity theorem for the analytic
Selberg class is a separate, deep mathematical problem.
-/

namespace LFunctionUniverse

/-- A generic finite arithmetic code.  The natural-number fields can represent
such invariants as degree and conductor, the integer list can represent finitely
many integral local coefficients, and the rational list can represent finite
archimedean or root-number data in a countable coefficient field. -/
structure FiniteArithmeticCode where
  discreteInvariants : List ℕ
  integralLocalData : List ℤ
  rationalData : List ℚ
deriving DecidableEq

/-- Finite arithmetic codes over countable alphabets form a countable type. -/
instance : Countable FiniteArithmeticCode := by
  apply Function.Injective.countable
    (f := fun c => (c.discreteInvariants, c.integralLocalData, c.rationalData))
  intro a b h
  cases a
  cases b
  simp_all

/-- **Faithful finite encoding criterion.** Any mathematical family faithfully
encoded by finite arithmetic codes is countable. -/
theorem countable_of_faithful_finite_encoding {L : Type*}
    (encode : L → FiniteArithmeticCode) (faithful : Function.Injective encode) :
    Countable L :=
  faithful.countable

/-- A faithful finite encoding also makes every subset of the family countable.
Thus imposing additional axioms (Euler product, functional equation, bounds, and
so on) cannot destroy countability once the ambient encoding theorem is known. -/
theorem subset_countable_of_faithful_finite_encoding {L : Type*}
    (encode : L → FiniteArithmeticCode) (faithful : Function.Injective encode)
    (S : Set L) : S.Countable := by
  letI : Countable L := countable_of_faithful_finite_encoding encode faithful
  exact Set.to_countable S

/-- **Exact census criterion.** If, in addition to a faithful finite encoding, a
family contains pairwise distinct members indexed by `ℕ`, then it is in bijection
with `ℕ`. -/
theorem equiv_nat_of_faithful_encoding_and_infinite_tower {L : Type*}
    (encode : L → FiniteArithmeticCode) (faithful : Function.Injective encode)
    (tower : ℕ → L) (towerFaithful : Function.Injective tower) :
    Nonempty (L ≃ ℕ) := by
  letI : Countable L := countable_of_faithful_finite_encoding encode faithful
  letI : Infinite L := Infinite.of_injective tower towerFaithful
  exact ⟨(nonempty_denumerable L).some.eqv⟩

/-- By contrast, arbitrary complex coefficient sequences are uncountable.  Thus a
faithful finite arithmetic encoding is a genuinely restrictive hypothesis, not a
property of arbitrary Dirichlet series. -/
theorem complex_coefficient_sequences_not_countable : ¬ Countable (ℕ → ℂ) := by
  intro h
  have hb : Countable (ℕ → Bool) := by
    apply Function.Injective.countable
      (f := fun a : ℕ → Bool => fun n => if a n then (1 : ℂ) else 0)
    intro a b hab
    funext n
    have hn := congrFun hab n
    by_cases ha : a n <;> by_cases hb : b n <;> simp [ha, hb] at hn ⊢
  have hcard : Cardinal.mk (ℕ → Bool) ≤ Cardinal.aleph0 :=
    Cardinal.mk_le_aleph0_iff.mpr hb
  rw [Cardinal.mk_arrow] at hcard
  simp only [Cardinal.mk_bool, Cardinal.mk_nat, Cardinal.lift_id] at hcard
  exact absurd hcard (not_le.mpr (Cardinal.cantor' _ (by norm_num)))

end LFunctionUniverse