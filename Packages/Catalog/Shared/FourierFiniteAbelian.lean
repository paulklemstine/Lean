/-
# Fourier analysis on finite abelian groups

This file develops the discrete Fourier transform (DFT) on an arbitrary finite abelian
group `G`, viewed as the decomposition of the regular representation into the characters
of `G` (equivalently, as the expansion in the Pontryagin dual `AddChar G ℂ`).

Main results:

* `FourierFA.sum_char_sub` : the orthogonality relation `∑ ψ, ψ (x - y) = |G| ⬝ [x = y]`.
* `FourierFA.dft_inversion` : Fourier inversion `f = idft (dft f)`.
* `FourierFA.parseval` : `∑_ψ f̂ ψ * conj (ĝ ψ) = |G| * ∑_x f x * conj (g x)`.
* `FourierFA.parseval_norm` : `∑_ψ ‖f̂ ψ‖² = |G| * ∑_x ‖f x‖²`.
* `FourierFA.dft_conv` : the convolution theorem `(f ∗ g)^ = f̂ · ĝ`.
* `FourierFA.dft_injective`, `FourierFA.dftEquiv` : the DFT is a linear equivalence.
* `FourierFA.uncertainty` : the Donoho–Stark uncertainty principle
  `|supp f| * |supp f̂| ≥ |G|` for `f ≠ 0`.
* `FourierFA.uncertainty_sharp_delta` : the bound is attained (Dirac deltas).
* `FourierFA.sum_char_mul_conj` : orthogonality of characters summed over the group.
* `FourierFA.idft_inversion`, `FourierFA.dftEquiv` : `idft` is a two-sided inverse, so the DFT
  is a linear equivalence with explicit inverse.
* `FourierFA.dft_dft` : `F² = |G| ⬝ reflection`, via Pontryagin's canonical embedding.
-/

import Mathlib

open Finset Fintype ComplexConjugate
open scoped BigOperators

namespace FourierFA

variable {G : Type*} [AddCommGroup G] [Fintype G] [DecidableEq G]

/-! ## Definitions -/

/-- The discrete Fourier transform of `f : G → ℂ`, indexed by the Pontryagin dual of `G`. -/
noncomputable def dft (f : G → ℂ) (ψ : AddChar G ℂ) : ℂ := ∑ x, conj (ψ x) * f x

/-- The inverse discrete Fourier transform. -/
noncomputable def idft (F : AddChar G ℂ → ℂ) (x : G) : ℂ :=
  (Fintype.card G : ℂ)⁻¹ * ∑ ψ : AddChar G ℂ, ψ x * F ψ

/-- Convolution of two functions on `G`. -/
noncomputable def conv (f g : G → ℂ) (x : G) : ℂ := ∑ y, f y * g (x - y)

/-- The support of `f`, as a `Finset`. -/
noncomputable def supp (f : G → ℂ) : Finset G := Finset.univ.filter (fun x => f x ≠ 0)

omit [AddCommGroup G] [DecidableEq G] in
lemma mem_supp {f : G → ℂ} {x : G} : x ∈ supp f ↔ f x ≠ 0 := by
  simp [supp]

/-! ## Orthogonality -/

/-- Orthogonality of characters, in the "dual" form: summing a fixed group element over all
characters. -/
lemma sum_char_sub (x y : G) :
    ∑ ψ : AddChar G ℂ, ψ x * conj (ψ y) = if x = y then (Fintype.card G : ℂ) else 0 := by
  have h : ∀ ψ : AddChar G ℂ, ψ x * conj (ψ y) = ψ (x - y) := by
    intro ψ
    rw [sub_eq_add_neg, ψ.map_add_eq_mul, AddChar.map_neg_eq_conj]
  simp_rw [h]
  rw [AddChar.sum_apply_eq_ite (x - y)]
  simp [sub_eq_zero]

