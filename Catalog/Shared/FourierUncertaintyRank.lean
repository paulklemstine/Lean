/-
# Total nonsingularity of the prime DFT matrix, in rank form

Chebotarev's theorem says every *square* minor of the prime-order DFT matrix is nonsingular.
The natural rank-theoretic strengthening is that every rectangular minor has the largest rank
its shape allows:

  `rank (ζ^{x y})_{x ∈ A, y ∈ B} = min |A| |B|`   for all `A, B ⊆ ZMod p`.

We prove this, and record the "fundamental theorem of algebra for the DFT": a nonzero signal
with `α` nonzero entries has Fourier transform vanishing at strictly fewer than `α` frequencies.

Main results:

* `FourierCyclic.card_zeros_dft_lt` : `#{k : f̂ k = 0} < |supp f|` for `f ≠ 0`.
* `FourierCyclic.dftMinor` : the `A × B` minor of the DFT matrix.
* `FourierCyclic.rank_dftMinor` : its rank is `min |A| |B|`.
-/

import Mathlib
import Catalog.Shared.FourierCyclic
import Catalog.Shared.ChebotarevMinors
import Catalog.Shared.FourierUncertaintySum

open Finset FourierFA

namespace FourierCyclic

variable {p : ℕ} [NeZero p]

/-! ## The fundamental theorem of algebra for the DFT -/

/-- **Zero-counting form of the additive uncertainty principle.**  If `f : ZMod p → ℂ` is
nonzero and has `α` nonzero values, then `f̂` vanishes at strictly fewer than `α` frequencies.
This is the exact analogue of "a nonzero polynomial with `α` terms has at most `α - 1` roots",
and it is equivalent to `uncertainty_sum_zmod`. -/
theorem card_zeros_dft_lt (hp : p.Prime) (f : ZMod p → ℂ) (hf : f ≠ 0) :
    (Finset.univ.filter (fun k : ZMod p => dftZMod f k = 0)).card < (supp f).card := by
  classical
  have hfilter : Finset.univ.filter (fun k : ZMod p => dftZMod f k = 0)
      = (supp (dftZMod f))ᶜ := by
    ext k
    simp [supp]
  have hcard : ((supp (dftZMod f))ᶜ).card = p - (supp (dftZMod f)).card := by
    rw [Finset.card_compl, ZMod.card]
  have hsum := uncertainty_sum_zmod hp f hf
  have hle : (supp (dftZMod f)).card ≤ p := by
    have := Finset.card_le_univ (supp (dftZMod f))
    rwa [ZMod.card] at this
  rw [hfilter, hcard]
  omega

/-! ## The rank of an arbitrary minor -/

/-- The `A × B` minor of the DFT matrix of `ZMod p`. -/
noncomputable def dftMinor (A B : Finset (ZMod p)) : Matrix A B ℂ :=
  Matrix.of fun i j => (zetaNeg p) ^ ((i : ZMod p).val * (j : ZMod p).val)

/-- Passing to an arbitrary sub-block (rows and columns selected by arbitrary maps) cannot
increase the rank. -/
theorem rank_submatrix_le_of_maps {m n r : Type*} [Fintype m] [Fintype n] [Fintype r]
    (M : Matrix m n ℂ) (ρ : r → m) (γ : r → n) : (M.submatrix ρ γ).rank ≤ M.rank := by
  have h1 : (M.submatrix ρ (id : n → n)).rank ≤ M.rank :=
    Matrix.rank_submatrix_le ρ (Equiv.refl _) M
  have h2 : ((M.submatrix ρ id).transpose.submatrix γ (Equiv.refl r)).rank
      ≤ (M.submatrix ρ id).transpose.rank :=
    Matrix.rank_submatrix_le γ (Equiv.refl _) _
  rw [Matrix.rank_transpose] at h2
  have h3 : (M.submatrix ρ γ).rank
      = ((M.submatrix ρ id).transpose.submatrix γ (Equiv.refl r)).rank := by
    rw [← Matrix.rank_transpose (M.submatrix ρ γ)]
    congr 1
  omega

/-- **Total nonsingularity in rank form.**  For `p` prime and *arbitrary* `A, B ⊆ ZMod p`, the
`A × B` minor of the DFT matrix has the maximal rank its shape allows, namely `min |A| |B|`.
Equivalently: the prime-order DFT matrix is totally nonsingular — no rectangular sub-block,
however chosen, is rank-deficient. -/
theorem rank_dftMinor (hp : p.Prime) (A B : Finset (ZMod p)) :
    (dftMinor A B).rank = min A.card B.card := by
  classical
  refine le_antisymm (le_min ?_ ?_) ?_
  · simpa using Matrix.rank_le_card_height (dftMinor A B)
  · simpa using Matrix.rank_le_card_width (dftMinor A B)
  · set r : ℕ := min A.card B.card with hr
    obtain ⟨A', hA'sub, hA'card⟩ := Finset.exists_subset_card_eq (min_le_left A.card B.card)
    obtain ⟨B', hB'sub, hB'card⟩ := Finset.exists_subset_card_eq (min_le_right A.card B.card)
    let eA : A' ≃ Fin r := A'.equivFinOfCardEq hA'card
    let eB : B' ≃ Fin r := B'.equivFinOfCardEq hB'card
    let ρ : Fin r → A := fun i => ⟨((eA.symm i : A') : ZMod p), hA'sub (eA.symm i).2⟩
    let γ : Fin r → B := fun j => ⟨((eB.symm j : B') : ZMod p), hB'sub (eB.symm j).2⟩
    set a : Fin r → ℕ := fun i => ((ρ i : ZMod p)).val with hadef
    set b : Fin r → ℕ := fun j => ((γ j : ZMod p)).val with hbdef
    have hainj : Function.Injective a := by
      intro x y hxy
      have h1 : ((ρ x : ZMod p)) = ((ρ y : ZMod p)) := ZMod.val_injective p hxy
      exact eA.symm.injective (Subtype.ext h1)
    have hbinj : Function.Injective b := by
      intro x y hxy
      have h1 : ((γ x : ZMod p)) = ((γ y : ZMod p)) := ZMod.val_injective p hxy
      exact eB.symm.injective (Subtype.ext h1)
    have hsub : (dftMinor A B).submatrix ρ γ = Matrix.of fun i j => (zetaNeg p) ^ (a i * b j) := by
      funext i j
      rfl
    have hdet : ((dftMinor A B).submatrix ρ γ).det ≠ 0 := by
      rw [hsub]
      exact Chebotarev.det_pow_ne_zero hp (zetaNeg_isPrimitiveRoot hp.pos) a b
        (fun i => ZMod.val_lt _) (fun j => ZMod.val_lt _) hainj hbinj
    have hunit : IsUnit ((dftMinor A B).submatrix ρ γ) :=
      (Matrix.isUnit_iff_isUnit_det _).2 (isUnit_iff_ne_zero.2 hdet)
    have hrank : ((dftMinor A B).submatrix ρ γ).rank = r := by
      rw [Matrix.rank_of_isUnit _ hunit, Fintype.card_fin]
    calc r = ((dftMinor A B).submatrix ρ γ).rank := hrank.symm
      _ ≤ (dftMinor A B).rank := rank_submatrix_le_of_maps _ ρ γ

end FourierCyclic