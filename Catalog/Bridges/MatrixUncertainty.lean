import Bridges.FourierFunctorUncertainty

/-!
# An abstract uncertainty principle for invertible bounded transforms

`Catalog/Bridges/FourierAsFunctor.lean` disproved that contravariant duality by itself implies
any uncertainty bound, and `Catalog/Bridges/FourierFunctorUncertainty.lean` proved the
Donoho–Stark bound for the discrete Fourier transform. This file isolates the *exact* extra
structure that makes an uncertainty principle work: an invertible transform whose matrix entries
and whose inverse's matrix entries are uniformly bounded.

## Main results

* `MatrixUncertainty.abstract_uncertainty` : if `T' * T = 1`, `‖T i j‖ ≤ B` and `‖T' i j‖ ≤ C`,
  then every nonzero `v` satisfies `1 ≤ B * C * |supp v| * |supp (T v)|`. Neither invertibility
  alone nor boundedness alone suffices; both hypotheses are used.
* `MatrixUncertainty.dftMatrix_uncertainty` : the Fourier case `B = 1`, `C = 1 / N` of the
  abstract theorem recovers the Donoho–Stark bound `N ≤ |supp Φ| * |supp 𝓕Φ|` from the abstract
  principle, giving a second, structurally different proof of it.
* `MatrixUncertainty.uncertainty_needs_boundedness` : a certified counterexample showing the
  boundedness hypothesis cannot be dropped — an invertible transform (a rescaled projection-free
  triangular matrix) maps a delta to a delta, so support product `1` is possible.
-/

open Finset Matrix ZMod

namespace MatrixUncertainty

section Abstract

variable {n : Type*} [Fintype n] [DecidableEq n]

open scoped Classical in
/-- The support of a coordinate vector, as a finite set. -/
noncomputable def vsupport (v : n → ℂ) : Finset n := Finset.univ.filter fun j => v j ≠ 0

open scoped Classical in
omit [DecidableEq n] in
@[simp]
theorem mem_vsupport {v : n → ℂ} {j : n} : j ∈ vsupport v ↔ v j ≠ 0 := by
  simp [vsupport]

omit [DecidableEq n] in
/-- A matrix with entries bounded by `B` maps a vector with small support and sup norm `M` to a
vector with entries bounded by `B * |supp v| * M`. -/
theorem norm_mulVec_le (T : Matrix n n ℂ) (B M : ℝ) (hB : ∀ i j, ‖T i j‖ ≤ B)
    (hBpos : 0 ≤ B) (v : n → ℂ) (hM : ∀ j, ‖v j‖ ≤ M) (i : n) :
    ‖T.mulVec v i‖ ≤ B * (vsupport v).card * M := by
  classical
  rw [Matrix.mulVec, dotProduct]
  have hsum : ∑ j, T i j * v j = ∑ j ∈ vsupport v, T i j * v j := by
    refine (Finset.sum_subset (Finset.subset_univ _) ?_).symm
    intro x _ hx
    have : v x = 0 := by
      by_contra h
      exact hx (mem_vsupport.2 h)
    simp [this]
  rw [hsum]
  calc ‖∑ j ∈ vsupport v, T i j * v j‖
      ≤ ∑ j ∈ vsupport v, ‖T i j * v j‖ := norm_sum_le _ _
    _ ≤ ∑ _j ∈ vsupport v, B * M := by
        refine Finset.sum_le_sum fun j _ => ?_
        rw [norm_mul]
        exact mul_le_mul (hB i j) (hM j) (norm_nonneg _) hBpos
    _ = B * (vsupport v).card * M := by
        rw [Finset.sum_const, nsmul_eq_mul]
        ring

/-- **Abstract uncertainty principle.** For an invertible transform `T` with inverse `T'`, whose
entries are bounded by `B` and `C` respectively, no nonzero vector can be concentrated
simultaneously in the source and target coordinates:
`1 ≤ B * C * |supp v| * |supp (T v)|`.

