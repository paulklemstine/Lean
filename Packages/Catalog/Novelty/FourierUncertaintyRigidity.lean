/-
# Rigidity of the Donoho–Stark uncertainty principle on finite abelian groups

`Catalog.Shared.FourierExtremals` proves the *easy* (`⇐`) direction of the extremal problem
for the Donoho–Stark uncertainty principle: every function of the form
`x ↦ c · χ x · 1_H (x - a)` (a nonzero multiple of a modulated coset indicator) satisfies
`|supp f| · |supp f̂| = |G|` (`FourierFA.uncertainty_eq_coset_modulation`).

This file settles the *open* (`⇒`) direction, i.e. the **rigidity/structure theorem**:
these are the *only* extremals.  The proof is a chain of equality analyses:

* `FourierFA.IsExtremal.norm_dft_eq_l1` : extremality forces `|f̂(ψ)| = ‖f‖₁` for every `ψ`
  in the spectrum, i.e. the Fourier transform has *constant modulus* on its support.
  (Equality analysis of Plancherel + Cauchy–Schwarz.)
* `FourierFA.IsExtremal.phase_align` : hence equality holds in the triangle inequality
  defining `f̂(ψ)`, so all the summands `conj (ψ x) f x`, `x ∈ supp f`, are positively
  proportional (`FourierFA.norm_sum_eq_sum_norm_phase`).
* `FourierFA.IsExtremal.card_mul_norm_eq` : Fourier inversion then forces `|f|` to be
  *constant on its support*.
* `FourierFA.IsExtremal.conj_mul_eq` : combining, `conj (ψ x) f x` does not depend on
  `x ∈ supp f`, for each `ψ` in the spectrum.
* `FourierFA.phaseSubgroup` : the subgroup `H = {z | ∀ ψ ∈ supp f̂, ψ z = ψ₀ z}`; the previous
  step shows `supp f - supp f ⊆ H` and `supp f̂ - ψ₀ ⊆ H^⊥`, and the duality
  `|H| · |H^⊥| = |G|` (`card_subgroup_mul_card_annihilator`) closes the counting argument,
  forcing `supp f` to be *exactly* a coset of `H`.
* `FourierFA.IsExtremal.isCosetModulation` and the two-sided
  `FourierFA.extremal_iff_isCosetModulation` : the structure theorem.

Consequences recorded here:

* `FourierFA.IsExtremal.card_supp_dvd` : the support of an extremal has cardinality *dividing*
  `|G|` — a purely arithmetic obstruction (e.g. for `|G|` prime only `1` and `|G|` occur).
* `FourierFA.IsExtremal.norm_eq_of_mem_supp` : `|f|` is constant on `supp f`.
* `FourierFA.IsExtremal.supp_eq_coset` : `supp f` is a coset of a subgroup.
-/

import Mathlib
import Catalog.Shared.FourierFiniteAbelian
import Catalog.Shared.FourierSubgroupDuality
import Catalog.Shared.FourierExtremals

open Finset Fintype ComplexConjugate

namespace FourierFA

/-! ## A quantitative equality case in the triangle inequality -/

/-- If a complex number has real part equal to its modulus, it is that nonnegative real. -/
lemma eq_norm_of_re_eq_norm {z : ℂ} (h : z.re = ‖z‖) : z = ((‖z‖ : ℝ) : ℂ) := by
  have hsq : ‖z‖ ^ 2 = z.re ^ 2 + z.im ^ 2 := by
    rw [Complex.norm_eq_sqrt_sq_add_sq, Real.sq_sqrt (by positivity)]
  rw [h] at hsq
  have him : z.im = 0 := by
    have h2 : z.im ^ 2 = 0 := by linarith
    exact pow_eq_zero_iff (n := 2) (by norm_num) |>.1 h2
  apply Complex.ext <;> simp [him, h]

