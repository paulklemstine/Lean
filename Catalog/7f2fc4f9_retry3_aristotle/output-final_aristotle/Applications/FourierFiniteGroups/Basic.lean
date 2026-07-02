import Mathlib

/-!
# Fourier analysis on `ZMod N`: support, sup-norm and `L¹`/`L∞` bounds

This file develops the analytic infrastructure needed for the Donoho–Stark
uncertainty principle and for Parseval/convolution identities for the discrete
Fourier transform `ZMod.dft` on `ZMod N`.

Mathlib provides `ZMod.dft : (ZMod N → ℂ) ≃ₗ[ℂ] (ZMod N → ℂ)` together with the
evaluation formula `ZMod.dft_apply` and the inverse `ZMod.dft.symm`
(`ZMod.invDFT_def`).  It does **not** provide:

* the elementary `L¹` bound `‖𝓕 f k‖ ≤ ∑ⱼ ‖f j‖`,
* the dual inversion bound `‖f j‖ ≤ N⁻¹ ∑ₖ ‖𝓕 f k‖`,
* the comparison of the `L¹` norm with `|supp f| · ‖f‖∞`,

which are the basic estimates underlying the uncertainty principle.  We supply
them here.

-- !-- Lab Notes -- !--
Hypothesis (H1): The two "mixed" Hölder-type bounds
  `‖𝓕 f‖∞ ≤ |supp f| · ‖f‖∞`   and   `‖f‖∞ ≤ N⁻¹ |supp 𝓕f| · ‖𝓕 f‖∞`
follow purely from `|χ| = 1` (`AddChar.norm_apply`) and the Fourier inversion
formula, with no orthogonality needed.
Experiment: proved `dft_norm_le_l1`, `f_norm_le_invDFT_l1`, and
`l1_le_card_mul_supNorm` below; chaining them gives both mixed bounds.
Analysis: the only subtle point is that the sup-norm is realised on a *nonempty*
finite set, so `Finset.sup'` (not `⨆`) is the right tool, and positivity of the
sup-norm is equivalent to `f ≠ 0`.
-/

open scoped BigOperators
open Classical

namespace Catalog.FourierFiniteGroups

variable {N : ℕ} [NeZero N]

/-- The (finite) support of `f : ZMod N → ℂ`. -/
noncomputable def fsupp (f : ZMod N → ℂ) : Finset (ZMod N) :=
  Finset.univ.filter (fun j => f j ≠ 0)

@[simp] lemma mem_fsupp {f : ZMod N → ℂ} {j : ZMod N} : j ∈ fsupp f ↔ f j ≠ 0 := by
  simp [fsupp]

/-- The sup-norm (`‖·‖∞`) of `f : ZMod N → ℂ`, as the maximum of `‖f j‖` over the
(nonempty) finite group `ZMod N`. -/
noncomputable def supNorm (f : ZMod N → ℂ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (fun j => ‖f j‖)

/-
Every value is bounded by the sup-norm.
-/
lemma norm_le_supNorm (f : ZMod N → ℂ) (j : ZMod N) : ‖f j‖ ≤ supNorm f := by
  exact Finset.le_sup' ( fun j => ‖f j‖ ) ( Finset.mem_univ j )

/-
The sup-norm is nonnegative.
-/
lemma supNorm_nonneg (f : ZMod N → ℂ) : 0 ≤ supNorm f := by
  exact Finset.le_sup' ( fun j => ‖f j‖ ) ( Finset.mem_univ 0 ) |> le_trans ( norm_nonneg _ )

/-
The sup-norm is strictly positive for a nonzero function.
-/
lemma supNorm_pos {f : ZMod N → ℂ} (hf : f ≠ 0) : 0 < supNorm f := by
  obtain ⟨j, hj⟩ : ∃ j, f j ≠ 0 := by
    exact Function.ne_iff.mp hf;
  exact lt_of_lt_of_le ( norm_pos_iff.mpr hj ) ( norm_le_supNorm f j )

/-
**`L¹` bound on a Fourier coefficient.**  Since every additive character has
modulus one, each Fourier coefficient is bounded by the `L¹` norm of `f`.
-/
lemma dft_norm_le_l1 (f : ZMod N → ℂ) (k : ZMod N) :
    ‖ZMod.dft f k‖ ≤ ∑ j, ‖f j‖ := by
  convert norm_sum_le _ _ using 2;
  norm_num [ norm_smul, AddChar.norm_apply ]

/-
**Dual `L¹` bound from Fourier inversion.**  Each value of `f` is bounded by
`N⁻¹` times the `L¹` norm of its Fourier transform.
-/
lemma f_norm_le_invDFT_l1 (f : ZMod N → ℂ) (j : ZMod N) :
    ‖f j‖ ≤ (N : ℝ)⁻¹ * ∑ k, ‖ZMod.dft f k‖ := by
  -- By definition of inverse DFT, we have that $f j = (N⁻¹ : ℂ) • ∑ k, (ZMod.stdAddChar (k * j)) • (ZMod.dft f k)$.
  have h_invDFT : f j = (N⁻¹ : ℂ) • ∑ k, (ZMod.stdAddChar (k * j)) • (ZMod.dft f k) := by
    convert congr_arg ( fun z => z j ) ( ZMod.invDFT_def _ ) using 1;
    aesop;
  simp_all +decide [ Finset.mul_sum _ _ _ ];
  convert norm_sum_le _ _ using 2 ; norm_num [ Complex.norm_exp ]

/-
**`L¹ ≤ |supp| · L∞`.**  The `L¹` norm is at most the size of the support times
the sup-norm, because only support points contribute.
-/
lemma l1_le_card_mul_supNorm (f : ZMod N → ℂ) :
    ∑ j, ‖f j‖ ≤ (fsupp f).card * supNorm f := by
  rw [ ← Finset.sum_subset ( Finset.subset_univ ( fsupp f ) ) ];
  · exact le_trans ( Finset.sum_le_sum fun x hx => norm_le_supNorm f x ) ( by norm_num );
  · unfold fsupp; aesop;

end Catalog.FourierFiniteGroups