import Mathlib

/-!
# Functional equations enforce primitivity: the genuine root-number reciprocity law

This file **deepens** the analysis in `FunctionalEquationPrimitivity.lean`.  There the
root-number reciprocity law was proved only in *identity form*
`W(χ)·W(χ⁻¹)·Λ(χ,s) = Λ(χ,s)`, deliberately avoiding a non-vanishing hypothesis so that the
statement stayed unconditional.  Here we upgrade it to the genuine equality
`W(χ)·W(χ⁻¹) = 1` in the setting where the arithmetic of Gauss sums is fully available,
namely a **prime modulus** `p`, where `ZMod p` is a field and the standard additive
character is primitive.

The engine is the Gauss-sum identity `gaussSum χ ψ · gaussSum χ⁻¹ ψ⁻¹ = #(ZMod p)` for a
nontrivial multiplicative character `χ` against a primitive additive character `ψ`.  Feeding
in `ψ = stdAddChar` and the reflection `χ(-1)·gaussSum χ⁻¹ ψ⁻¹ = gaussSum χ⁻¹ ψ` turns this
into `gaussSum χ ψ · gaussSum χ⁻¹ ψ = χ(-1)·p`.  Dividing by the Archimedean factor and by
`p` — and observing that the parity factor `I^{2a}` cancels `χ(-1)` exactly — yields the
clean reciprocity `W(χ)·W(χ⁻¹) = 1`.

## Main results

* `FEPrimitivityDeep.inv_even_iff` — inversion preserves parity of a Dirichlet character.
* `FEPrimitivityDeep.gaussSum_mul_gaussSum_inv_stdAddChar` — the same-character Gauss-sum
  product `gaussSum χ · gaussSum χ⁻¹ = χ(-1)·p`.
* `FEPrimitivityDeep.rootNumber_mul_rootNumber_inv` — **genuine reciprocity** `W(χ)·W(χ⁻¹) = 1`.
* `FEPrimitivityDeep.rootNumber_ne_zero` — the root number of a nontrivial character mod `p`
  is non-zero.
* `FEPrimitivityDeep.rootNumber_inv_eq_inv` — `W(χ⁻¹) = W(χ)⁻¹`.
* `FEPrimitivityDeep.rootNumber_sq_self_dual` — for a real character, `W(χ)² = 1`, i.e. the
  root number of a quadratic character is a sign.
* `FEPrimitivityDeep.completedLFunction_inv_eq` — reflection identity rewritten through the
  genuine reciprocity, expressing `Λ(χ⁻¹, s)` from `Λ(χ, 1-s)`.
-/

namespace FEPrimitivityDeep

open DirichletCharacter Complex
open ZMod (stdAddChar isPrimitive_stdAddChar)

/-! ### Inversion preserves parity -/