omit [DecidableEq G] in
/-- Orthogonality of characters, in the "primal" form: summing over the group. -/
lemma sum_char_mul_conj (ψ χ : AddChar G ℂ) :
    ∑ x : G, ψ x * conj (χ x) = if ψ = χ then (Fintype.card G : ℂ) else 0 := by
  classical
  have h : ∀ x : G, ψ x * conj (χ x) = (ψ - χ) x := by
    intro x
    rw [AddChar.sub_apply' ψ χ x, div_eq_mul_inv, AddChar.inv_apply_eq_conj]
  simp_rw [h]
  rw [AddChar.sum_eq_ite (ψ - χ)]
  simp [sub_eq_zero]

/-! ## Linearity -/

omit [DecidableEq G] in
@[simp] lemma dft_zero : dft (0 : G → ℂ) = 0 := by
  funext ψ; simp [dft]

omit [DecidableEq G] in
lemma dft_add (f g : G → ℂ) : dft (f + g) = dft f + dft g := by
  funext ψ; simp [dft, mul_add, Finset.sum_add_distrib]

omit [DecidableEq G] in
lemma dft_smul (c : ℂ) (f : G → ℂ) : dft (c • f) = c • dft f := by
  funext ψ; simp [dft, Finset.mul_sum, mul_left_comm]

/-- The DFT as a `ℂ`-linear map. -/
noncomputable def dftLinear : (G → ℂ) →ₗ[ℂ] (AddChar G ℂ → ℂ) where
  toFun := dft
  map_add' := dft_add
  map_smul' := dft_smul

omit [DecidableEq G] in
@[simp] lemma dftLinear_apply (f : G → ℂ) : dftLinear f = dft f := rfl

/-! ## Fourier inversion -/

/-- **Fourier inversion** on a finite abelian group. -/
theorem dft_inversion (f : G → ℂ) : idft (dft f) = f := by
  funext x
  have hcard : (Fintype.card G : ℂ) ≠ 0 := by
    exact_mod_cast (Fintype.card_ne_zero (α := G))
  have key : ∑ ψ : AddChar G ℂ, ψ x * dft f ψ = (Fintype.card G : ℂ) * f x := by
    calc ∑ ψ : AddChar G ℂ, ψ x * dft f ψ
        = ∑ ψ : AddChar G ℂ, ∑ y, (ψ x * conj (ψ y)) * f y := by
          refine Finset.sum_congr rfl fun ψ _ => ?_
          rw [dft, Finset.mul_sum]
          exact Finset.sum_congr rfl fun y _ => by ring
      _ = ∑ y, (∑ ψ : AddChar G ℂ, ψ x * conj (ψ y)) * f y := by
          rw [Finset.sum_comm]
          exact Finset.sum_congr rfl fun y _ => by rw [Finset.sum_mul]
      _ = (Fintype.card G : ℂ) * f x := by
          simp_rw [sum_char_sub]
          rw [Finset.sum_eq_single x]
          · simp
          · intro y _ hy
            simp [Ne.symm hy]
          · intro h; exact absurd (Finset.mem_univ x) h
  rw [idft, key, ← mul_assoc, inv_mul_cancel₀ hcard, one_mul]

/-- The DFT is injective. -/
theorem dft_injective : Function.Injective (dft : (G → ℂ) → AddChar G ℂ → ℂ) := by
  intro f g h
  rw [← dft_inversion f, ← dft_inversion g, h]

omit [DecidableEq G] in
/-- The inverse transform really is a right inverse: `dft (idft F) = F`. -/
theorem idft_inversion (F : AddChar G ℂ → ℂ) : dft (idft F) = F := by
  funext χ
  have hcard : (Fintype.card G : ℂ) ≠ 0 := by
    exact_mod_cast (Fintype.card_ne_zero (α := G))
  have key : ∀ x : G, conj (χ x) * idft F x
      = (Fintype.card G : ℂ)⁻¹ * ∑ ψ : AddChar G ℂ, (ψ x * conj (χ x)) * F ψ := by
    intro x
    have hx : ∑ ψ : AddChar G ℂ, (ψ x * conj (χ x)) * F ψ
        = conj (χ x) * ∑ ψ : AddChar G ℂ, ψ x * F ψ := by
      rw [Finset.mul_sum]
      exact Finset.sum_congr rfl fun ψ _ => by ring
    rw [idft, hx]
    ring
  calc dft (idft F) χ = ∑ x : G, conj (χ x) * idft F x := rfl
    _ = ∑ x : G, (Fintype.card G : ℂ)⁻¹ * ∑ ψ : AddChar G ℂ, (ψ x * conj (χ x)) * F ψ :=
        Finset.sum_congr rfl fun x _ => key x
    _ = (Fintype.card G : ℂ)⁻¹ * ∑ ψ : AddChar G ℂ, (∑ x : G, ψ x * conj (χ x)) * F ψ := by
        rw [← Finset.mul_sum]
        congr 1
        rw [Finset.sum_comm]
        exact Finset.sum_congr rfl fun ψ _ => by rw [Finset.sum_mul]
    _ = F χ := by
        simp_rw [sum_char_mul_conj]
        rw [Finset.sum_eq_single χ]
        · rw [if_pos rfl, ← mul_assoc, inv_mul_cancel₀ hcard, one_mul]
        · intro ψ _ hψ; simp [hψ]
        · intro h; exact absurd (Finset.mem_univ χ) h

/-- The discrete Fourier transform as a `ℂ`-linear equivalence between functions on `G` and
functions on the Pontryagin dual, with explicit inverse `idft`. -/
noncomputable def dftEquiv : (G → ℂ) ≃ₗ[ℂ] (AddChar G ℂ → ℂ) where
  toFun := dft
  map_add' := dft_add
  map_smul' := dft_smul
  invFun := idft
  left_inv := dft_inversion
  right_inv := idft_inversion

@[simp] lemma dftEquiv_apply (f : G → ℂ) : dftEquiv f = dft f := rfl

@[simp] lemma dftEquiv_symm_apply (F : AddChar G ℂ → ℂ) :
    (dftEquiv (G := G)).symm F = idft F := rfl

/-! ## Parseval / Plancherel -/

/-- **Parseval's theorem** (sesquilinear form). -/
theorem parseval (f g : G → ℂ) :
    ∑ ψ : AddChar G ℂ, dft f ψ * conj (dft g ψ)
      = (Fintype.card G : ℂ) * ∑ x, f x * conj (g x) := by
  have expand : ∀ ψ : AddChar G ℂ, dft f ψ * conj (dft g ψ)
      = ∑ x, ∑ y, (ψ y * conj (ψ x)) * (f x * conj (g y)) := by
    intro ψ
    rw [dft, dft, map_sum, Finset.sum_mul_sum]
    refine Finset.sum_congr rfl fun x _ => Finset.sum_congr rfl fun y _ => ?_
    rw [map_mul, RCLike.conj_conj]
    ring
  have swap : ∑ ψ : AddChar G ℂ, ∑ x : G, ∑ y : G, (ψ y * conj (ψ x)) * (f x * conj (g y))
      = ∑ x : G, ∑ y : G, ∑ ψ : AddChar G ℂ, (ψ y * conj (ψ x)) * (f x * conj (g y)) := by
    rw [Finset.sum_comm]
    exact Finset.sum_congr rfl fun x _ => Finset.sum_comm
  have inner : ∀ x : G, ∑ y : G, ∑ ψ : AddChar G ℂ, (ψ y * conj (ψ x)) * (f x * conj (g y))
      = (Fintype.card G : ℂ) * (f x * conj (g x)) := by
    intro x
    have hy : ∀ y : G, ∑ ψ : AddChar G ℂ, (ψ y * conj (ψ x)) * (f x * conj (g y))
        = (if y = x then (Fintype.card G : ℂ) else 0) * (f x * conj (g y)) := by
      intro y
      rw [← Finset.sum_mul, sum_char_sub]
    simp_rw [hy]
    rw [Finset.sum_eq_single x]
    · simp
    · intro y _ hy'; simp [hy']
    · intro h; exact absurd (Finset.mem_univ x) h
  calc ∑ ψ : AddChar G ℂ, dft f ψ * conj (dft g ψ)
      = ∑ ψ : AddChar G ℂ, ∑ x : G, ∑ y : G, (ψ y * conj (ψ x)) * (f x * conj (g y)) :=
        Finset.sum_congr rfl fun ψ _ => expand ψ
    _ = ∑ x : G, ∑ y : G, ∑ ψ : AddChar G ℂ, (ψ y * conj (ψ x)) * (f x * conj (g y)) := swap
    _ = ∑ x : G, (Fintype.card G : ℂ) * (f x * conj (g x)) :=
        Finset.sum_congr rfl fun x _ => inner x
    _ = (Fintype.card G : ℂ) * ∑ x, f x * conj (g x) := by rw [Finset.mul_sum]