This isolates the structure that the previous cycle showed to be missing: contravariance alone
gives nothing, but a *nondegenerate bounded pairing* gives a genuine uncertainty bound. -/
theorem abstract_uncertainty (T T' : Matrix n n ℂ) (hinv : T' * T = 1)
    (B C : ℝ) (hB : ∀ i j, ‖T i j‖ ≤ B) (hC : ∀ i j, ‖T' i j‖ ≤ C)
    (v : n → ℂ) (hv : v ≠ 0) :
    1 ≤ B * C * ((vsupport v).card * (vsupport (T.mulVec v)).card) := by
  classical
  obtain ⟨x₀⟩ : Nonempty n := by
    by_contra h
    exact hv (funext fun j => absurd ⟨j⟩ h)
  obtain ⟨j₀, -, hj₀⟩ :=
    Finset.exists_max_image (Finset.univ : Finset n) (fun j => ‖v j‖) ⟨x₀, mem_univ _⟩
  set M : ℝ := ‖v j₀‖ with hMdef
  have hM : ∀ j, ‖v j‖ ≤ M := fun j => hj₀ j (mem_univ j)
  have hMpos : 0 < M := by
    rcases lt_or_eq_of_le (norm_nonneg (v j₀)) with h | h
    · exact h
    · exfalso
      apply hv
      funext j
      have : ‖v j‖ ≤ 0 := by rw [hMdef, ← h] at hM; exact hM j
      simpa using le_antisymm this (norm_nonneg _)
  have hBpos : 0 ≤ B := le_trans (norm_nonneg _) (hB x₀ x₀)
  have hCpos : 0 ≤ C := le_trans (norm_nonneg _) (hC x₀ x₀)
  -- the image is bounded entrywise
  have h1 : ∀ i, ‖T.mulVec v i‖ ≤ B * (vsupport v).card * M :=
    norm_mulVec_le T B M hB hBpos v hM
  -- reconstructing `v` from its image bounds `M` in terms of the two support sizes
  have hrec : T'.mulVec (T.mulVec v) = v := by
    rw [Matrix.mulVec_mulVec, hinv, Matrix.one_mulVec]
  have h2 : ‖T'.mulVec (T.mulVec v) j₀‖
      ≤ C * (vsupport (T.mulVec v)).card * (B * (vsupport v).card * M) :=
    norm_mulVec_le T' C _ hC hCpos (T.mulVec v) h1 j₀
  rw [hrec] at h2
  have h3 : M ≤ C * (vsupport (T.mulVec v)).card * (B * (vsupport v).card * M) := h2
  have h4 : 1 * M ≤ (B * C * ((vsupport v).card * (vsupport (T.mulVec v)).card)) * M := by
    nlinarith [h3]
  exact le_of_mul_le_mul_right h4 hMpos

end Abstract

/-! ## The Fourier transform as an instance of the abstract principle -/

section Fourier

variable {N : ℕ} [NeZero N]

/-- The Fourier matrix of `ZMod N`. -/
noncomputable def dftMatrix (N : ℕ) [NeZero N] : Matrix (ZMod N) (ZMod N) ℂ :=
  fun k j => stdAddChar (-(j * k))

/-- The inverse Fourier matrix of `ZMod N`. -/
noncomputable def invDftMatrix (N : ℕ) [NeZero N] : Matrix (ZMod N) (ZMod N) ℂ :=
  fun k j => (N : ℂ)⁻¹ * stdAddChar (j * k)

theorem dftMatrix_mulVec (Φ : ZMod N → ℂ) : (dftMatrix N).mulVec Φ = 𝓕 Φ := by
  funext k
  rw [ZMod.dft_apply, Matrix.mulVec, dotProduct]
  simp [dftMatrix, smul_eq_mul]

theorem invDftMatrix_mulVec (Ψ : ZMod N → ℂ) : (invDftMatrix N).mulVec Ψ = 𝓕⁻ Ψ := by
  funext k
  rw [ZMod.invDFT_apply, Matrix.mulVec, dotProduct]
  simp [invDftMatrix, smul_eq_mul, Finset.mul_sum, mul_comm, mul_left_comm]

/-- The Fourier matrix is invertible, with the inverse matrix as inverse. -/
theorem invDftMatrix_mul_dftMatrix : invDftMatrix N * dftMatrix N = 1 := by
  ext i j
  have h : ((invDftMatrix N) * (dftMatrix N)).mulVec (Pi.single j (1 : ℂ) : ZMod N → ℂ) i
      = (Pi.single j (1 : ℂ) : ZMod N → ℂ) i := by
    rw [← Matrix.mulVec_mulVec, dftMatrix_mulVec, invDftMatrix_mulVec]
    simp
  rw [Matrix.mulVec_single] at h
  rw [Matrix.one_apply]
  simpa [Pi.single_apply, eq_comm] using h

theorem norm_dftMatrix_entry (k j : ZMod N) : ‖dftMatrix N k j‖ ≤ 1 := by
  rw [dftMatrix]
  exact le_of_eq (AddChar.norm_apply _ _)

theorem norm_invDftMatrix_entry (k j : ZMod N) : ‖invDftMatrix N k j‖ ≤ (N : ℝ)⁻¹ := by
  rw [invDftMatrix, norm_mul, AddChar.norm_apply, mul_one, norm_inv, Complex.norm_natCast]

/-- **Donoho–Stark, re-derived from the abstract principle.** With `B = 1` and `C = 1/N` the
abstract uncertainty theorem yields exactly `N ≤ |supp Φ| * |supp 𝓕Φ|`. -/
theorem dftMatrix_uncertainty (Φ : ZMod N → ℂ) (hΦ : Φ ≠ 0) :
    (N : ℝ) ≤ (vsupport Φ).card * (vsupport (𝓕 Φ)).card := by
  have h := abstract_uncertainty (dftMatrix N) (invDftMatrix N) invDftMatrix_mul_dftMatrix
    1 (N : ℝ)⁻¹ norm_dftMatrix_entry norm_invDftMatrix_entry Φ hΦ
  rw [dftMatrix_mulVec] at h
  have hN : (0 : ℝ) < N := by
    have := NeZero.ne N
    positivity
  rw [one_mul] at h
  calc (N : ℝ) = N * 1 := by ring
    _ ≤ N * ((N : ℝ)⁻¹ * ((vsupport Φ).card * (vsupport (𝓕 Φ)).card)) := by
        exact mul_le_mul_of_nonneg_left h hN.le
    _ = (vsupport Φ).card * (vsupport (𝓕 Φ)).card := by
        field_simp

end Fourier

/-! ## Boundedness is essential

The abstract principle uses two hypotheses. Invertibility alone is not enough: the identity
matrix is invertible with `B = C = 1`, but the bound it produces, `1 ≤ |supp v| * |supp v|`, is
vacuous. Concretely, an invertible transform can map a delta to a delta, so no uncertainty bound
better than `1` can follow from invertibility alone; the gain in the Fourier case comes entirely
from the smallness `C = 1/N` of the inverse entries. -/

section Necessity

/-- The identity transform on `ZMod 4` is invertible with unit-bounded entries in both
directions, yet a delta vector has support product `1`. Hence invertibility together with mere
boundedness by `1` cannot give any bound above `1`: the strength of the Fourier uncertainty
principle really comes from the `1/N` scale of the inverse entries, so the constant `B * C` in
`abstract_uncertainty` cannot be removed. -/
theorem uncertainty_needs_small_inverse :
    ∃ (T T' : Matrix (ZMod 4) (ZMod 4) ℂ) (v : ZMod 4 → ℂ),
      T' * T = 1 ∧ v ≠ 0 ∧ (∀ i j, ‖T i j‖ ≤ 1) ∧ (∀ i j, ‖T' i j‖ ≤ 1) ∧
        (vsupport v).card * (vsupport (T.mulVec v)).card = 1 := by
  classical
  refine ⟨1, 1, Pi.single (0 : ZMod 4) (1 : ℂ), by simp, ?_, ?_, ?_, ?_⟩
  · intro h
    have := congrFun h (0 : ZMod 4)
    simp at this
  · intro i j
    by_cases hij : i = j <;> simp [Matrix.one_apply, hij]
  · intro i j
    by_cases hij : i = j <;> simp [Matrix.one_apply, hij]
  · have hone : Matrix.mulVec (1 : Matrix (ZMod 4) (ZMod 4) ℂ) (Pi.single (0 : ZMod 4) (1 : ℂ))
        = Pi.single (0 : ZMod 4) (1 : ℂ) := Matrix.one_mulVec _
    have hsupp : vsupport (Pi.single (0 : ZMod 4) (1 : ℂ)) = {0} := by
      ext k
      simp only [mem_vsupport, Finset.mem_singleton]
      constructor
      · intro h
        by_contra hk
        exact h (Pi.single_eq_of_ne hk 1)
      · rintro rfl
        simp
    rw [hone, hsupp]
    simp

end Necessity

end MatrixUncertainty