/-- Inversion of a Dirichlet character preserves parity: `χ` is even iff `χ⁻¹` is even. -/
lemma inv_even_iff {N : ℕ} [NeZero N] (χ : DirichletCharacter ℂ N) :
    χ.Even ↔ χ⁻¹.Even := by
  unfold DirichletCharacter.Even
  rw [MulChar.inv_apply_eq_inv' χ (-1), inv_eq_one]

/-! ### The same-character Gauss-sum product for a prime modulus -/

/-- For a prime modulus `p` and a nontrivial Dirichlet character `χ`, the product of the
Gauss sums of `χ` and `χ⁻¹` against the *same* standard additive character equals
`χ(-1)·p`.  This is the field-case Gauss-sum reciprocity, with the additive-character
inversion folded in via `mul_gaussSum_inv_eq_gaussSum`. -/
theorem gaussSum_mul_gaussSum_inv_stdAddChar {p : ℕ} [Fact p.Prime]
    (χ : DirichletCharacter ℂ p) (hχ : χ ≠ 1) :
    gaussSum χ stdAddChar * gaussSum χ⁻¹ stdAddChar = χ (-1) * (p : ℂ) := by
  have hprim := isPrimitive_stdAddChar p
  have hcard := gaussSum_mul_gaussSum_eq_card (χ := χ) hχ hprim
  have hinv := mul_gaussSum_inv_eq_gaussSum χ⁻¹ (stdAddChar (N := p))
  have hsq : χ (-1) * χ (-1) = 1 := by rw [← map_mul]; norm_num
  have hne : χ (-1) ≠ 0 := by intro h; rw [h, mul_zero] at hsq; exact zero_ne_one hsq
  have hxinv : χ⁻¹ (-1) = (χ (-1))⁻¹ := MulChar.inv_apply_eq_inv' χ (-1)
  have hconv : gaussSum χ⁻¹ stdAddChar⁻¹ = χ (-1) * gaussSum χ⁻¹ stdAddChar := by
    have h2 := congrArg (fun z => χ (-1) * z) hinv
    simp only [hxinv, ← mul_assoc, mul_inv_cancel₀ hne, one_mul] at h2
    exact h2
  rw [hconv, ZMod.card] at hcard
  have hkey : χ (-1) * (gaussSum χ stdAddChar * gaussSum χ⁻¹ stdAddChar) = (p : ℂ) := by
    rw [← hcard]; ring
  calc gaussSum χ stdAddChar * gaussSum χ⁻¹ stdAddChar
      = χ (-1) * χ (-1) * (gaussSum χ stdAddChar * gaussSum χ⁻¹ stdAddChar) := by
        rw [hsq, one_mul]
    _ = χ (-1) * (χ (-1) * (gaussSum χ stdAddChar * gaussSum χ⁻¹ stdAddChar)) := by ring
    _ = χ (-1) * (p : ℂ) := by rw [hkey]

/-! ### Genuine root-number reciprocity -/

/-- **Genuine root-number reciprocity for a prime modulus.**  For a nontrivial Dirichlet
character `χ` modulo a prime `p`, the root numbers of `χ` and `χ⁻¹` are genuine
multiplicative inverses: `W(χ)·W(χ⁻¹) = 1`.  This upgrades the identity-form reciprocity of
`FunctionalEquationPrimitivity.lean` to an honest equality of complex numbers. -/
theorem rootNumber_mul_rootNumber_inv {p : ℕ} [Fact p.Prime]
    (χ : DirichletCharacter ℂ p) (hχ : χ ≠ 1) :
    rootNumber χ * rootNumber χ⁻¹ = 1 := by
  classical
  have hgs := gaussSum_mul_gaussSum_inv_stdAddChar χ hχ
  have hpar : (χ.Even ↔ χ⁻¹.Even) := inv_even_iff χ
  have hp0 : (p : ℂ) ≠ 0 := by exact_mod_cast (Fact.out (p := p.Prime)).ne_zero
  have hpsq : ((p : ℂ) ^ (1/2 : ℂ)) ^ 2 = (p : ℂ) := by
    rw [sq, ← Complex.cpow_add _ _ hp0]; norm_num
  have hpsq0 : ((p : ℂ) ^ (1/2 : ℂ)) ≠ 0 := by
    intro h; rw [h] at hpsq; simp at hpsq; exact hp0 hpsq.symm
  unfold rootNumber
  rw [show (if χ⁻¹.Even then 0 else 1) = (if χ.Even then (0:ℕ) else 1) by
        by_cases h : χ.Even
        · rw [if_pos h, if_pos (hpar.mp h)]
        · rw [if_neg h, if_neg (fun hc => h (hpar.mpr hc))]]
  by_cases hev : χ.Even
  · simp only [hev, if_true, pow_zero, div_one]
    have hx1 : χ (-1) = 1 := hev
    field_simp
    rw [hgs, hx1, hpsq]; ring
  · simp only [hev, if_false, pow_one]
    have hx1 : χ (-1) = -1 := (χ.even_or_odd.resolve_left hev)
    field_simp
    rw [hgs, hx1, hpsq]; ring_nf; rw [Complex.I_sq]; ring

/-- The root number of a nontrivial Dirichlet character modulo a prime is non-zero. -/
theorem rootNumber_ne_zero {p : ℕ} [Fact p.Prime]
    (χ : DirichletCharacter ℂ p) (hχ : χ ≠ 1) :
    rootNumber χ ≠ 0 := by
  intro h
  have := rootNumber_mul_rootNumber_inv χ hχ
  rw [h, zero_mul] at this
  exact zero_ne_one this

/-- The root number of `χ⁻¹` is the inverse of the root number of `χ` (prime modulus). -/
theorem rootNumber_inv_eq_inv {p : ℕ} [Fact p.Prime]
    (χ : DirichletCharacter ℂ p) (hχ : χ ≠ 1) :
    rootNumber χ⁻¹ = (rootNumber χ)⁻¹ := by
  have hprod := rootNumber_mul_rootNumber_inv χ hχ
  field_simp [rootNumber_ne_zero χ hχ] at hprod ⊢
  linear_combination hprod

/-- **Root number of a quadratic character is a sign.**  A nontrivial real (self-dual)
character modulo a prime satisfies `W(χ)² = 1`. -/
theorem rootNumber_sq_self_dual {p : ℕ} [Fact p.Prime]
    (χ : DirichletCharacter ℂ p) (hχ : χ ≠ 1) (hself : χ⁻¹ = χ) :
    rootNumber χ ^ 2 = 1 := by
  have := rootNumber_mul_rootNumber_inv χ hχ
  rw [hself] at this
  rw [sq]; exact this

/-! ### Reflection identity through genuine reciprocity -/

/-- With genuine reciprocity available, the functional equation for a primitive character
modulo a prime can be solved for `Λ(χ⁻¹, s)`: dividing the reflection identity by
`N^{s-1/2}·W(χ)` (both non-zero) recovers the dual completed `L`-function. -/
theorem completedLFunction_inv_eq {p : ℕ} [Fact p.Prime]
    {χ : DirichletCharacter ℂ p} (hχ : χ.IsPrimitive) (hne : χ ≠ 1) (s : ℂ) :
    DirichletCharacter.completedLFunction χ⁻¹ s
      = (p : ℂ) ^ (-(s - 1 / 2)) * rootNumber χ⁻¹
          * DirichletCharacter.completedLFunction χ (1 - s) := by
  have hp0 : (p : ℂ) ≠ 0 := by exact_mod_cast (Fact.out (p := p.Prime)).ne_zero
  have hrefl := hχ.completedLFunction_one_sub s
  have hcpow : (p:ℂ)^(-(s-1/2)) * (p:ℂ)^(s-1/2) = 1 := by
    rw [← Complex.cpow_add _ _ hp0]; simp
  have hrec : rootNumber χ⁻¹ * rootNumber χ = 1 := by
    rw [mul_comm]; exact rootNumber_mul_rootNumber_inv χ hne
  rw [hrefl]
  symm
  calc (p : ℂ) ^ (-(s - 1 / 2)) * rootNumber χ⁻¹
        * ((p:ℂ)^(s-1/2) * rootNumber χ * DirichletCharacter.completedLFunction χ⁻¹ s)
      = ((p:ℂ)^(-(s-1/2))*(p:ℂ)^(s-1/2)) * (rootNumber χ⁻¹ * rootNumber χ)
          * DirichletCharacter.completedLFunction χ⁻¹ s := by ring
    _ = DirichletCharacter.completedLFunction χ⁻¹ s := by rw [hcpow, hrec]; ring

end FEPrimitivityDeep