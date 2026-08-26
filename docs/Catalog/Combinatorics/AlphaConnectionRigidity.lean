import Mathlib
import Probability.InformationGeometryContrarian

/-!
# Rigidity of the canonical α-family

The catalog file `Probability/InformationGeometryContrarian.lean` *defines* the
lower-index natural-coordinate coefficients of the α-connection by the formula
`((1 - α) / 2) C`.  Why that formula and no other?

This file answers the question with a rigidity (uniqueness) theorem of
Cauchy-functional-equation type: the affine coefficient function
`α ↦ (1 - α) / 2` is the *unique* continuous coefficient function compatible
with the three structural axioms of the theory,

* **e-flatness**: the coefficient vanishes at `α = 1`;
* **duality**: opposite α's split the Amari–Chentsov tensor, `F α + F (-α) = 1`;
* **translation covariance of increments**: shifting the α-parameter by a
  constant shifts all coefficients by the same amount,
  `F (α + β) = F α + F β - F 0`.

The last axiom expresses that the α-family is a one-parameter *affine* pencil of
connections: its increments only depend on the difference of the α's.

We then use the rigidity theorem to characterise degeneracy of the pencil: two
distinct α-connections coincide if and only if the Amari–Chentsov tensor
vanishes.
-/

noncomputable section

namespace AlphaConnectionRigidity

open InformationGeometryContrarian

/-- The coefficient function of the canonical α-family. -/
def canonicalCoeff (α : ℝ) : ℝ := (1 - α) / 2

lemma canonicalCoeff_one : canonicalCoeff 1 = 0 := by
  simp [canonicalCoeff]

lemma canonicalCoeff_dual (α : ℝ) : canonicalCoeff α + canonicalCoeff (-α) = 1 := by
  unfold canonicalCoeff; ring

lemma canonicalCoeff_affine (α β : ℝ) :
    canonicalCoeff (α + β) = canonicalCoeff α + canonicalCoeff β - canonicalCoeff 0 := by
  unfold canonicalCoeff; ring

lemma canonicalCoeff_continuous : Continuous canonicalCoeff := by
  unfold canonicalCoeff; fun_prop

/-- Duality at `α = 0` pins the Levi–Civita coefficient to `1 / 2`. -/
lemma coeff_zero_of_dual {F : ℝ → ℝ} (hdual : ∀ α, F α + F (-α) = 1) :
    F 0 = 1 / 2 := by
  have h := hdual 0
  simp at h
  linarith

/-- The centred coefficient function is additive. -/
lemma centred_additive {F : ℝ → ℝ}
    (haff : ∀ α β, F (α + β) = F α + F β - F 0) (α β : ℝ) :
    (F (α + β) - F 0) = (F α - F 0) + (F β - F 0) := by
  rw [haff α β]; ring

/-- **Rigidity of the canonical α-family.**  A continuous coefficient function
that is e-flat at `α = 1`, dual under `α ↦ -α`, and affine in the α-parameter
must be `(1 - α) / 2`.  Continuity is genuinely needed: without a regularity
assumption the additive part is an arbitrary `ℚ`-linear (Hamel) map. -/
theorem alpha_coeff_rigidity {F : ℝ → ℝ} (hcont : Continuous F)
    (hone : F 1 = 0) (hdual : ∀ α, F α + F (-α) = 1)
    (haff : ∀ α β, F (α + β) = F α + F β - F 0) :
    ∀ α, F α = (1 - α) / 2 := by
  have hzero : F 0 = 1 / 2 := coeff_zero_of_dual hdual
  -- the centred function is an additive, continuous map, hence `ℝ`-linear
  set G : ℝ → ℝ := fun α => F α - F 0 with hG
  have hGadd : ∀ α β, G (α + β) = G α + G β := fun α β => centred_additive haff α β
  have hGcont : Continuous G := hcont.sub continuous_const
  let Gh : ℝ →+ ℝ :=
    { toFun := G
      map_zero' := by
        have := hGadd 0 0
        simp at this
        linarith
      map_add' := hGadd }
  have hGlin : ∀ α : ℝ, G α = α * G 1 := by
    intro α
    have hGcont' : Continuous ⇑Gh := hGcont
    have key : ∀ y : ℝ, (Gh.toRealLinearMap hGcont') y = G y :=
      fun y => congrFun (AddMonoidHom.coe_toRealLinearMap Gh hGcont') y
    have hmap : (Gh.toRealLinearMap hGcont') α
        = α • (Gh.toRealLinearMap hGcont') 1 := by
      simpa using (Gh.toRealLinearMap hGcont').map_smul α (1 : ℝ)
    rw [key, key] at hmap
    simpa using hmap
  intro α
  have h1 : G 1 = -(1 / 2) := by
    simp [hG, hone, hzero]
  have := hGlin α
  rw [h1] at this
  have hFα : F α - F 0 = α * (-(1 / 2)) := this
  rw [hzero] at hFα
  linarith

/-- The rigidity theorem, transported to the catalog's Christoffel coefficients:
any structurally admissible one-parameter family of lower-index coefficients
agrees with `naturalAlphaChristoffel`. -/
theorem alpha_christoffel_rigidity {d : ℕ} {F : ℝ → ℝ} (hcont : Continuous F)
    (hone : F 1 = 0) (hdual : ∀ α, F α + F (-α) = 1)
    (haff : ∀ α β, F (α + β) = F α + F β - F 0)
    (C : Fin d → Fin d → Fin d → ℝ) (α : ℝ) (i j k : Fin d) :
    F α * C i j k = naturalAlphaChristoffel α C i j k := by
  rw [alpha_coeff_rigidity hcont hone hdual haff α]
  rfl

/-- **Degeneracy criterion for the α-pencil.**  Two distinct members of the
α-family have the same natural-coordinate coefficients exactly when the
Amari–Chentsov tensor vanishes identically. -/
theorem alpha_pencil_degenerate_iff {d : ℕ} (C : Fin d → Fin d → Fin d → ℝ)
    {α β : ℝ} (hαβ : α ≠ β) :
    (∀ i j k, naturalAlphaChristoffel α C i j k
      = naturalAlphaChristoffel β C i j k) ↔ ∀ i j k, C i j k = 0 := by
  constructor
  · intro h i j k
    have hik := h i j k
    unfold naturalAlphaChristoffel at hik
    have hfac : ((β - α) / 2) * C i j k = 0 := by linarith
    rcases mul_eq_zero.mp hfac with h' | h'
    · exact absurd (by linarith : α = β) hαβ
    · exact h'
  · intro h i j k
    unfold naturalAlphaChristoffel
    rw [h i j k, mul_zero, mul_zero]

/-- The Levi–Civita member is the unique self-dual member of the pencil: it is
the only `α` whose coefficients coincide with those of `-α`, unless the cubic
tensor is degenerate. -/
theorem selfdual_iff_leviCivita {d : ℕ} (C : Fin d → Fin d → Fin d → ℝ)
    {i j k : Fin d} (hC : C i j k ≠ 0) (α : ℝ) :
    naturalAlphaChristoffel α C i j k = naturalAlphaChristoffel (-α) C i j k
      ↔ α = 0 := by
  unfold naturalAlphaChristoffel
  constructor
  · intro h
    have hfac : α * C i j k = 0 := by linarith
    exact (mul_eq_zero.mp hfac).resolve_right hC
  · rintro rfl; ring

end AlphaConnectionRigidity