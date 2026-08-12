import Bridges.MatrixUncertainty
import Bridges.UncertaintyRigidity

/-!
# Abstract rigidity: sharpness of the bounded-inverse uncertainty principle forces flatness

`Catalog/Bridges/MatrixUncertainty.lean` proved the abstract uncertainty principle
`1 ≤ B * C * |supp v| * |supp (T v)|` for an invertible transform `T` with inverse `T'` whose
entries are bounded by `B` and `C`. `Catalog/Bridges/UncertaintyRigidity.lean` proved that
equality in the *Fourier* case forces the function to be flat on its support. This file shows
that the flatness phenomenon is not special to the Fourier transform: it is a consequence of the
abstract hypotheses alone, and it is the first half of Conjecture 4 of the thread.

## Main results

* `AbstractRigidity.norm_mulVec_le_sum` : the `ℓ¹` refinement of the entrywise bound.
* `AbstractRigidity.abstract_flatness` : if the abstract bound is attained,
  `B * C * (|supp v| * |supp (T v)|) = 1`, then `‖v‖` is constant on the support of `v`.
* `AbstractRigidity.abstract_uncertainty_strict` : hence a vector with two distinct nonzero
  moduli satisfies the *strict* inequality `1 < B * C * |supp v| * |supp (T v)|`.
* `AbstractRigidity.dft_flat_of_extremal_abstract` : specialising to the Fourier matrix
  (`B = 1`, `C = 1/N`) gives a second, structurally different proof of flatness for the
  Donoho–Stark equality case.
-/

open Finset Matrix ZMod FourierUncertainty MatrixUncertainty

namespace AbstractRigidity

section Abstract

variable {n : Type*} [Fintype n] [DecidableEq n]

omit [DecidableEq n] in
/-- `ℓ¹` refinement of `MatrixUncertainty.norm_mulVec_le`: an entrywise bound `B` on the matrix
bounds the image entries by `B` times the `ℓ¹` norm of the vector. -/
theorem norm_mulVec_le_sum (T : Matrix n n ℂ) (B : ℝ) (hB : ∀ i j, ‖T i j‖ ≤ B)
    (v : n → ℂ) (i : n) :
    ‖T.mulVec v i‖ ≤ B * ∑ j ∈ vsupport v, ‖v j‖ := by
  classical
  rw [Matrix.mulVec, dotProduct]
  have hsum : ∑ j, T i j * v j = ∑ j ∈ vsupport v, T i j * v j := by
    refine (Finset.sum_subset (Finset.subset_univ _) ?_).symm
    intro x _ hx
    have : v x = 0 := by
      by_contra h
      exact hx (mem_vsupport.2 h)
    simp [this]
  rw [hsum, Finset.mul_sum]
  refine (norm_sum_le _ _).trans (Finset.sum_le_sum fun j _ => ?_)
  rw [norm_mul]
  exact mul_le_mul_of_nonneg_right (hB i j) (norm_nonneg _)

