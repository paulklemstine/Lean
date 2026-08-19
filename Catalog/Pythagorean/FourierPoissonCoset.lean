/-
# Affine (coset) Poisson summation and its converse

`Catalog.Pythagorean.FourierPoissonConverse` shows that the *exact* Poisson identity
singles out subgroups.  Subgroups are however not translation invariant, whereas the two
sides of Poisson summation transform very predictably under translation: replacing `f` by
`f (x₀ + ·)` multiplies each Fourier coefficient by the phase `ψ x₀`.

This file develops the resulting **affine** theory: the phase-twisted identity

  `|G| * ∑_{x ∈ S} f x = |S| * ∑_{ψ ∈ (S - x₀)^⊥} ψ x₀ * f̂ ψ`                    (P_{S,x₀})

and proves that it characterises **cosets** exactly as `(P_S)` characterises subgroups.

Main results:

* `FourierFA.dft_translate` : `(f (x₀ + ·))^ ψ = ψ x₀ * f̂ ψ`.
* `FourierFA.cosetPoissonSet_iff_poissonSet_translate` : `(P_{S,x₀})` for `S` is exactly
  `(P_T)` for the translate `T = S - x₀`.
* `FourierFA.cosetPoissonSet_iff_coset` : for nonempty `S` and `x₀ ∈ S`, `(P_{S,x₀})` holds
  **iff** `S` is a coset of a subgroup, `S = x₀ + H`.
* `FourierFA.cosetPoissonSet_of_coset` : the "if" direction, i.e. affine Poisson summation.
* `FourierFA.not_cosetPoissonSet_squares_zmod8` : the squares mod `8` are not even a coset,
  so no choice of base point rescues Poisson summation for them.
-/

import Mathlib
import Pythagorean.FourierPoissonUncertainty

open Finset Fintype ComplexConjugate
open scoped Classical

namespace FourierFA

variable {G : Type*} [AddCommGroup G] [Fintype G] [DecidableEq G]

/-! ## Translation and the Fourier transform -/

omit [DecidableEq G] in
/-- Translating the argument multiplies the Fourier coefficients by a phase. -/
theorem dft_translate (f : G → ℂ) (x₀ : G) (ψ : AddChar G ℂ) :
    dft (fun y => f (x₀ + y)) ψ = ψ x₀ * dft f ψ := by
  rw [dft, dft, Finset.mul_sum]
  rw [← Fintype.sum_equiv (Equiv.addLeft x₀) (fun y => conj (ψ y) * f (x₀ + y))
      (fun z => ψ x₀ * (conj (ψ z) * f z)) ?_]
  intro y
  have hzy : (Equiv.addLeft x₀) y = x₀ + y := rfl
  rw [hzy]
  have : ψ (x₀ + y) = ψ x₀ * ψ y := ψ.map_add_eq_mul x₀ y
  have hnorm : ψ x₀ * conj (ψ x₀) = 1 := by
    rw [← AddChar.map_neg_eq_conj, ← ψ.map_add_eq_mul]
    simp
  calc conj (ψ y) * f (x₀ + y)
      = (ψ x₀ * conj (ψ x₀)) * (conj (ψ y) * f (x₀ + y)) := by rw [hnorm, one_mul]
    _ = ψ x₀ * (conj (ψ x₀ * ψ y) * f (x₀ + y)) := by rw [map_mul]; ring
    _ = ψ x₀ * (conj (ψ (x₀ + y)) * f (x₀ + y)) := by rw [this]

/-! ## The affine Poisson property -/

/-- The translate `S - x₀` of a finset. -/
noncomputable def translateF (S : Finset G) (x₀ : G) : Finset G := S.image (fun x => x - x₀)

omit [Fintype G] in
@[simp] lemma mem_translateF {S : Finset G} {x₀ y : G} :
    y ∈ translateF S x₀ ↔ y + x₀ ∈ S := by
  simp only [translateF, Finset.mem_image]
  constructor
  · rintro ⟨x, hx, rfl⟩; simpa using hx
  · intro h; exact ⟨y + x₀, h, by abel⟩

omit [Fintype G] in
@[simp] lemma card_translateF (S : Finset G) (x₀ : G) :
    (translateF S x₀).card = S.card :=
  Finset.card_image_of_injective _ (fun a b hab => by
    have := congrArg (· + x₀) hab
    simpa using this)

/-- The phase-twisted (affine) Poisson property with base point `x₀`. -/
def CosetPoissonSet (S : Finset G) (x₀ : G) : Prop :=
  ∀ f : G → ℂ, (Fintype.card G : ℂ) * ∑ x ∈ S, f x
    = (S.card : ℂ) * ∑ ψ ∈ annihF (translateF S x₀), ψ x₀ * dft f ψ

omit [Fintype G] in
lemma sum_translateF (S : Finset G) (x₀ : G) (f : G → ℂ) :
    ∑ y ∈ translateF S x₀, f (x₀ + y) = ∑ x ∈ S, f x := by
  rw [translateF, Finset.sum_image (fun a _ b _ hab => by
    have := congrArg (· + x₀) hab
    simpa using this)]
  exact Finset.sum_congr rfl fun x _ => by rw [show x₀ + (x - x₀) = x by abel]