/-- **Parseval's theorem** for norms: the DFT is an isometry up to the factor `|G|`. -/
theorem parseval_norm (f : G → ℂ) :
    ∑ ψ : AddChar G ℂ, ‖dft f ψ‖ ^ 2 = (Fintype.card G : ℝ) * ∑ x, ‖f x‖ ^ 2 := by
  have h := parseval f f
  have hL : ∀ ψ : AddChar G ℂ, dft f ψ * conj (dft f ψ) = ((‖dft f ψ‖ ^ 2 : ℝ) : ℂ) := by
    intro ψ; rw [mul_comm, Complex.conj_mul']; norm_cast
  have hR : ∀ x : G, f x * conj (f x) = ((‖f x‖ ^ 2 : ℝ) : ℂ) := by
    intro x; rw [mul_comm, Complex.conj_mul']; norm_cast
  simp_rw [hL, hR] at h
  have hcast : ((∑ ψ : AddChar G ℂ, ‖dft f ψ‖ ^ 2 : ℝ) : ℂ)
      = (((Fintype.card G : ℝ) * ∑ x, ‖f x‖ ^ 2 : ℝ) : ℂ) := by
    push_cast
    push_cast at h
    exact h
  exact_mod_cast hcast

/-! ## The convolution theorem -/

omit [DecidableEq G] in
/-- **Convolution theorem**: the DFT turns convolution into pointwise multiplication. -/
theorem dft_conv (f g : G → ℂ) (ψ : AddChar G ℂ) :
    dft (conv f g) ψ = dft f ψ * dft g ψ := by
  have hstep : dft (conv f g) ψ = ∑ x, ∑ y, conj (ψ x) * (f y * g (x - y)) := by
    rw [dft]
    exact Finset.sum_congr rfl fun x _ => by rw [conv, Finset.mul_sum]
  rw [hstep, Finset.sum_comm]
  have : ∀ y : G, ∑ x : G, conj (ψ x) * (f y * g (x - y))
      = (conj (ψ y) * f y) * dft g ψ := by
    intro y
    rw [dft, Finset.mul_sum]
    rw [← Equiv.sum_comp (Equiv.addRight y) (fun x => conj (ψ x) * (f y * g (x - y)))]
    refine Finset.sum_congr rfl fun z _ => ?_
    have hz : (Equiv.addRight y) z = z + y := rfl
    rw [hz]
    have : conj (ψ (z + y)) = conj (ψ z) * conj (ψ y) := by
      rw [ψ.map_add_eq_mul, map_mul]
    rw [this]
    simp [add_sub_cancel_right]
    ring
  simp_rw [this]
  rw [← Finset.sum_mul]
  rfl

/-! ## Squaring the transform -/

/-- **The square of the Fourier transform is `|G|` times the reflection**: transforming twice
(the second time on the dual group, evaluated through Pontryagin's canonical embedding
`doubleDualEmb`) returns `|G| * f (-x)`. -/
theorem dft_dft (f : G → ℂ) (x : G) :
    dft (dft f) (AddChar.doubleDualEmb x) = (Fintype.card G : ℂ) * f (-x) := by
  classical
  rw [dft]
  have h1 : ∀ ψ : AddChar G ℂ, conj ((AddChar.doubleDualEmb x) ψ) * dft f ψ
      = ∑ y, conj (ψ x) * conj (ψ y) * f y := by
    intro ψ
    rw [dft, Finset.mul_sum]
    refine Finset.sum_congr rfl fun y _ => ?_
    rw [AddChar.doubleDualEmb_apply]
    ring
  simp_rw [h1]
  rw [Finset.sum_comm]
  have h2 : ∀ y : G, ∑ ψ : AddChar G ℂ, conj (ψ x) * conj (ψ y) * f y
      = (if x + y = 0 then (Fintype.card G : ℂ) else 0) * f y := by
    intro y
    rw [← Finset.sum_mul]
    congr 1
    have hc : ∀ ψ : AddChar G ℂ, conj (ψ x) * conj (ψ y) = conj (ψ (x + y)) := by
      intro ψ; rw [ψ.map_add_eq_mul, map_mul]
    simp_rw [hc]
    rw [← map_sum, AddChar.sum_apply_eq_ite]
    split_ifs <;> simp
  simp_rw [h2]
  rw [Finset.sum_eq_single (-x)]
  · simp
  · intro y _ hy
    have hne : x + y ≠ 0 := fun h => hy (by rw [← neg_eq_of_add_eq_zero_right h])
    simp [hne]
  · intro h; exact absurd (Finset.mem_univ (-x)) h

/-! ## The Donoho–Stark uncertainty principle -/

omit [DecidableEq G] in
private lemma dft_bound (f : G → ℂ) (M : ℝ) (hM : ∀ x, ‖f x‖ ≤ M) (ψ : AddChar G ℂ) :
    ‖dft f ψ‖ ≤ (supp f).card * M := by
  have h1 : dft f ψ = ∑ x ∈ supp f, conj (ψ x) * f x := by
    rw [dft]
    refine (Finset.sum_subset (Finset.subset_univ _) ?_).symm
    intro x _ hx
    have : f x = 0 := by
      by_contra h
      exact hx (mem_supp.2 h)
    simp [this]
  rw [h1]
  calc ‖∑ x ∈ supp f, conj (ψ x) * f x‖ ≤ ∑ x ∈ supp f, ‖conj (ψ x) * f x‖ :=
        norm_sum_le _ _
    _ = ∑ x ∈ supp f, ‖f x‖ := by
        refine Finset.sum_congr rfl fun x _ => ?_
        rw [norm_mul, RCLike.norm_conj, AddChar.norm_apply, one_mul]
    _ ≤ ∑ _x ∈ supp f, M := Finset.sum_le_sum fun x _ => hM x
    _ = (supp f).card * M := by rw [Finset.sum_const, nsmul_eq_mul]

/-- **Uncertainty principle** (Donoho–Stark): a nonzero function on a finite abelian group
cannot be simultaneously concentrated on a small set and have Fourier transform concentrated
on a small set: `|supp f| * |supp f̂| ≥ |G|`. -/
theorem uncertainty (f : G → ℂ) (hf : f ≠ 0) :
    (Fintype.card G : ℕ) ≤ (supp f).card * (supp (dft f)).card := by
  classical
  -- pick a maximizer of `‖f ·‖`
  obtain ⟨x₀, hx₀⟩ : ∃ x₀ : G, f x₀ ≠ 0 := by
    by_contra h
    push_neg at h
    exact hf (funext h)
  have hne : (Finset.univ : Finset G).Nonempty := ⟨x₀, Finset.mem_univ _⟩
  obtain ⟨m, -, hm⟩ := Finset.exists_max_image (Finset.univ : Finset G) (fun x => ‖f x‖) hne
  obtain ⟨M, hMdef⟩ : ∃ M : ℝ, M = ‖f m‖ := ⟨_, rfl⟩
  have hMpos : 0 < M := by
    rw [hMdef]; exact lt_of_lt_of_le (norm_pos_iff.2 hx₀) (hm x₀ (Finset.mem_univ _))
  have hMall : ∀ x, ‖f x‖ ≤ M := by
    intro x; rw [hMdef]; exact hm x (Finset.mem_univ _)
  -- bound the Fourier coefficients
  have hFbound : ∀ ψ : AddChar G ℂ, ‖dft f ψ‖ ≤ (supp f).card * M := dft_bound f M hMall
  -- bound `M` back by inversion
  have hinv : f m = (Fintype.card G : ℂ)⁻¹ * ∑ ψ : AddChar G ℂ, ψ m * dft f ψ := by
    conv_lhs => rw [← dft_inversion f]
    rfl
  have hcardpos : (0 : ℝ) < (Fintype.card G : ℝ) := by
    exact_mod_cast Fintype.card_pos (α := G)
  have hsum : ∑ ψ : AddChar G ℂ, ψ m * dft f ψ
      = ∑ ψ ∈ supp (dft f), ψ m * dft f ψ := by
    refine (Finset.sum_subset (Finset.subset_univ _) ?_).symm
    intro ψ _ hψ
    have : dft f ψ = 0 := by
      by_contra h
      exact hψ (mem_supp.2 h)
    simp [this]
  have h2 : ‖∑ ψ ∈ supp (dft f), ψ m * dft f ψ‖
      ≤ (supp (dft f)).card * ((supp f).card * M) := by
    calc ‖∑ ψ ∈ supp (dft f), ψ m * dft f ψ‖
        ≤ ∑ ψ ∈ supp (dft f), ‖ψ m * dft f ψ‖ := norm_sum_le _ _
      _ = ∑ ψ ∈ supp (dft f), ‖dft f ψ‖ := by
          refine Finset.sum_congr rfl fun ψ _ => ?_
          rw [norm_mul, AddChar.norm_apply, one_mul]
      _ ≤ ∑ _ψ ∈ supp (dft f), ((supp f).card * M) :=
          Finset.sum_le_sum fun ψ _ => hFbound ψ
      _ = (supp (dft f)).card * ((supp f).card * M) := by
          rw [Finset.sum_const, nsmul_eq_mul]
  have hM_le : M ≤ (Fintype.card G : ℝ)⁻¹ * ((supp (dft f)).card * ((supp f).card * M)) := by
    calc M = ‖f m‖ := hMdef
      _ = ‖(Fintype.card G : ℂ)⁻¹ * ∑ ψ ∈ supp (dft f), ψ m * dft f ψ‖ := by
          rw [← hsum, ← hinv]
      _ = (Fintype.card G : ℝ)⁻¹ * ‖∑ ψ ∈ supp (dft f), ψ m * dft f ψ‖ := by
          rw [norm_mul]; simp
      _ ≤ (Fintype.card G : ℝ)⁻¹ * ((supp (dft f)).card * ((supp f).card * M)) :=
          mul_le_mul_of_nonneg_left h2 (by positivity)
  -- conclude
  have key : (Fintype.card G : ℝ) ≤ (supp f).card * (supp (dft f)).card := by
    have h := mul_le_mul_of_nonneg_left hM_le (le_of_lt hcardpos)
    rw [← mul_assoc, mul_inv_cancel₀ (ne_of_gt hcardpos), one_mul] at h
    have h' : (Fintype.card G : ℝ) * M ≤ ((supp f).card * (supp (dft f)).card) * M := by
      calc (Fintype.card G : ℝ) * M ≤ (supp (dft f)).card * ((supp f).card * M) := h
        _ = ((supp f).card * (supp (dft f)).card) * M := by ring
    exact le_of_mul_le_mul_right (by linarith [h']) hMpos
  exact_mod_cast key

/-! ## Sharpness -/

/-- The Dirac delta at `a`. -/
noncomputable def delta (a : G) : G → ℂ := fun x => if x = a then 1 else 0

@[simp] lemma dft_delta (a : G) (ψ : AddChar G ℂ) : dft (delta a) ψ = conj (ψ a) := by
  rw [dft, Finset.sum_eq_single a]
  · simp [delta]
  · intro b _ hb; simp [delta, hb]
  · intro h; exact absurd (Finset.mem_univ a) h

omit [AddCommGroup G] in
lemma supp_delta (a : G) : supp (delta a) = {a} := by
  ext x
  simp [mem_supp, delta]

lemma supp_dft_delta (a : G) : supp (dft (delta a)) = (Finset.univ : Finset (AddChar G ℂ)) := by
  ext ψ
  have : conj (ψ a) ≠ 0 := by
    have : ‖ψ a‖ = 1 := AddChar.norm_apply _ _
    simp only [ne_eq, map_eq_zero]
    intro h
    rw [h] at this
    simp at this
  simp [mem_supp, this]

/-- The uncertainty bound is sharp: Dirac deltas attain equality. -/
theorem uncertainty_sharp_delta (a : G) :
    (supp (delta a)).card * (supp (dft (delta a))).card = Fintype.card G := by
  rw [supp_delta, supp_dft_delta, Finset.card_singleton, Finset.card_univ, one_mul,
    AddChar.card_eq]

end FourierFA