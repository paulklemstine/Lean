import Mathlib

/-!
# Norm rigidity of quaternion conjugation

This file addresses the algebraic core of **Conjecture 5** of the
"Composition-Algebra Playground" research direction.

For a nonzero quaternion `q`, the conjugation map `x ↦ q * x * q⁻¹` preserves the
quaternionic norm for **every** `x` — not merely for unit `q`, and not merely on
the unit sphere.  This is the computation underlying the classical covers
`S³ → SO(3)` and `S³ × S³ → SO(4)`: because norm-preservation holds for all
nonzero `q`, the action factors through the projective unit group.

Everything follows from the multiplicativity of `Quaternion.normSq`
(it is a `MonoidWithZeroHom`) together with `map_inv₀`.
-/

open Quaternion

namespace QuaternionConjugation

variable {R : Type*} [CommRing R]

/-- Quaternion conjugation by a nonzero `q`. -/
noncomputable def conj (q x : ℍ[ℝ]) : ℍ[ℝ] := q * x * q⁻¹

/--
**Norm-square rigidity.**  Conjugation by any nonzero quaternion preserves
`normSq` for every `x`.
-/
theorem normSq_conj (q x : ℍ[ℝ]) (hq : q ≠ 0) :
    Quaternion.normSq (conj q x) = Quaternion.normSq x := by
  simp +decide [ conj ];
  exact mul_div_cancel_left₀ _ ( by simpa [ Quaternion.normSq_eq_zero ] using hq )

/--
**Norm rigidity.**  Conjugation by any nonzero quaternion preserves the
quaternionic norm for every `x`.
-/
theorem norm_conj (q x : ℍ[ℝ]) (hq : q ≠ 0) : ‖conj q x‖ = ‖x‖ := by
  convert congr_arg Real.sqrt ( normSq_conj q x hq ) using 1

/--
Conjugation fixes the scalar (real) axis.
-/
theorem conj_coe (q : ℍ[ℝ]) (c : ℝ) (hq : q ≠ 0) : conj q (c : ℍ[ℝ]) = (c : ℍ[ℝ]) := by
  unfold conj;
  rw [ mul_assoc, Quaternion.coe_commute ];
  rw [ ← mul_assoc, mul_inv_cancel₀ hq, one_mul ]

/--
Conjugation is multiplicative: it is an inner algebra automorphism.
-/
theorem conj_mul (q x y : ℍ[ℝ]) (hq : q ≠ 0) :
    conj q (x * y) = conj q x * conj q y := by
  simp +decide [hq, mul_assoc, conj]

/--
For a **unit** quaternion the conjugation map is an isometry of `S³`
(indeed of all of `ℍ`), since `‖q‖ = 1 ≠ 0`.
-/
theorem norm_conj_of_unit (q x : ℍ[ℝ]) (hq : ‖q‖ = 1) : ‖conj q x‖ = ‖x‖ := by
  exact norm_conj q x ( by rintro rfl; norm_num at hq )

end QuaternionConjugation