/-- **The affine identity is the plain identity for the translate.** -/
theorem cosetPoissonSet_iff_poissonSet_translate (S : Finset G) (x₀ : G) :
    CosetPoissonSet S x₀ ↔ PoissonSet (translateF S x₀) := by
  constructor
  · intro h g
    have hf := h (fun x => g (x - x₀))
    rw [card_translateF]
    have hL : ∑ x ∈ S, g (x - x₀) = ∑ y ∈ translateF S x₀, g y := by
      rw [← sum_translateF S x₀ (fun x => g (x - x₀))]
      exact Finset.sum_congr rfl fun y _ => by rw [show x₀ + y - x₀ = y by abel]
    have hR : ∀ ψ : AddChar G ℂ, ψ x₀ * dft (fun x => g (x - x₀)) ψ = dft g ψ := by
      intro ψ
      have : (fun y => (fun x => g (x - x₀)) (x₀ + y)) = g := by
        funext y; simp only; rw [show x₀ + y - x₀ = y by abel]
      have h2 := dft_translate (fun x => g (x - x₀)) x₀ ψ
      rw [this] at h2
      exact h2.symm
    rw [hL] at hf
    rw [hf]
    exact congrArg _ (Finset.sum_congr rfl fun ψ _ => hR ψ)
  · intro h f
    have hg := h (fun y => f (x₀ + y))
    rw [card_translateF, sum_translateF S x₀ f] at hg
    rw [hg]
    exact congrArg _ (Finset.sum_congr rfl fun ψ _ => (dft_translate f x₀ ψ))

/-- **Affine Poisson summation.**  Every coset `S = x₀ + H` of a subgroup satisfies the
phase-twisted identity with base point `x₀`. -/
theorem cosetPoissonSet_of_coset {S : Finset G} {x₀ : G} {H : AddSubgroup G}
    (hH : ∀ x, x ∈ S ↔ x - x₀ ∈ H) : CosetPoissonSet S x₀ := by
  rw [cosetPoissonSet_iff_poissonSet_translate]
  refine (poissonSet_iff).2 (Or.inr ⟨H, fun y => ?_⟩)
  rw [mem_translateF, hH (y + x₀), show y + x₀ - x₀ = y by abel]

/-- **Converse of affine Poisson summation: the identity characterises cosets.** -/
theorem cosetPoissonSet_iff_coset {S : Finset G} {x₀ : G} (hx₀ : x₀ ∈ S) :
    CosetPoissonSet S x₀ ↔ ∃ H : AddSubgroup G, ∀ x, x ∈ S ↔ x - x₀ ∈ H := by
  constructor
  · intro h
    rw [cosetPoissonSet_iff_poissonSet_translate] at h
    have hne : (translateF S x₀).Nonempty := ⟨0, mem_translateF.2 (by simpa using hx₀)⟩
    obtain ⟨H, hH⟩ := (poissonSet_iff_subgroup hne).1 h
    refine ⟨H, fun x => ?_⟩
    have := hH (x - x₀)
    rw [mem_translateF, show x - x₀ + x₀ = x by abel] at this
    exact this
  · rintro ⟨H, hH⟩
    exact cosetPoissonSet_of_coset hH

/-- Cosets are the only sets for which *some* base point works. -/
theorem exists_cosetPoissonSet_iff_coset {S : Finset G} :
    (∃ x₀ ∈ S, CosetPoissonSet S x₀)
      ↔ ∃ (x₀ : G) (H : AddSubgroup G), x₀ ∈ S ∧ ∀ x, x ∈ S ↔ x - x₀ ∈ H := by
  constructor
  · rintro ⟨x₀, hx₀, h⟩
    obtain ⟨H, hH⟩ := (cosetPoissonSet_iff_coset hx₀).1 h
    exact ⟨x₀, H, hx₀, hH⟩
  · rintro ⟨x₀, H, hx₀, hH⟩
    exact ⟨x₀, hx₀, cosetPoissonSet_of_coset hH⟩

/-- The squares mod `8` are not a coset either: no base point makes the affine Poisson
identity true for them. -/
theorem not_cosetPoissonSet_squares_zmod8 :
    ∀ x₀ ∈ ({0, 1, 4} : Finset (ZMod 8)), ¬ CosetPoissonSet ({0, 1, 4} : Finset (ZMod 8)) x₀ := by
  intro x₀ hx₀ h
  obtain ⟨H, hH⟩ := (cosetPoissonSet_iff_coset hx₀).1 h
  -- `S - x₀` would have to be a subgroup, but it is never closed under subtraction.
  have hsub : ∀ x ∈ ({0, 1, 4} : Finset (ZMod 8)), ∀ y ∈ ({0, 1, 4} : Finset (ZMod 8)),
      x - y + x₀ ∈ ({0, 1, 4} : Finset (ZMod 8)) := by
    intro x hx y hy
    refine (hH _).2 ?_
    have hx' : x - x₀ ∈ H := (hH x).1 hx
    have hy' : y - x₀ ∈ H := (hH y).1 hy
    have : x - y + x₀ - x₀ = (x - x₀) - (y - x₀) := by abel
    rw [this]
    exact H.sub_mem hx' hy'
  have h1 := hsub 1 (by decide) 4 (by decide)
  have h4 := hsub 4 (by decide) 1 (by decide)
  have hfin : ∀ z : ZMod 8, z ∈ ({0, 1, 4} : Finset (ZMod 8)) →
      1 - 4 + z ∈ ({0, 1, 4} : Finset (ZMod 8)) →
      4 - 1 + z ∈ ({0, 1, 4} : Finset (ZMod 8)) → False := by decide
  exact hfin x₀ hx₀ h1 h4

end FourierFA