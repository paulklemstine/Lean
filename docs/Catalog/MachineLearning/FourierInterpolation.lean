/-
# Deterministic Fourier interpolation on `ZMod p`

Chebotarev's theorem (`Chebotarev.det_pow_ne_zero`) says that *every* square minor of the
prime-order DFT matrix is nonsingular.  Read as a statement about linear algebra rather than
about supports, this says that the restricted Fourier transform

  `{f : supp f ⊆ A} → ℂ^B`,  `f ↦ f̂|_B`

is an isomorphism whenever `|A| = |B|`, for *arbitrary* `A, B ⊆ ZMod p`.  This is the
"deterministic compressed sensing" face of the additive uncertainty principle
(`FourierCyclic.uncertainty_sum_zmod`): no genericity or randomness is required of the
sampling pattern `B` or the sparsity pattern `A`.

Main results:

* `FourierCyclic.dft_interpolation` : existence and uniqueness of an `A`-supported signal with
  prescribed Fourier data on `B`, when `|A| = |B|`.
* `FourierCyclic.dft_restricted_surjective` : any Fourier data on `B` is achievable by an
  `A`-supported signal whenever `|B| ≤ |A|`.
* `FourierCyclic.dft_restricted_injective` : an `A`-supported signal is determined by its
  Fourier data on `B` whenever `|A| ≤ |B|`.
* `FourierCyclic.dft_columns_linearIndependent` : full spark — for every frequency set `B`, any
  `|B|` columns of the partial DFT matrix are linearly independent.
-/

import Mathlib
import Shared.FourierCyclic
import Shared.ChebotarevMinors
import Shared.FourierUncertaintySum

open Finset FourierFA

namespace FourierCyclic

variable {p : ℕ} [NeZero p]

/-- Signals vanishing off `A` have Fourier transform computed by the `A`-minor. -/
theorem dftZMod_of_vanishing_off {A : Finset (ZMod p)} {α : ℕ} (eA : A ≃ Fin α)
    (f : ZMod p → ℂ) (hf : ∀ x, x ∉ A → f x = 0) (k : ZMod p) :
    dftZMod f k
      = ∑ j : Fin α, (zetaNeg p) ^ (k.val * ((eA.symm j : A) : ZMod p).val)
          * f ((eA.symm j : A) : ZMod p) := by
  have hsub : supp f ⊆ A := by
    intro x hx
    by_contra hxA
    exact (mem_supp.1 hx) (hf x hxA)
  rw [dftZMod_eq_sum_finset f k hsub,
    sum_finset_eq_sum_fin A eA (fun x => (zetaNeg p) ^ (k.val * x.val) * f x)]

/-- **Deterministic Fourier interpolation.**  Let `p` be prime and let `A, B ⊆ ZMod p` be
*arbitrary* sets of the same size.  For any prescribed data `g` there is a unique signal `f`
vanishing off `A` whose Fourier transform agrees with `g` on `B`.

