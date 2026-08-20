/-
# The classical discrete Fourier transform on `ZMod n`

This file specialises the representation-theoretic Fourier transform of
`Catalog.Shared.FourierFiniteAbelian` to the cyclic group `ZMod n`, where the characters are the
`n`-th roots of unity `x ↦ e^{2πi k x / n}`.  We show that the abstract transform coincides with
the classical DFT matrix `F_{k,x} = e^{-2πi k x / n}` and transfer inversion, Parseval, the
convolution theorem and the uncertainty principle to that concrete setting.

Main results:

* `FourierCyclic.chr_apply` : the standard characters of `ZMod n` are the roots of unity.
* `FourierCyclic.dftZMod_eq` : the classical DFT equals the abstract DFT at the standard character.
* `FourierCyclic.dftZMod_inversion` : the classical inversion formula.
* `FourierCyclic.dftZMod_parseval` : `∑_k |f̂(k)|² = n * ∑_x |f(x)|²`.
* `FourierCyclic.dftZMod_conv` : the classical convolution theorem.
* `FourierCyclic.uncertainty_zmod` : `|supp f| * |supp f̂| ≥ n` for `f ≠ 0`.
-/

import Mathlib
import Catalog.Shared.FourierFiniteAbelian

open Finset ComplexConjugate FourierFA
open scoped Real

namespace FourierCyclic

variable {n : ℕ} [NeZero n]

/-- The standard character `x ↦ e^{2πi k x / n}` of the cyclic group `ZMod n`. -/
noncomputable def chr (k : ZMod n) : AddChar (ZMod n) ℂ := AddChar.zmodAddEquiv k

/-- The standard characters of `ZMod n` are exactly the roots of unity. -/
theorem chr_apply (k x : ZMod n) :
    chr k x = Complex.exp (2 * Real.pi * Complex.I * (k.val * x.val) / n) := by
  have h1 : (AddChar.zmod n k) x = Circle.exp (2 * Real.pi * ((k.val : ℝ) * (x.val : ℝ) / n)) := by
    conv_lhs => rw [← ZMod.natCast_zmod_val (a := k), ← ZMod.natCast_zmod_val (a := x)]
    have := AddChar.zmod_intCast n (k.val : ℤ) (x.val : ℤ)
    push_cast at this ⊢
    exact this
  show ((AddChar.zmod n k x : Circle) : ℂ) = _
  rw [h1, Circle.coe_exp]
  push_cast
  ring_nf

/-- `chr` is injective: distinct residues give distinct characters. -/
theorem chr_injective : Function.Injective (chr : ZMod n → AddChar (ZMod n) ℂ) := by
  intro a b hab
  exact AddChar.zmodAddEquiv.injective hab

/-- `chr` is surjective onto the dual group. -/
theorem chr_surjective : Function.Surjective (chr : ZMod n → AddChar (ZMod n) ℂ) := by
  intro ψ
  exact ⟨AddChar.zmodAddEquiv.symm ψ, by simp [chr]⟩

/-- The classical discrete Fourier transform on `ZMod n`. -/
noncomputable def dftZMod (f : ZMod n → ℂ) (k : ZMod n) : ℂ :=
  ∑ x : ZMod n, Complex.exp (-(2 * Real.pi * Complex.I * (k.val * x.val)) / n) * f x

/-- The classical DFT is the abstract DFT evaluated at the standard characters. -/
theorem dftZMod_eq (f : ZMod n → ℂ) (k : ZMod n) : dftZMod f k = dft f (chr k) := by
  rw [dftZMod, dft]
  refine Finset.sum_congr rfl fun x _ => ?_
  congr 1
  rw [chr_apply, ← Complex.exp_conj]
  congr 1
  simp only [map_div₀, map_mul, Complex.conj_I, Complex.conj_ofReal, Complex.conj_natCast,
    map_ofNat]
  ring

/-- **Fourier inversion** for the classical DFT on `ZMod n`. -/
theorem dftZMod_inversion (f : ZMod n → ℂ) (x : ZMod n) :
    f x = (n : ℂ)⁻¹ * ∑ k : ZMod n,
      Complex.exp (2 * Real.pi * Complex.I * (k.val * x.val) / n) * dftZMod f k := by
  have hcard : Fintype.card (ZMod n) = n := ZMod.card n
  have h : idft (dft f) x = f x := by rw [dft_inversion]
  rw [idft, hcard] at h
  rw [← h]
  congr 1
  rw [← Equiv.sum_comp (AddChar.zmodAddEquiv (n := n)).toEquiv
      (fun ψ : AddChar (ZMod n) ℂ => ψ x * dft f ψ)]
  refine Finset.sum_congr rfl fun k _ => ?_
  rw [dftZMod_eq]
  congr 1
  rw [← chr_apply]
  rfl

/-- **Parseval's theorem** for the classical DFT on `ZMod n`. -/
theorem dftZMod_parseval (f : ZMod n → ℂ) :
    ∑ k : ZMod n, ‖dftZMod f k‖ ^ 2 = (n : ℝ) * ∑ x : ZMod n, ‖f x‖ ^ 2 := by
  have hcard : Fintype.card (ZMod n) = n := ZMod.card n
  have h := parseval_norm f
  rw [hcard] at h
  rw [← h]
  rw [← Equiv.sum_comp (AddChar.zmodAddEquiv (n := n)).toEquiv
      (fun ψ : AddChar (ZMod n) ℂ => ‖dft f ψ‖ ^ 2)]
  exact Finset.sum_congr rfl fun k _ => by rw [dftZMod_eq]; rfl

/-- **Convolution theorem** for the classical DFT on `ZMod n`. -/
theorem dftZMod_conv (f g : ZMod n → ℂ) (k : ZMod n) :
    dftZMod (conv f g) k = dftZMod f k * dftZMod g k := by
  rw [dftZMod_eq, dftZMod_eq, dftZMod_eq, dft_conv]

/-- The support of the classical DFT matches the support of the abstract one. -/
theorem supp_dft_eq_image (f : ZMod n → ℂ) :
    supp (dft f) = (supp (dftZMod f)).image chr := by
  ext ψ
  rw [mem_supp, Finset.mem_image]
  constructor
  · intro h
    obtain ⟨k, rfl⟩ := chr_surjective ψ
    exact ⟨k, mem_supp.2 (by rwa [dftZMod_eq]), rfl⟩
  · rintro ⟨k, hk, rfl⟩
    rw [← dftZMod_eq]
    exact mem_supp.1 hk

/-- **Uncertainty principle** for the classical DFT on the cyclic group `ZMod n`. -/
theorem uncertainty_zmod (f : ZMod n → ℂ) (hf : f ≠ 0) :
    n ≤ (supp f).card * (supp (dftZMod f)).card := by
  have hcard : Fintype.card (ZMod n) = n := ZMod.card n
  have h := uncertainty f hf
  rw [hcard, supp_dft_eq_image f, Finset.card_image_of_injective _ chr_injective] at h
  exact h

/-- Sharpness in the cyclic case: the Dirac delta at `a` attains equality. -/
theorem uncertainty_zmod_sharp (a : ZMod n) :
    (supp (delta a)).card * (supp (dftZMod (delta a))).card = n := by
  have hcard : Fintype.card (ZMod n) = n := ZMod.card n
  have h := uncertainty_sharp_delta a
  rw [hcard, supp_dft_eq_image (delta a),
    Finset.card_image_of_injective _ chr_injective] at h
  exact h

end FourierCyclic