/-- **Abstract flatness.** If a nonzero vector attains the abstract uncertainty bound, then all
its nonzero entries have the same modulus. Flatness is therefore forced by invertibility plus
entrywise bounds, with no Fourier structure involved. -/
theorem abstract_flatness (T T' : Matrix n n ℂ) (hinv : T' * T = 1)
    (B C : ℝ) (hB : ∀ i j, ‖T i j‖ ≤ B) (hC : ∀ i j, ‖T' i j‖ ≤ C)
    (v : n → ℂ) (hv : v ≠ 0)
    (heq : B * C * ((vsupport v).card * (vsupport (T.mulVec v)).card) = 1)
    {a b : n} (ha : a ∈ vsupport v) (hb : b ∈ vsupport v) :
    ‖v a‖ = ‖v b‖ := by
  classical
  obtain ⟨x₀⟩ : Nonempty n := ⟨a⟩
  obtain ⟨j₀, -, hj₀'⟩ :=
    Finset.exists_max_image (Finset.univ : Finset n) (fun j => ‖v j‖) ⟨x₀, mem_univ _⟩
  have hj₀ : ∀ j, ‖v j‖ ≤ ‖v j₀‖ := fun j => hj₀' j (mem_univ j)
  set M : ℝ := ‖v j₀‖ with hM
  have hMpos : 0 < M := by
    rcases lt_or_eq_of_le (norm_nonneg (v j₀)) with h | h
    · exact h
    · exfalso
      apply hv
      funext j
      have : ‖v j‖ ≤ 0 := by rw [hM, ← h] at hj₀; exact hj₀ j
      simpa using le_antisymm this (norm_nonneg _)
  have hBpos : 0 ≤ B := le_trans (norm_nonneg _) (hB x₀ x₀)
  have hCpos : 0 ≤ C := le_trans (norm_nonneg _) (hC x₀ x₀)
  set s : ℝ := ((vsupport v).card : ℝ) with hs
  set t : ℝ := ((vsupport (T.mulVec v)).card : ℝ) with ht
  set S : ℝ := ∑ j ∈ vsupport v, ‖v j‖ with hS
  have hspos : 0 ≤ s := by positivity
  have htpos : 0 ≤ t := by positivity
  -- all four factors of the extremality relation are positive
  have hprod : B * C * (s * t) = 1 := heq
  have hBP : 0 < B := by
    rcases hBpos.lt_or_eq with h | h
    · exact h
    · exfalso; rw [← h] at hprod; simp at hprod
  have hCP : 0 < C := by
    rcases hCpos.lt_or_eq with h | h
    · exact h
    · exfalso; rw [← h] at hprod; simp at hprod
  have htP : 0 < t := by
    rcases htpos.lt_or_eq with h | h
    · exact h
    · exfalso; rw [← h] at hprod; simp at hprod
  -- the two bounds of the chain
  have hupper : S ≤ s * M := by
    have := Finset.sum_le_card_nsmul (vsupport v) (fun j => ‖v j‖) M fun j _ => hj₀ j
    simpa [hS, hs, nsmul_eq_mul] using this
  have himg : ∀ i, ‖T.mulVec v i‖ ≤ B * S := norm_mulVec_le_sum T B hB v
  have hrec : T'.mulVec (T.mulVec v) = v := by
    rw [Matrix.mulVec_mulVec, hinv, Matrix.one_mulVec]
  have hlower : M ≤ C * t * (B * S) := by
    have h2 := norm_mulVec_le T' C (B * S) hC hCpos (T.mulVec v) himg j₀
    rw [hrec] at h2
    simpa [hM, ht] using h2
  -- equality forces the `ℓ¹` norm to be maximal
  have hSval : S = s * M := by
    refine le_antisymm hupper ?_
    have hcoef : 0 < C * t * B := by positivity
    have hM' : M ≤ (C * t * B) * S := by
      rw [show (C * t * B) * S = C * t * (B * S) by ring]
      exact hlower
    have hkey : (C * t * B) * (s * M) = M := by linear_combination M * hprod
    have hstep : (C * t * B) * (s * M) ≤ (C * t * B) * S := by rw [hkey]; exact hM'
    exact le_of_mul_le_mul_left hstep hcoef
  -- flatness
  have hconst : ∑ _j ∈ vsupport v, M = s * M := by
    rw [Finset.sum_const, nsmul_eq_mul, hs]
  have hall : ∀ j ∈ vsupport v, ‖v j‖ = M :=
    (Finset.sum_eq_sum_iff_of_le fun j _ => hj₀ j).1 (by rw [← hS, hSval, ← hconst])
  rw [hall a ha, hall b hb]

/-- **Strict abstract uncertainty for non-flat vectors.** -/
theorem abstract_uncertainty_strict (T T' : Matrix n n ℂ) (hinv : T' * T = 1)
    (B C : ℝ) (hB : ∀ i j, ‖T i j‖ ≤ B) (hC : ∀ i j, ‖T' i j‖ ≤ C)
    (v : n → ℂ) {a b : n} (ha : v a ≠ 0) (hb : v b ≠ 0) (hne : ‖v a‖ ≠ ‖v b‖) :
    1 < B * C * ((vsupport v).card * (vsupport (T.mulVec v)).card) := by
  classical
  have hv : v ≠ 0 := fun h => ha (by rw [h]; rfl)
  refine lt_of_le_of_ne (abstract_uncertainty T T' hinv B C hB hC v hv) fun hEq => hne ?_
  exact abstract_flatness T T' hinv B C hB hC v hv hEq.symm
    (mem_vsupport.2 ha) (mem_vsupport.2 hb)

end Abstract

/-! ## The Fourier instance -/

section Fourier

variable {N : ℕ} [NeZero N]

theorem vsupport_eq_fsupport (Φ : ZMod N → ℂ) : vsupport Φ = fsupport Φ := by
  classical
  ext j
  simp

/-- **Flatness of the Donoho–Stark extremals, re-derived from the abstract principle.** This is a
second proof of `UncertaintyRigidity.flat_of_extremal`, obtained by instantiating abstract
flatness at `B = 1`, `C = 1/N`; it shows that the equality analysis depends only on the
invertibility and the entry bounds of the Fourier matrix. -/
theorem dft_flat_of_extremal_abstract {Φ : ZMod N → ℂ} (hΦ : Φ ≠ 0)
    (hext : (fsupport Φ).card * (fsupport (𝓕 Φ)).card = N)
    {a b : ZMod N} (ha : a ∈ fsupport Φ) (hb : b ∈ fsupport Φ) :
    ‖Φ a‖ = ‖Φ b‖ := by
  classical
  have hN : (N : ℝ) ≠ 0 := Nat.cast_ne_zero.2 (NeZero.ne N)
  have hmul : (dftMatrix N).mulVec Φ = 𝓕 Φ := dftMatrix_mulVec Φ
  have heq : (1 : ℝ) * (N : ℝ)⁻¹ *
      ((vsupport Φ).card * (vsupport ((dftMatrix N).mulVec Φ)).card) = 1 := by
    rw [hmul, vsupport_eq_fsupport, vsupport_eq_fsupport]
    have : ((fsupport Φ).card * (fsupport (𝓕 Φ)).card : ℝ) = (N : ℝ) := by
      exact_mod_cast congrArg (Nat.cast : ℕ → ℝ) hext
    rw [this]
    field_simp
  refine abstract_flatness (dftMatrix N) (invDftMatrix N) invDftMatrix_mul_dftMatrix
    1 (N : ℝ)⁻¹ norm_dftMatrix_entry norm_invDftMatrix_entry Φ hΦ heq ?_ ?_
  · rw [vsupport_eq_fsupport]; exact ha
  · rw [vsupport_eq_fsupport]; exact hb

end Fourier

end AbstractRigidity