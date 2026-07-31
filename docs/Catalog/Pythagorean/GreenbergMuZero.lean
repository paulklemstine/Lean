import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.LinearAlgebra.Dimension.Finite
import Mathlib.LinearAlgebra.AnnihilatingPolynomial

namespace GreenbergMuZero

open scoped BigOperators

section Averaging

variable {G k V : Type*} [Group G] [Fintype G]
  [Field k] [AddCommGroup V] [Module k V]

/-- A degree-one cocycle for a finite group action is a coboundary when the group
order is invertible in the coefficient field.  This is the finite-level averaging
step behind the prime-to-`ℓ` cohomology vanishing used in the paper. -/
theorem one_cocycle_is_coboundary
    (ρ : G → V →ₗ[k] V)
    (c : G → V)
    (cocycle : ∀ g h, c (g * h) = c g + ρ g (c h))
    (hcard : (Fintype.card G : k) ≠ 0) :
    ∃ v : V, ∀ g : G, c g = v - ρ g v := by
  let S : V := ∑ h : G, c h
  let v : V := (Fintype.card G : k)⁻¹ • S
  use v
  intro g
  have h1 : ρ g v = (Fintype.card G : k)⁻¹ • (∑ h : G, ρ g (c h)) := by
    simp only [v, S]
    rw [map_smul, map_sum]
  have h2 : ∑ h : G, ρ g (c h) = ∑ h : G, (c (g * h) - c g) := by
    refine Finset.sum_congr rfl fun h _ => ?_
    have := cocycle g h
    rw [this]; simp
  have h3 : ∑ h : G, (c (g * h) - c g) = (∑ h : G, c (g * h)) - Fintype.card G • c g := by
    rw [Finset.sum_sub_distrib]
    simp [Finset.card_univ]
  have h4 : ∑ h : G, c (g * h) = S := by
    simp only [S]
    exact Equiv.sum_comp (Equiv.mulLeft g) c
  have h5 : ∑ h : G, ρ g (c h) = S - Fintype.card G • c g := by
    rw [h2, h3, h4]
  have h6 : ρ g v = v - c g := by
    rw [h1, h5]
    simp [v]
    rw [smul_sub]
    congr 1
    have : (Fintype.card G : ℕ) • c g = (Fintype.card G : k) • c g := by
      rw [← Nat.cast_smul_eq_nsmul k]
    rw [this, smul_smul, inv_mul_cancel₀ hcard, one_smul]
  rw [h6]
  simp

/-- In particular, a homomorphism from a finite group to a vector space over a
field of characteristic prime to the group order must vanish. -/
theorem hom_to_additive_group_eq_zero
    (c : G → V)
    (c_mul : ∀ g h, c (g * h) = c g + c h)
    (hcard : (Fintype.card G : k) ≠ 0) :
    ∀ g : G, c g = 0 := by
  let ρ : G → V →ₗ[k] V := fun _ ↦ LinearMap.id
  have cocycle : ∀ g h, c (g * h) = c g + ρ g (c h) := by
    intro g h
    simpa [ρ] using c_mul g h
  obtain ⟨v, hv⟩ := one_cocycle_is_coboundary ρ c cocycle hcard
  intro g
  simpa [ρ] using hv g

end Averaging

section PolynomialTorsion

variable {k V : Type*} [Field k] [AddCommGroup V] [Module k V]

/-- An endomorphism of a finite-dimensional vector space is annihilated by a
nonzero polynomial.  For an Iwasawa generator acting after reduction modulo
`ℓ`, this gives the algebraic torsion mechanism used with finite cohomology. -/
theorem finite_dimensional_endomorphism_has_annihilator
    [FiniteDimensional k V] (φ : Module.End k V) :
    ∃ p : Polynomial k, p ≠ 0 ∧ Polynomial.aeval φ p = 0 := by
  obtain ⟨p, hpmonic, hp⟩ :=
    (Module.End.isIntegral (R := k) (M := V)).isIntegral φ
  exact ⟨p, hpmonic.ne_zero, by simpa [Polynomial.aeval_def] using hp⟩

/-- Every vector in a finite-dimensional representation of one Iwasawa
operator is killed by one common nonzero polynomial. -/
theorem finite_dimensional_endomorphism_is_polynomial_torsion
    [FiniteDimensional k V] (φ : Module.End k V) (v : V) :
    ∃ p : Polynomial k, p ≠ 0 ∧ (Polynomial.aeval φ p) v = 0 := by
  obtain ⟨p, hp0, hp⟩ := finite_dimensional_endomorphism_has_annihilator φ
  exact ⟨p, hp0, by rw [hp]; rfl⟩

end PolynomialTorsion

end GreenbergMuZero