/-- **Equality case of the triangle inequality for a finite sum of complex numbers**, in a
division-free form: if `‖∑ z j‖ = ∑ ‖z j‖` then every summand is a nonnegative multiple of
the sum, namely `‖∑ z‖ · z i = ‖z i‖ · ∑ z`. -/
lemma norm_sum_eq_sum_norm_phase {ι : Type*} (s : Finset ι) (z : ι → ℂ)
    (h : ‖∑ j ∈ s, z j‖ = ∑ j ∈ s, ‖z j‖) {i : ι} (hi : i ∈ s) :
    ((‖∑ j ∈ s, z j‖ : ℝ) : ℂ) * z i = ((‖z i‖ : ℝ) : ℂ) * ∑ j ∈ s, z j := by
  set T := ∑ j ∈ s, z j with hTdef
  by_cases hT : T = 0
  · have h0 : ∑ j ∈ s, ‖z j‖ = 0 := by rw [← h, hT, norm_zero]
    have hzi : ‖z i‖ = 0 :=
      (Finset.sum_eq_zero_iff_of_nonneg (fun j _ => norm_nonneg _)).1 h0 i hi
    simp [hT, norm_eq_zero.1 hzi]
  · have hTn : (0 : ℝ) < ‖T‖ := norm_pos_iff.2 hT
    set w : ℂ := conj T / (‖T‖ : ℂ) with hw
    have hTC : ((‖T‖ : ℝ) : ℂ) ≠ 0 := by exact_mod_cast hTn.ne'
    have hwT : w * T = ((‖T‖ : ℝ) : ℂ) := by
      rw [hw, div_mul_eq_mul_div, Complex.conj_mul']
      field_simp
    have hwnorm : ‖w‖ = 1 := by
      rw [hw, norm_div, RCLike.norm_conj]
      simp [hTn.ne']
    have hle : ∀ j ∈ s, (w * z j).re ≤ ‖z j‖ := by
      intro j _
      calc (w * z j).re ≤ ‖w * z j‖ := Complex.re_le_norm _
        _ = ‖z j‖ := by rw [norm_mul, hwnorm, one_mul]
    have hsum : ∑ j ∈ s, (w * z j).re = ∑ j ∈ s, ‖z j‖ := by
      have hre : ∑ j ∈ s, (w * z j).re = (w * T).re := by
        rw [hTdef, Finset.mul_sum, Complex.re_sum]
      rw [hre, hwT]
      simp [h]
    have heq := (Finset.sum_eq_sum_iff_of_le hle).1 hsum i hi
    have hwz : w * z i = ((‖z i‖ : ℝ) : ℂ) := by
      have hh : (w * z i).re = ‖w * z i‖ := by rw [norm_mul, hwnorm, one_mul]; exact heq
      have h2 := eq_norm_of_re_eq_norm hh
      rwa [norm_mul, hwnorm, one_mul] at h2
    calc ((‖T‖ : ℝ) : ℂ) * z i = (w * T) * z i := by rw [hwT]
      _ = (w * z i) * T := by ring
      _ = ((‖z i‖ : ℝ) : ℂ) * T := by rw [hwz]

variable {G : Type*} [AddCommGroup G] [Fintype G] [DecidableEq G]

/-! ## The `ℓ¹` norm and elementary support manipulations -/

/-- The `ℓ¹` norm of `f`, written as a sum over its support. -/
noncomputable def l1norm (f : G → ℂ) : ℝ := ∑ x ∈ supp f, ‖f x‖

omit [DecidableEq G] in
lemma dft_eq_sum_supp (f : G → ℂ) (ψ : AddChar G ℂ) :
    dft f ψ = ∑ x ∈ supp f, conj (ψ x) * f x := by
  rw [dft]
  refine (Finset.sum_subset (Finset.subset_univ _) ?_).symm
  intro x _ hx
  have : f x = 0 := by
    by_contra h
    exact hx (mem_supp.2 h)
  simp [this]

omit [DecidableEq G] in
lemma norm_dft_le_l1norm (f : G → ℂ) (ψ : AddChar G ℂ) : ‖dft f ψ‖ ≤ l1norm f := by
  rw [dft_eq_sum_supp, l1norm]
  calc ‖∑ x ∈ supp f, conj (ψ x) * f x‖ ≤ ∑ x ∈ supp f, ‖conj (ψ x) * f x‖ := norm_sum_le _ _
    _ = ∑ x ∈ supp f, ‖f x‖ := by
        refine Finset.sum_congr rfl fun x _ => ?_
        rw [norm_mul, RCLike.norm_conj, AddChar.norm_apply, one_mul]

omit [AddCommGroup G] [DecidableEq G] in
lemma l1norm_pos {f : G → ℂ} (hf : f ≠ 0) : 0 < l1norm f := by
  obtain ⟨x₀, hx₀⟩ : ∃ x₀ : G, f x₀ ≠ 0 := by
    by_contra h
    push_neg at h
    exact hf (funext h)
  refine Finset.sum_pos' (fun x _ => norm_nonneg _) ⟨x₀, mem_supp.2 hx₀, ?_⟩
  exact norm_pos_iff.2 hx₀

omit [AddCommGroup G] [DecidableEq G] in
lemma sum_sq_supp (f : G → ℂ) : ∑ x ∈ supp f, ‖f x‖ ^ 2 = ∑ x : G, ‖f x‖ ^ 2 := by
  refine Finset.sum_subset (Finset.subset_univ _) ?_
  intro x _ hx
  have : f x = 0 := by
    by_contra h
    exact hx (mem_supp.2 h)
  simp [this]

omit [AddCommGroup G] [DecidableEq G] in
lemma supp_nonempty {f : G → ℂ} (hf : f ≠ 0) : (supp f).Nonempty := by
  obtain ⟨x₀, hx₀⟩ : ∃ x₀ : G, f x₀ ≠ 0 := by
    by_contra h
    push_neg at h
    exact hf (funext h)
  exact ⟨x₀, mem_supp.2 hx₀⟩

lemma dft_ne_zero {f : G → ℂ} (hf : f ≠ 0) : dft f ≠ 0 := fun h => hf (dft_injective (by simp [h]))

omit [DecidableEq G] in
/-- An extremal function is nonzero. -/
lemma IsExtremal.ne_zero {f : G → ℂ} (hext : IsExtremal f) : f ≠ 0 := by
  intro h
  rw [IsExtremal, h] at hext
  have hs : supp (0 : G → ℂ) = (∅ : Finset G) := by
    ext x; simp [mem_supp]
  rw [hs] at hext
  simp at hext
  exact absurd hext.symm (Fintype.card_ne_zero (α := G))

/-! ## Step 1: the spectrum has constant modulus `‖f‖₁` -/

/-- **Equality analysis of Plancherel + Cauchy–Schwarz.**  If `f` is extremal then every
nonzero Fourier coefficient has the maximal possible modulus `‖f‖₁`. -/
theorem IsExtremal.norm_dft_eq_l1norm {f : G → ℂ} (hext : IsExtremal f)
    {ψ : AddChar G ℂ} (hψ : ψ ∈ supp (dft f)) : ‖dft f ψ‖ = l1norm f := by
  classical
  set S := supp f with hS
  set A := supp (dft f) with hA
  set N1 := l1norm f with hN1
  set N2 := ∑ x : G, ‖f x‖ ^ 2 with hN2
  have hN2nonneg : 0 ≤ N2 := Finset.sum_nonneg fun x _ => by positivity
  -- Plancherel, with the left side restricted to the spectrum
  have hrestrict : ∑ ψ ∈ A, ‖dft f ψ‖ ^ 2 = ∑ ψ : AddChar G ℂ, ‖dft f ψ‖ ^ 2 := by
    refine Finset.sum_subset (Finset.subset_univ A) ?_
    intro φ _ hφ
    have hz : dft f φ = 0 := by
      by_contra h
      exact hφ (mem_supp.2 h)
    simp [hz]
  have hplan : ∑ ψ ∈ A, ‖dft f ψ‖ ^ 2 = (Fintype.card G : ℝ) * N2 := by
    rw [hrestrict, parseval_norm f, hN2]
  -- each coefficient is at most `N1`
  have hterm : ∀ φ ∈ A, ‖dft f φ‖ ^ 2 ≤ N1 ^ 2 := fun φ _ =>
    pow_le_pow_left₀ (norm_nonneg _) (norm_dft_le_l1norm f φ) 2
  have hupper : ∑ φ ∈ A, ‖dft f φ‖ ^ 2 ≤ ∑ _φ ∈ A, N1 ^ 2 := Finset.sum_le_sum hterm
  have hconst : ∑ _φ ∈ A, N1 ^ 2 = (A.card : ℝ) * N1 ^ 2 := by
    rw [Finset.sum_const, nsmul_eq_mul]
  -- Cauchy–Schwarz
  have hcs : N1 ^ 2 ≤ (S.card : ℝ) * N2 := by
    have h : (∑ x ∈ S, ‖f x‖) ^ 2 ≤ (S.card : ℝ) * ∑ x ∈ S, ‖f x‖ ^ 2 :=
      sq_sum_le_card_mul_sum_sq
    rw [hS, sum_sq_supp f] at h
    rw [hN1, l1norm, hN2, hS]
    exact h
  -- extremality closes the loop
  have hcard : (S.card : ℝ) * (A.card : ℝ) = (Fintype.card G : ℝ) := by
    exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) hext
  have hAnn : (0 : ℝ) ≤ (A.card : ℝ) := by positivity
  have hchain : (A.card : ℝ) * N1 ^ 2 ≤ (Fintype.card G : ℝ) * N2 := by
    calc (A.card : ℝ) * N1 ^ 2 ≤ (A.card : ℝ) * ((S.card : ℝ) * N2) :=
          mul_le_mul_of_nonneg_left hcs hAnn
      _ = (Fintype.card G : ℝ) * N2 := by rw [← hcard]; ring
  have hsumeq : ∑ φ ∈ A, ‖dft f φ‖ ^ 2 = ∑ _φ ∈ A, N1 ^ 2 := by
    rw [hconst]
    linarith [hplan, hupper, hchain, hconst]
  have hfin := (Finset.sum_eq_sum_iff_of_le hterm).1 hsumeq ψ hψ
  have h0 : 0 ≤ N1 := le_of_lt (l1norm_pos hext.ne_zero)
  nlinarith [norm_nonneg (dft f ψ), hfin]

/-! ## Step 2: alignment of the phases -/

/-- Extremality forces all summands of `f̂(ψ) = ∑_{x ∈ supp f} conj (ψ x) f x` to be
positively proportional. -/
theorem IsExtremal.phase_align {f : G → ℂ} (hext : IsExtremal f)
    {ψ : AddChar G ℂ} (hψ : ψ ∈ supp (dft f)) {x : G} (hx : x ∈ supp f) :
    ((l1norm f : ℝ) : ℂ) * (conj (ψ x) * f x) = ((‖f x‖ : ℝ) : ℂ) * dft f ψ := by
  have hnormz : ∀ y : G, ‖conj (ψ y) * f y‖ = ‖f y‖ := by
    intro y
    rw [norm_mul, RCLike.norm_conj, AddChar.norm_apply, one_mul]
  have hsum : ‖∑ y ∈ supp f, conj (ψ y) * f y‖ = ∑ y ∈ supp f, ‖conj (ψ y) * f y‖ := by
    rw [← dft_eq_sum_supp]
    rw [hext.norm_dft_eq_l1norm hψ, l1norm]
    exact Finset.sum_congr rfl fun y _ => (hnormz y).symm
  have h := norm_sum_eq_sum_norm_phase (supp f) (fun y => conj (ψ y) * f y) hsum hx
  rw [← dft_eq_sum_supp] at h
  rw [hext.norm_dft_eq_l1norm hψ] at h
  rw [hnormz x] at h
  exact h

/-! ## Step 3: `|f|` is constant on the support -/

/-- Fourier inversion turns the phase alignment into the statement that `|f|` is constant on
`supp f`, with the explicit value `‖f‖₁ · |supp f̂| / |G|`. -/
theorem IsExtremal.card_mul_norm_eq {f : G → ℂ} (hext : IsExtremal f)
    {x : G} (hx : x ∈ supp f) :
    ‖f x‖ * (Fintype.card G : ℝ) = l1norm f * ((supp (dft f)).card : ℝ) := by
  classical
  have hfx : f x ≠ 0 := mem_supp.1 hx
  -- inversion
  have hcardC : (Fintype.card G : ℂ) ≠ 0 := by
    exact_mod_cast (Fintype.card_ne_zero (α := G))
  have hinv : (Fintype.card G : ℂ) * f x = ∑ ψ : AddChar G ℂ, ψ x * dft f ψ := by
    conv_lhs => rw [← dft_inversion f]
    rw [idft, ← mul_assoc, mul_inv_cancel₀ hcardC, one_mul]
  have hrestrict : ∑ ψ : AddChar G ℂ, ψ x * dft f ψ = ∑ ψ ∈ supp (dft f), ψ x * dft f ψ := by
    refine (Finset.sum_subset (Finset.subset_univ _) ?_).symm
    intro ψ _ hψ
    have : dft f ψ = 0 := by
      by_contra h
      exact hψ (mem_supp.2 h)
    simp [this]
  -- each spectral term contributes the same value
  have hterm : ∀ ψ ∈ supp (dft f),
      ((‖f x‖ : ℝ) : ℂ) * (ψ x * dft f ψ) = ((l1norm f : ℝ) : ℂ) * f x := by
    intro ψ hψ
    have h := hext.phase_align hψ hx
    have hunit : ψ x * conj (ψ x) = 1 := by
      have : ‖ψ x‖ = 1 := AddChar.norm_apply _ _
      have h2 : (Complex.normSq (ψ x) : ℂ) = 1 := by
        rw [Complex.normSq_eq_norm_sq, this]; norm_num
      rw [Complex.mul_conj]
      exact h2
    calc ((‖f x‖ : ℝ) : ℂ) * (ψ x * dft f ψ)
        = ψ x * (((‖f x‖ : ℝ) : ℂ) * dft f ψ) := by ring
      _ = ψ x * (((l1norm f : ℝ) : ℂ) * (conj (ψ x) * f x)) := by rw [h]
      _ = ((l1norm f : ℝ) : ℂ) * ((ψ x * conj (ψ x)) * f x) := by ring
      _ = ((l1norm f : ℝ) : ℂ) * f x := by rw [hunit, one_mul]
  have hbig : ((‖f x‖ : ℝ) : ℂ) * ((Fintype.card G : ℂ) * f x)
      = ((supp (dft f)).card : ℂ) * (((l1norm f : ℝ) : ℂ) * f x) := by
    rw [hinv, hrestrict, Finset.mul_sum, Finset.sum_congr rfl hterm, Finset.sum_const,
      nsmul_eq_mul]
  have hcancel : ((‖f x‖ : ℝ) : ℂ) * (Fintype.card G : ℂ)
      = ((l1norm f : ℝ) : ℂ) * ((supp (dft f)).card : ℂ) := by
    have h2 : (((‖f x‖ : ℝ) : ℂ) * (Fintype.card G : ℂ)) * f x
        = (((l1norm f : ℝ) : ℂ) * ((supp (dft f)).card : ℂ)) * f x := by
      linear_combination hbig
    exact mul_right_cancel₀ hfx h2
  exact_mod_cast hcancel

/-- `|f|` is constant on the support of an extremal function. -/
theorem IsExtremal.norm_eq_of_mem_supp {f : G → ℂ} (hext : IsExtremal f)
    {x y : G} (hx : x ∈ supp f) (hy : y ∈ supp f) : ‖f x‖ = ‖f y‖ := by
  have h1 := hext.card_mul_norm_eq hx
  have h2 := hext.card_mul_norm_eq hy
  have hpos : (0 : ℝ) < (Fintype.card G : ℝ) := by exact_mod_cast Fintype.card_pos (α := G)
  have : ‖f x‖ * (Fintype.card G : ℝ) = ‖f y‖ * (Fintype.card G : ℝ) := by rw [h1, h2]
  exact mul_right_cancel₀ hpos.ne' this

/-! ## Step 4: `conj (ψ x) f x` is independent of `x ∈ supp f` -/

theorem IsExtremal.conj_mul_eq {f : G → ℂ} (hext : IsExtremal f)
    {ψ : AddChar G ℂ} (hψ : ψ ∈ supp (dft f)) {x y : G} (hx : x ∈ supp f) (hy : y ∈ supp f) :
    conj (ψ x) * f x = conj (ψ y) * f y := by
  have h1 := hext.phase_align hψ hx
  have h2 := hext.phase_align hψ hy
  have hnorm : ‖f x‖ = ‖f y‖ := hext.norm_eq_of_mem_supp hx hy
  rw [hnorm] at h1
  have hl1 : ((l1norm f : ℝ) : ℂ) ≠ 0 := by
    have := l1norm_pos hext.ne_zero
    exact_mod_cast this.ne'
  exact mul_left_cancel₀ hl1 (h1.trans h2.symm)

/-! ## Step 5: the phase subgroup -/

variable (f : G → ℂ)

/-- The subgroup on which all characters in the spectrum of `f` agree with a fixed spectral
character `ψ₀`.  For an extremal `f`, this subgroup is exactly the difference set of the
support. -/
def phaseSubgroup (ψ₀ : AddChar G ℂ) : AddSubgroup G where
  carrier := {z : G | ∀ ψ ∈ supp (dft f), ψ z = ψ₀ z}
  zero_mem' := by intro ψ _; simp
  add_mem' := by
    intro a b ha hb ψ hψ
    rw [ψ.map_add_eq_mul, ψ₀.map_add_eq_mul, ha ψ hψ, hb ψ hψ]
  neg_mem' := by
    intro a ha ψ hψ
    rw [AddChar.map_neg_eq_inv, AddChar.map_neg_eq_inv, ha ψ hψ]

variable {f}

omit [DecidableEq G] in
@[simp] lemma mem_phaseSubgroup {ψ₀ : AddChar G ℂ} {z : G} :
    z ∈ phaseSubgroup f ψ₀ ↔ ∀ ψ ∈ supp (dft f), ψ z = ψ₀ z := Iff.rfl

/-- The difference set of the support of an extremal function lies in the phase subgroup. -/
theorem IsExtremal.sub_mem_phaseSubgroup (hext : IsExtremal f) {ψ₀ : AddChar G ℂ}
    (hψ₀ : ψ₀ ∈ supp (dft f)) {x y : G} (hx : x ∈ supp f) (hy : y ∈ supp f) :
    x - y ∈ phaseSubgroup f ψ₀ := by
  intro ψ hψ
  have hfx : f x ≠ 0 := mem_supp.1 hx
  have hfy : f y ≠ 0 := mem_supp.1 hy
  have hchar : ∀ (φ : AddChar G ℂ) (z : G), φ z ≠ 0 := by
    intro φ z h
    have hn := AddChar.norm_apply φ z
    rw [h] at hn
    simp at hn
  have hunit : ∀ (φ : AddChar G ℂ) (z : G), φ z * conj (φ z) = 1 := by
    intro φ z
    have hn : ‖φ z‖ = 1 := AddChar.norm_apply _ _
    rw [Complex.mul_conj, Complex.normSq_eq_norm_sq, hn]
    norm_num
  have hsub : ∀ (φ : AddChar G ℂ), φ (x - y) = φ x * conj (φ y) := by
    intro φ
    rw [sub_eq_add_neg, φ.map_add_eq_mul, AddChar.map_neg_eq_conj]
  -- the two relations coming from `ψ` and from `ψ₀`
  have e1 : conj (ψ x) * f x = conj (ψ y) * f y := hext.conj_mul_eq hψ hx hy
  have e2 : conj (ψ₀ x) * f x = conj (ψ₀ y) * f y := hext.conj_mul_eq hψ₀ hx hy
  have h1 : ψ y * f x = ψ x * f y := by
    calc ψ y * f x = (ψ x * conj (ψ x)) * (ψ y * f x) := by rw [hunit]; ring
      _ = (ψ x * ψ y) * (conj (ψ x) * f x) := by ring
      _ = (ψ x * ψ y) * (conj (ψ y) * f y) := by rw [e1]
      _ = (ψ y * conj (ψ y)) * (ψ x * f y) := by ring
      _ = ψ x * f y := by rw [hunit]; ring
  have h2 : ψ₀ y * f x = ψ₀ x * f y := by
    calc ψ₀ y * f x = (ψ₀ x * conj (ψ₀ x)) * (ψ₀ y * f x) := by rw [hunit]; ring
      _ = (ψ₀ x * ψ₀ y) * (conj (ψ₀ x) * f x) := by ring
      _ = (ψ₀ x * ψ₀ y) * (conj (ψ₀ y) * f y) := by rw [e2]
      _ = (ψ₀ y * conj (ψ₀ y)) * (ψ₀ x * f y) := by ring
      _ = ψ₀ x * f y := by rw [hunit]; ring
  -- the key multiplicative identity
  have key : ψ x * ψ₀ y = ψ y * ψ₀ x := by
    have hmul : (ψ x * ψ₀ y) * (f x * f y) = (ψ y * ψ₀ x) * (f x * f y) := by
      calc (ψ x * ψ₀ y) * (f x * f y) = (ψ x * f y) * (ψ₀ y * f x) := by ring
        _ = (ψ y * f x) * (ψ₀ x * f y) := by rw [← h1, ← h2]
        _ = (ψ y * ψ₀ x) * (f x * f y) := by ring
    exact mul_right_cancel₀ (mul_ne_zero hfx hfy) hmul
  -- conclude by cancelling the (nonzero) values at `y`
  rw [hsub, hsub]
  refine mul_right_cancel₀ (mul_ne_zero (hchar ψ y) (hchar ψ₀ y)) ?_
  calc (ψ x * conj (ψ y)) * (ψ y * ψ₀ y)
      = (ψ y * conj (ψ y)) * (ψ x * ψ₀ y) := by ring
    _ = ψ x * ψ₀ y := by rw [hunit]; ring
    _ = ψ y * ψ₀ x := key
    _ = (ψ₀ y * conj (ψ₀ y)) * (ψ₀ x * ψ y) := by rw [hunit]; ring
    _ = (ψ₀ x * conj (ψ₀ y)) * (ψ y * ψ₀ y) := by ring

/-! ## Step 6: counting — the support is exactly a coset of the phase subgroup -/

/-- **The core counting step.**  For an extremal `f`, a point `a` of the support and a character
`ψ₀` of the spectrum, the support of `f` is *exactly* the coset `a + H` of the phase subgroup
`H = phaseSubgroup f ψ₀`.

One inclusion is `IsExtremal.sub_mem_phaseSubgroup`; the other follows from the duality
`|H| · |H^⊥| = |G|` together with the injections `supp f ↪ H` and `supp f̂ ↪ H^⊥`, which force
both to be bijections. -/
theorem IsExtremal.mem_supp_iff_sub_mem (hext : IsExtremal f) {ψ₀ : AddChar G ℂ}
    (hψ₀ : ψ₀ ∈ supp (dft f)) {a : G} (ha : a ∈ supp f) (x : G) :
    x ∈ supp f ↔ x - a ∈ phaseSubgroup f ψ₀ := by
  classical
  letI : DecidablePred (· ∈ phaseSubgroup f ψ₀) := Classical.decPred _
  set H := phaseSubgroup f ψ₀ with hH
  -- `supp f ↪ H` via `x ↦ x - a`
  have hmaps : ∀ y ∈ supp f, y - a ∈ subFinset H :=
    fun y hy => mem_subFinset.2 (hext.sub_mem_phaseSubgroup hψ₀ hy ha)
  have hcard1 : (supp f).card ≤ (subFinset H).card := by
    refine Finset.card_le_card_of_injOn (fun y => y - a) hmaps ?_
    intro u _ v _ huv
    exact sub_left_injective huv
  -- `supp f̂ ↪ H^⊥` via `ψ ↦ ψ - ψ₀`
  have hcard2 : (supp (dft f)).card ≤ (annih H).card := by
    refine Finset.card_le_card_of_injOn (fun ψ => ψ - ψ₀) ?_ ?_
    · intro ψ hψ
      refine mem_annih.2 fun z hz => ?_
      have hzz : ψ z = ψ₀ z := hz ψ hψ
      have hne : ψ₀ z ≠ 0 := by
        intro h
        have hn := AddChar.norm_apply ψ₀ z
        rw [h] at hn
        simp at hn
      rw [AddChar.sub_apply' ψ ψ₀ z, hzz, div_self hne]
    · intro u _ v _ huv
      exact sub_left_injective huv
  -- duality
  have hdual : (subFinset H).card * (annih H).card = Fintype.card G :=
    card_subgroup_mul_card_annihilator
  have hAp : 0 < (supp (dft f)).card :=
    Finset.card_pos.2 ⟨ψ₀, hψ₀⟩
  -- the two injections are bijections
  have hchain1 : (supp f).card * (supp (dft f)).card
      ≤ (subFinset H).card * (supp (dft f)).card := Nat.mul_le_mul_right _ hcard1
  have hchain2 : (subFinset H).card * (supp (dft f)).card
      ≤ (subFinset H).card * (annih H).card := Nat.mul_le_mul_left _ hcard2
  have hle : (subFinset H).card * (supp (dft f)).card
      ≤ (supp f).card * (supp (dft f)).card := by
    calc (subFinset H).card * (supp (dft f)).card
        ≤ (subFinset H).card * (annih H).card := hchain2
      _ = Fintype.card G := hdual
      _ = (supp f).card * (supp (dft f)).card := hext.symm
  have heq : (subFinset H).card * (supp (dft f)).card = (supp f).card * (supp (dft f)).card :=
    le_antisymm hle hchain1
  have hSeq : (supp f).card = (subFinset H).card :=
    (Nat.eq_of_mul_eq_mul_right hAp heq).symm
  -- hence `supp f - a = H` as finsets
  have himg : (supp f).image (fun y => y - a) = subFinset H := by
    refine Finset.eq_of_subset_of_card_le ?_ ?_
    · intro z hz
      obtain ⟨y, hy, rfl⟩ := Finset.mem_image.1 hz
      exact hmaps y hy
    · rw [Finset.card_image_of_injective _ (fun u v huv => sub_left_injective huv), ← hSeq]
  constructor
  · intro hx
    exact hext.sub_mem_phaseSubgroup hψ₀ hx ha
  · intro hx
    have hz : x - a ∈ (supp f).image (fun y => y - a) := by rw [himg]; exact mem_subFinset.2 hx
    obtain ⟨y, hy, hxy⟩ := Finset.mem_image.1 hz
    have : y = x := by
      have := sub_left_injective hxy
      exact this
    rwa [this] at hy

/-! ## The structure theorem -/

/-- `f` is a **modulated coset indicator**: there are a subgroup `H`, a nonzero scalar `c`,
a character `χ` and a base point `a` with `f = c · χ · 1_{a + H}`. -/
def IsCosetModulation (f : G → ℂ) : Prop :=
  ∃ (H : AddSubgroup G) (c : ℂ) (χ : AddChar G ℂ) (a : G), c ≠ 0 ∧
    (∀ x, x - a ∈ H → f x = c * χ x) ∧ (∀ x, x - a ∉ H → f x = 0)

/-- **Rigidity (the `⇒` direction).**  Every extremal function for the Donoho–Stark uncertainty
principle is a nonzero multiple of a modulated indicator of a coset of a subgroup. -/
theorem IsExtremal.isCosetModulation (hext : IsExtremal f) : IsCosetModulation f := by
  classical
  obtain ⟨a, ha⟩ := supp_nonempty hext.ne_zero
  obtain ⟨ψ₀, hψ₀⟩ := supp_nonempty (dft_ne_zero hext.ne_zero)
  have hfa : f a ≠ 0 := mem_supp.1 ha
  have hψ₀a : conj (ψ₀ a) ≠ 0 := by
    intro h
    have hn := AddChar.norm_apply ψ₀ a
    rw [← RCLike.norm_conj, h] at hn
    simp at hn
  refine ⟨phaseSubgroup f ψ₀, conj (ψ₀ a) * f a, ψ₀, a, mul_ne_zero hψ₀a hfa, ?_, ?_⟩
  · intro x hx
    have hxs : x ∈ supp f := (hext.mem_supp_iff_sub_mem hψ₀ ha x).2 hx
    have hkey : conj (ψ₀ x) * f x = conj (ψ₀ a) * f a := hext.conj_mul_eq hψ₀ hxs ha
    have hunit : ψ₀ x * conj (ψ₀ x) = 1 := by
      have hn : ‖ψ₀ x‖ = 1 := AddChar.norm_apply _ _
      rw [Complex.mul_conj, Complex.normSq_eq_norm_sq, hn]
      norm_num
    calc f x = (ψ₀ x * conj (ψ₀ x)) * f x := by rw [hunit, one_mul]
      _ = ψ₀ x * (conj (ψ₀ x) * f x) := by ring
      _ = ψ₀ x * (conj (ψ₀ a) * f a) := by rw [hkey]
      _ = (conj (ψ₀ a) * f a) * ψ₀ x := by ring
  · intro x hx
    have hxs : x ∉ supp f := fun h => hx ((hext.mem_supp_iff_sub_mem hψ₀ ha x).1 h)
    by_contra h
    exact hxs (mem_supp.2 h)

/-- The easy direction, restated for `IsCosetModulation`: modulated coset indicators are
extremal.  (This repackages `FourierFA.isExtremal_coset_modulation`.) -/
theorem IsCosetModulation.isExtremal (h : IsCosetModulation f) : IsExtremal f := by
  classical
  obtain ⟨H, c, χ, a, hc, h₁, h₂⟩ := h
  letI : DecidablePred (· ∈ H) := Classical.decPred _
  have hf : f = c • modul χ (transl a (indic H)) := by
    funext x
    by_cases hx : x - a ∈ H
    · rw [h₁ x hx]
      simp [modul, transl, indic, hx, Pi.smul_apply, smul_eq_mul]
    · rw [h₂ x hx]
      simp [modul, transl, indic, hx]
  rw [hf]
  exact isExtremal_coset_modulation H hc χ a

/-- **The extremal problem for the Donoho–Stark uncertainty principle, solved.**
`|supp f| · |supp f̂| = |G|` holds *if and only if* `f` is a nonzero multiple of a modulated
indicator of a coset of a subgroup of `G`. -/
theorem extremal_iff_isCosetModulation : IsExtremal f ↔ IsCosetModulation f :=
  ⟨fun h => h.isCosetModulation, fun h => h.isExtremal⟩

/-! ## Consequences of rigidity -/

/-- The support of an extremal function is a coset of a subgroup; in particular its cardinality
divides `|G|`. -/
theorem IsExtremal.card_supp_dvd (hext : IsExtremal f) : (supp f).card ∣ Fintype.card G := by
  classical
  obtain ⟨a, ha⟩ := supp_nonempty hext.ne_zero
  obtain ⟨ψ₀, hψ₀⟩ := supp_nonempty (dft_ne_zero hext.ne_zero)
  letI : DecidablePred (· ∈ phaseSubgroup f ψ₀) := Classical.decPred _
  set H := phaseSubgroup f ψ₀ with hH
  have himg : supp f = (subFinset H).image (fun z => z + a) := by
    ext x
    simp only [Finset.mem_image, mem_subFinset]
    constructor
    · intro hx
      exact ⟨x - a, (hext.mem_supp_iff_sub_mem hψ₀ ha x).1 hx, by abel⟩
    · rintro ⟨z, hz, rfl⟩
      refine (hext.mem_supp_iff_sub_mem hψ₀ ha _).2 ?_
      simpa using hz
  have hcard : (supp f).card = (subFinset H).card := by
    rw [himg, Finset.card_image_of_injective _ (add_left_injective a)]
  rw [hcard, ← card_subgroup_mul_card_annihilator (H := H)]
  exact Dvd.intro _ rfl

/-- The Fourier transform of an extremal function also has constant modulus on its (spectral)
support, and the two constants are linked by `|f(x)| · |G| = ‖f‖₁ · |supp f̂|`. -/
theorem IsExtremal.norm_dft_const (hext : IsExtremal f) {ψ χ : AddChar G ℂ}
    (hψ : ψ ∈ supp (dft f)) (hχ : χ ∈ supp (dft f)) : ‖dft f ψ‖ = ‖dft f χ‖ := by
  rw [hext.norm_dft_eq_l1norm hψ, hext.norm_dft_eq_l1norm hχ]

end FourierFA