Equivalently: for every pair of equal-size sets, the restricted Fourier transform
`f ↦ f̂|_B` on signals supported in `A` is a linear isomorphism. -/
theorem dft_interpolation (hp : p.Prime) (A B : Finset (ZMod p)) (hAB : A.card = B.card)
    (g : ZMod p → ℂ) :
    ∃! f : ZMod p → ℂ, (∀ x, x ∉ A → f x = 0) ∧ ∀ k ∈ B, dftZMod f k = g k := by
  classical
  set α : ℕ := A.card with hα
  have hBcard : B.card = α := hAB.symm
  let eA : A ≃ Fin α := A.equivFinOfCardEq hα.symm
  let eB : B ≃ Fin α := B.equivFinOfCardEq hBcard
  let v : Fin α → ZMod p := fun j => ((eA.symm j : A) : ZMod p)
  let u : Fin α → ZMod p := fun i => ((eB.symm i : B) : ZMod p)
  have hvinj : Function.Injective v := fun x y h => eA.symm.injective (Subtype.ext h)
  have huinj : Function.Injective u := fun x y h => eB.symm.injective (Subtype.ext h)
  set a : Fin α → ℕ := fun i => (u i).val with hadef
  set b : Fin α → ℕ := fun j => (v j).val with hbdef
  have hainj : Function.Injective a := fun x y h => huinj (ZMod.val_injective p h)
  have hbinj : Function.Injective b := fun x y h => hvinj (ZMod.val_injective p h)
  set M : Matrix (Fin α) (Fin α) ℂ := Matrix.of fun i j => (zetaNeg p) ^ (a i * b j) with hM
  have hdet : M.det ≠ 0 :=
    Chebotarev.det_pow_ne_zero hp (zetaNeg_isPrimitiveRoot hp.pos) a b
      (fun i => ZMod.val_lt (u i)) (fun j => ZMod.val_lt (v j)) hainj hbinj
  have hunit : IsUnit M.det := isUnit_iff_ne_zero.2 hdet
  -- Translate "vanishes off `A`, Fourier data `g` on `B`" into a linear system for `M`.
  have hkey : ∀ f : ZMod p → ℂ, (∀ x, x ∉ A → f x = 0) →
      ∀ i : Fin α, dftZMod f (u i) = M.mulVec (fun j => f (v j)) i := by
    intro f hf i
    rw [dftZMod_of_vanishing_off eA f hf (u i)]
    simp only [hM, Matrix.mulVec, Matrix.of_apply, dotProduct, hadef, hbdef]
    rfl
  -- Recover `f` from its values on `A`.
  have hcoords : ∀ w : Fin α → ℂ, ∀ j : Fin α,
      (fun x => if h : x ∈ A then w (eA ⟨x, h⟩) else 0) (v j) = w j := by
    intro w j
    have hmem : v j ∈ A := (eA.symm j).2
    simp only [dif_pos hmem]
    congr 1
    have : (⟨v j, hmem⟩ : A) = eA.symm j := Subtype.ext rfl
    rw [this, Equiv.apply_symm_apply]
  refine ⟨fun x => if h : x ∈ A then (M⁻¹.mulVec (fun i => g (u i))) (eA ⟨x, h⟩) else 0, ⟨?_, ?_⟩, ?_⟩
  · intro x hx
    simp [dif_neg hx]
  · intro k hk
    set w : Fin α → ℂ := M⁻¹.mulVec (fun i => g (u i)) with hw
    set f : ZMod p → ℂ := fun x => if h : x ∈ A then w (eA ⟨x, h⟩) else 0 with hfdef
    have hvan : ∀ x, x ∉ A → f x = 0 := fun x hx => by simp [hfdef, dif_neg hx]
    have hfv : (fun j => f (v j)) = w := funext (hcoords w)
    have hi : k = u (eB ⟨k, hk⟩) := by
      have : (eB.symm (eB ⟨k, hk⟩) : B) = (⟨k, hk⟩ : B) := by rw [Equiv.symm_apply_apply]
      simp only [u]
      rw [this]
    rw [hi, hkey f hvan, hfv, hw, Matrix.mulVec_mulVec, Matrix.mul_nonsing_inv M hunit,
      Matrix.one_mulVec]
  · rintro f ⟨hvan, hval⟩
    set w : Fin α → ℂ := M⁻¹.mulVec (fun i => g (u i)) with hw
    set f₀ : ZMod p → ℂ := fun x => if h : x ∈ A then w (eA ⟨x, h⟩) else 0 with hf₀
    have hvan₀ : ∀ x, x ∉ A → f₀ x = 0 := fun x hx => by simp [hf₀, dif_neg hx]
    have hfv₀ : (fun j => f₀ (v j)) = w := funext (hcoords w)
    -- Both `f` and `f₀` produce the same right-hand side, so their coordinate vectors agree.
    have hMw : M.mulVec w = fun i => g (u i) := by
      rw [hw, Matrix.mulVec_mulVec, Matrix.mul_nonsing_inv M hunit, Matrix.one_mulVec]
    have hMf : M.mulVec (fun j => f (v j)) = fun i => g (u i) := by
      funext i
      rw [← hkey f hvan i]
      exact hval (u i) (eB.symm i).2
    have hdiff : M.mulVec ((fun j => f (v j)) - w) = 0 := by
      rw [Matrix.mulVec_sub, hMf, hMw, sub_self]
    have hzero : (fun j => f (v j)) - w = 0 := by
      by_contra hne
      exact hdet (Matrix.exists_mulVec_eq_zero_iff.1 ⟨_, hne, hdiff⟩)
    have hcoord : ∀ j, f (v j) = w j := by
      intro j
      have := congrFun hzero j
      simpa [sub_eq_zero] using this
    funext x
    by_cases hx : x ∈ A
    · have hxv : x = v (eA ⟨x, hx⟩) := by
        have : (eA.symm (eA ⟨x, hx⟩) : A) = (⟨x, hx⟩ : A) := by rw [Equiv.symm_apply_apply]
        simp only [v]
        rw [this]
      rw [hxv, hcoord, hf₀]
      exact (hcoords w (eA ⟨x, hx⟩)).symm
    · rw [hvan x hx, hvan₀ x hx]

