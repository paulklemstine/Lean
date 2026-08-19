/-
# Fourier invariance of extremality, and the shape of the support pair

Two capstone consequences of the classification of extremals
(`Catalog.Probability.FourierExtremalConverse`):

* the *support pair* of an extremal function is a coset of a subgroup together with a coset of
  its annihilator (`FourierFA.isExtremal_supports`), which is the sharp form of
  `|supp f| * |supp f̂| = |G|`;
* extremality is **invariant under the Fourier transform**: if `f` is extremal on `G` then `f̂`
  is extremal on the dual group (`FourierFA.isExtremal_dft`). The proof goes through Pontryagin
  duality, since `F² = |G| · reflection`.
-/

import Mathlib
import Shared.FourierFiniteAbelian
import Shared.FourierSubgroupDuality
import Shared.FourierExtremals
import Probability.FourierExtremalConverse
import Probability.FourierExtremalConvolution

open Finset ComplexConjugate

namespace FourierFA

variable {G : Type*} [AddCommGroup G] [Fintype G] [DecidableEq G]

/-! ## The support pair of an extremal function -/

/-- **The support pair of an extremal function.** If `f ≠ 0` is extremal, then `supp f` is a
coset of a subgroup `K` and `supp f̂` is a coset of the annihilator `K^⊥`. -/
theorem isExtremal_supports (f : G → ℂ) (hf : f ≠ 0) (hext : IsExtremal f) :
    ∃ (K : AddSubgroup G) (a : G) (χ : AddChar G ℂ),
      (∀ x, x ∈ supp f ↔ x - a ∈ K) ∧ (∀ ψ, ψ ∈ supp (dft f) ↔ ψ - χ ∈ annihSub K) := by
  obtain ⟨K, χ, a, c, hc, h1, h2⟩ := exists_coset_modulation_of_isExtremal f hf hext
  refine ⟨K, a, χ, fun x => ⟨?_, ?_⟩, fun ψ => ?_⟩
  · intro hx
    by_contra hxK
    exact (mem_supp.1 hx) (h2 x hxK)
  · intro hx
    refine mem_supp.2 ?_
    rw [h1 x hx]
    refine mul_ne_zero hc ?_
    intro h0
    have := AddChar.norm_apply χ x
    rw [h0] at this
    simp at this
  · rw [mem_supp]
    exact dft_ne_zero_iff_of_coset_values hc h1 h2 ψ

/-! ## Fourier invariance of extremality -/

/-- The support of the twice-transformed function is the reflection of `supp f` inside the
double dual. -/
theorem card_supp_dft_dft (f : G → ℂ) :
    (supp (dft (dft f))).card = (supp f).card := by
  classical
  have hN : (Fintype.card G : ℂ) ≠ 0 := by exact_mod_cast (Fintype.card_ne_zero (α := G))
  have himg : supp (dft (dft f))
      = (supp f).image (fun x => AddChar.doubleDualEmb (-x)) := by
    ext Θ
    rw [mem_supp, Finset.mem_image]
    constructor
    · intro hΘ
      obtain ⟨x, rfl⟩ := AddChar.doubleDualEmb_bijective.surjective Θ
      rw [dft_dft] at hΘ
      refine ⟨-x, mem_supp.2 ?_, by rw [neg_neg]⟩
      intro h0
      rw [h0, mul_zero] at hΘ
      exact hΘ rfl
    · rintro ⟨x, hx, rfl⟩
      rw [dft_dft, neg_neg]
      exact mul_ne_zero hN (mem_supp.1 hx)
  have hinj : Function.Injective
      (fun x : G => (AddChar.doubleDualEmb (-x) : AddChar (AddChar G ℂ) ℂ)) := by
    intro x y h
    simp only at h
    have hxy : (-x) = (-y) := AddChar.doubleDualEmb_injective h
    simpa using hxy
  rw [himg, Finset.card_image_of_injective _ hinj]

/-- **Extremality is a Fourier-invariant notion.** If `f` attains equality in the uncertainty
principle on `G`, then its Fourier transform attains equality on the dual group. -/
theorem isExtremal_dft (f : G → ℂ) (hext : IsExtremal f) :
    (supp (dft f)).card * (supp (dft (dft f))).card = Fintype.card (AddChar G ℂ) := by
  rw [card_supp_dft_dft, AddChar.card_eq, mul_comm]
  exact hext

end FourierFA