/-- **Surjectivity of the restricted Fourier transform.**  If `|B| ≤ |A|` then every
prescription of Fourier data on `B` is realised by some signal vanishing off `A`. -/
theorem dft_restricted_surjective (hp : p.Prime) (A B : Finset (ZMod p)) (hAB : B.card ≤ A.card)
    (g : ZMod p → ℂ) :
    ∃ f : ZMod p → ℂ, (∀ x, x ∉ A → f x = 0) ∧ ∀ k ∈ B, dftZMod f k = g k := by
  obtain ⟨A', hA'sub, hA'card⟩ := Finset.exists_subset_card_eq hAB
  obtain ⟨f, ⟨hvan, hval⟩, -⟩ := dft_interpolation hp A' B hA'card g
  exact ⟨f, fun x hx => hvan x (fun hxA => hx (hA'sub hxA)), hval⟩

/-- **Injectivity of the restricted Fourier transform.**  If `|A| ≤ |B|` then a signal
vanishing off `A` is completely determined by its Fourier data on `B`. -/
theorem dft_restricted_injective (hp : p.Prime) (A B : Finset (ZMod p)) (hAB : A.card ≤ B.card)
    (f₁ f₂ : ZMod p → ℂ) (h₁ : ∀ x, x ∉ A → f₁ x = 0) (h₂ : ∀ x, x ∉ A → f₂ x = 0)
    (heq : ∀ k ∈ B, dftZMod f₁ k = dftZMod f₂ k) : f₁ = f₂ := by
  obtain ⟨B', hB'sub, hB'card⟩ := Finset.exists_subset_card_eq hAB
  obtain ⟨f₀, -, huniq⟩ := dft_interpolation hp A B' hB'card.symm (dftZMod f₁)
  have e₁ := huniq f₁ ⟨h₁, fun k _ => rfl⟩
  have e₂ := huniq f₂ ⟨h₂, fun k hk => (heq k (hB'sub hk)).symm⟩
  rw [e₁, e₂]

/-- **Full spark of the prime DFT matrix.**  For any frequency set `B` and any `A` with
`|A| ≤ |B|`, the columns of the DFT matrix indexed by `A`, restricted to the rows `B`, are
linearly independent.  In compressed-sensing language: the `|B| × p` partial DFT matrix has
spark `|B| + 1`, the largest possible, for *every* choice of sampled frequencies. -/
theorem dft_columns_linearIndependent (hp : p.Prime) (A B : Finset (ZMod p))
    (hAB : A.card ≤ B.card) :
    LinearIndependent ℂ
      (fun (j : A) (i : B) => (zetaNeg p) ^ ((i : ZMod p).val * (j : ZMod p).val)) := by
  classical
  rw [Fintype.linearIndependent_iff]
  intro g hg j
  set f : ZMod p → ℂ := fun x => if h : x ∈ A then g ⟨x, h⟩ else 0 with hfdef
  have hvan : ∀ x, x ∉ A → f x = 0 := fun x hx => by simp [hfdef, dif_neg hx]
  have hdft : ∀ i ∈ B, dftZMod f i = 0 := by
    intro i hi
    have hsub : supp f ⊆ A := by
      intro x hx
      by_contra hxA
      exact (mem_supp.1 hx) (hvan x hxA)
    rw [dftZMod_eq_sum_finset f i hsub, ← Finset.sum_coe_sort A]
    have hterm : ∀ x : A, (zetaNeg p) ^ (i.val * (x : ZMod p).val) * f (x : ZMod p)
        = g x * (zetaNeg p) ^ (i.val * (x : ZMod p).val) := by
      intro x
      simp only [hfdef, dif_pos x.2, Subtype.coe_eta]
      ring
    rw [Finset.sum_congr rfl (fun x _ => hterm x)]
    have := congrFun hg ⟨i, hi⟩
    simpa [Finset.sum_apply] using this
  have hzero : f = 0 :=
    dft_restricted_injective hp A B hAB f 0 hvan (fun _ _ => rfl)
      (fun k hk => by rw [hdft k hk]; simp [dftZMod])
  have := congrFun hzero (j : ZMod p)
  simpa [hfdef, dif_pos j.2] using this

end FourierCyclic