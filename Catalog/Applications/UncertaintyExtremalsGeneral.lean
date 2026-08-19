/-
# The complete equality case of the Donoho–Stark uncertainty principle

`Catalog.Applications.UncertaintyExtremals` classifies the extremals of
`|supp f| * |supp f̂| ≥ |G|` among *indicator* functions: they are the cosets.  This file
removes the restriction to indicators and settles the general problem:

  **`f ≠ 0` is extremal if and only if `f = c · ψ₁ · 1_{a+H}`** for a subgroup `H`, a coset
  representative `a`, a character `ψ₁` and a nonzero constant `c`.

So the extremals form exactly one orbit of the natural symmetry group of the problem
(scaling × translation × modulation) acting on subgroup indicators.

## Structure of the argument

1. `FourierFA.eq_of_norm_sum_eq_card` — the equality case of the triangle inequality in the
   form actually needed: `n` unimodular numbers with `‖∑‖ = n` are all *equal*.
2. `FourierFA.norm_eq_of_extremal` — running the Donoho–Stark chain
   `|G| M ≤ ∑_{ψ ∈ B} ‖f̂ ψ‖ ≤ |B| ‖f‖₁ ≤ |B| |A| M = |G| M` backwards shows that extremality
   forces **double flatness**: `‖f‖` is constant on `supp f` and `‖f̂‖` is constant on
   `supp f̂`.
3. `FourierFA.phase_eq_of_extremal` — double flatness plus Fourier inversion forces the
   phases `ψ ↦ ψ x * f̂ ψ` to be independent of `ψ ∈ supp f̂`, for each `x ∈ supp f`.
4. Comparing two such phase relations makes the block
   `(supp f − a) × (supp f̂ − ψ₁)` of the character table identically `1`, of area `|G|`, so
   `FourierFA.isPoissonPair_iff_rectangle` and the converse of Poisson summation turn
   `supp f − a` into a subgroup.

Nothing beyond the character table and the triangle inequality is used.

## Main results

* `FourierFA.donoho_stark_extremal_structure` — extremal ⇒ character-times-coset.
* `FourierFA.extremal_of_char_coset` — character-times-coset ⇒ extremal.
* `FourierFA.donoho_stark_equality_iff` — the classification, a biconditional.
-/

import Mathlib
import Catalog.Shared.FourierFiniteAbelian
import Catalog.Shared.FourierSubgroupDuality
import Catalog.Applications.PoissonSummationConverse
import Catalog.Applications.PoissonSummationTwisted
import Catalog.Applications.UncertaintyExtremals

open Finset Fintype ComplexConjugate

namespace FourierFA

variable {G : Type*} [AddCommGroup G] [Fintype G] [DecidableEq G]

/-! ## The equality case of the triangle inequality, sharpened -/

/-- If `n` unimodular complex numbers have `‖∑ z i‖ = n`, then they are all equal. -/
lemma eq_of_norm_sum_eq_card {ι : Type*} {s : Finset ι} {z : ι → ℂ}
    (hnorm : ∀ i ∈ s, ‖z i‖ = 1) (hsum : ‖∑ i ∈ s, z i‖ = (s.card : ℝ)) :
    ∀ i ∈ s, ∀ j ∈ s, z i = z j := by
  rcases Finset.eq_empty_or_nonempty s with rfl | hs
  · simp
  have hcard : (0 : ℝ) < (s.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hs
  have hcardC : ((s.card : ℂ)) ≠ 0 := Nat.cast_ne_zero.2 (Finset.card_pos.2 hs).ne'
  set S : ℂ := ∑ i ∈ s, z i with hSdef
  have hSnorm : ‖S‖ = (s.card : ℝ) := hsum
  have hu : conj S * S = ((s.card : ℂ)) * ((s.card : ℂ)) := by
    rw [Complex.conj_mul', hSnorm]
    push_cast
    ring
  set u : ℂ := conj S / (s.card : ℂ) with hudef
  have husum : ∑ i ∈ s, u * z i = (s.card : ℂ) := by
    rw [← Finset.mul_sum, ← hSdef, hudef, div_mul_eq_mul_div, hu]
    field_simp
  have hSne : S ≠ 0 := by
    intro hc
    rw [hc] at hSnorm
    simp only [norm_zero] at hSnorm
    linarith
  have hune : u ≠ 0 := div_ne_zero (by simpa using hSne) hcardC
  have hunorm : ∀ i ∈ s, ‖u * z i‖ = 1 := by
    intro i hi
    rw [norm_mul, hnorm i hi, mul_one, hudef, norm_div, RCLike.norm_conj, hSnorm,
      Complex.norm_natCast]
    field_simp
  have hall := eq_one_of_sum_eq_card hunorm husum
  intro i hi j hj
  exact mul_left_cancel₀ hune ((hall i hi).trans (hall j hj).symm)

/-! ## Two elementary facts about supports -/

variable {f : G → ℂ}

/-- Fourier inversion, with the sum restricted to the support of the transform. -/
lemma inversion_over_supp (f : G → ℂ) (x : G) :
    (Fintype.card G : ℂ) * f x = ∑ ψ ∈ supp (dft f), ψ x * dft f ψ := by
  have hcard : (Fintype.card G : ℂ) ≠ 0 := by
    exact_mod_cast (Fintype.card_ne_zero (α := G))
  have hfull : (Fintype.card G : ℂ) * f x = ∑ ψ : AddChar G ℂ, ψ x * dft f ψ := by
    conv_lhs => rw [← dft_inversion f]
    rw [idft, ← mul_assoc, mul_inv_cancel₀ hcard, one_mul]
  rw [hfull]
  refine (Finset.sum_subset (Finset.subset_univ _) ?_).symm
  intro ψ _ hψ
  have : dft f ψ = 0 := by
    by_contra hc
    exact hψ (mem_supp.2 hc)
  rw [this, mul_zero]

omit [DecidableEq G] in
/-- The Fourier transform is bounded by the `ℓ¹` norm of `f` over its support. -/
lemma norm_dft_le_l1 (f : G → ℂ) (ψ : AddChar G ℂ) :
    ‖dft f ψ‖ ≤ ∑ x ∈ supp f, ‖f x‖ := by
  have h1 : dft f ψ = ∑ x ∈ supp f, conj (ψ x) * f x := by
    rw [dft]
    refine (Finset.sum_subset (Finset.subset_univ _) ?_).symm
    intro x _ hx
    have : f x = 0 := by
      by_contra hc
      exact hx (mem_supp.2 hc)
    rw [this, mul_zero]
  rw [h1]
  calc ‖∑ x ∈ supp f, conj (ψ x) * f x‖ ≤ ∑ x ∈ supp f, ‖conj (ψ x) * f x‖ :=
        norm_sum_le _ _
    _ = ∑ x ∈ supp f, ‖f x‖ := by
        refine Finset.sum_congr rfl fun x _ => ?_
        rw [norm_mul, RCLike.norm_conj, AddChar.norm_apply, one_mul]

omit [DecidableEq G] in
omit [AddCommGroup G] in
lemma supp_nonempty_of_ne_zero (hf : f ≠ 0) : (supp f).Nonempty := by
  by_contra h
  rw [Finset.not_nonempty_iff_eq_empty] at h
  refine hf (funext fun x => ?_)
  by_contra hx
  have : x ∈ supp f := mem_supp.2 hx
  rw [h] at this
  exact absurd this (Finset.notMem_empty x)

lemma supp_dft_nonempty_of_ne_zero (hf : f ≠ 0) : (supp (dft f)).Nonempty :=
  supp_nonempty_of_ne_zero (fun h => hf (dft_injective (by rw [h, dft_zero])))

/-! ## Double flatness -/

/-- **Double flatness.**  An extremal function has constant modulus on its support, and so
does its Fourier transform. -/
theorem norm_eq_of_extremal (hf : f ≠ 0)
    (hext : (supp f).card * (supp (dft f)).card = Fintype.card G) :
    ∃ M : ℝ, 0 < M ∧ (∀ x ∈ supp f, ‖f x‖ = M) ∧
      (∀ ψ ∈ supp (dft f), ‖dft f ψ‖ = ((supp f).card : ℝ) * M) := by
  classical
  obtain ⟨x₀, hx₀⟩ := supp_nonempty_of_ne_zero hf
  have hx₀' : f x₀ ≠ 0 := mem_supp.1 hx₀
  have hBne := supp_dft_nonempty_of_ne_zero hf
  obtain ⟨m, -, hm⟩ :=
    Finset.exists_max_image (Finset.univ : Finset G) (fun x => ‖f x‖) ⟨x₀, Finset.mem_univ _⟩
  set M : ℝ := ‖f m‖ with hMdef
  have hMle : ∀ x : G, ‖f x‖ ≤ M := fun x => hm x (Finset.mem_univ _)
  have hMpos : 0 < M := lt_of_lt_of_le (norm_pos_iff.2 hx₀') (hMle x₀)
  set L : ℝ := ∑ x ∈ supp f, ‖f x‖ with hLdef
  have hApos : (0 : ℝ) < ((supp f).card : ℝ) := by
    exact_mod_cast Finset.card_pos.2 (supp_nonempty_of_ne_zero hf)
  have hBpos : (0 : ℝ) < ((supp (dft f)).card : ℝ) := by
    exact_mod_cast Finset.card_pos.2 hBne
  have hcards : ((supp f).card : ℝ) * ((supp (dft f)).card : ℝ) = (Fintype.card G : ℝ) := by
    exact_mod_cast congrArg (Nat.cast : ℕ → ℝ) hext
  -- the Donoho–Stark chain
  have hL_le : L ≤ ((supp f).card : ℝ) * M := by
    calc L ≤ ∑ _x ∈ supp f, M := Finset.sum_le_sum fun x _ => hMle x
      _ = ((supp f).card : ℝ) * M := by rw [Finset.sum_const, nsmul_eq_mul]
  have hsum_le : ∑ ψ ∈ supp (dft f), ‖dft f ψ‖ ≤ ((supp (dft f)).card : ℝ) * L := by
    calc ∑ ψ ∈ supp (dft f), ‖dft f ψ‖ ≤ ∑ _ψ ∈ supp (dft f), L :=
          Finset.sum_le_sum fun ψ _ => norm_dft_le_l1 f ψ
      _ = ((supp (dft f)).card : ℝ) * L := by rw [Finset.sum_const, nsmul_eq_mul]
  have hinv : (Fintype.card G : ℝ) * M ≤ ∑ ψ ∈ supp (dft f), ‖dft f ψ‖ := by
    have h1 := inversion_over_supp f m
    have h2 : (Fintype.card G : ℝ) * M = ‖∑ ψ ∈ supp (dft f), ψ m * dft f ψ‖ := by
      rw [← h1, norm_mul, Complex.norm_natCast, hMdef]
    rw [h2]
    calc ‖∑ ψ ∈ supp (dft f), ψ m * dft f ψ‖
        ≤ ∑ ψ ∈ supp (dft f), ‖ψ m * dft f ψ‖ := norm_sum_le _ _
      _ = ∑ ψ ∈ supp (dft f), ‖dft f ψ‖ := by
          refine Finset.sum_congr rfl fun ψ _ => ?_
          rw [norm_mul, AddChar.norm_apply, one_mul]
  -- no slack anywhere
  have hLeq : L = ((supp f).card : ℝ) * M := by
    have h1 : ((supp (dft f)).card : ℝ) * (((supp f).card : ℝ) * M)
        ≤ ((supp (dft f)).card : ℝ) * L := by nlinarith
    have h2 : ((supp f).card : ℝ) * M ≤ L := le_of_mul_le_mul_left h1 hBpos
    linarith
  have hsumeq : ∑ ψ ∈ supp (dft f), ‖dft f ψ‖ = ((supp (dft f)).card : ℝ) * L := by
    nlinarith
  refine ⟨M, hMpos, ?_, ?_⟩
  · exact eq_of_sum_eq_card_mul (fun x _ => hMle x) (by rw [← hLdef, hLeq])
  · intro ψ hψ
    have h := eq_of_sum_eq_card_mul (fun ψ' _ => norm_dft_le_l1 f ψ') hsumeq ψ hψ
    rw [h, ← hLdef, hLeq]

/-! ## Constancy of the phase -/

/-- **Phase rigidity.**  For an extremal `f` and any `x` in its support, the products
`ψ x * f̂ ψ` do not depend on `ψ ∈ supp f̂`. -/
theorem phase_eq_of_extremal (hf : f ≠ 0)
    (hext : (supp f).card * (supp (dft f)).card = Fintype.card G)
    {x : G} (hx : x ∈ supp f) :
    ∀ ψ ∈ supp (dft f), ∀ χ ∈ supp (dft f), ψ x * dft f ψ = χ x * dft f χ := by
  classical
  obtain ⟨M, hMpos, hflatf, hflatF⟩ := norm_eq_of_extremal hf hext
  have hApos : (0 : ℝ) < ((supp f).card : ℝ) := by
    exact_mod_cast Finset.card_pos.2 (supp_nonempty_of_ne_zero hf)
  have hcards : ((supp f).card : ℝ) * ((supp (dft f)).card : ℝ) = (Fintype.card G : ℝ) := by
    exact_mod_cast congrArg (Nat.cast : ℕ → ℝ) hext
  set k : ℝ := ((supp f).card : ℝ) * M with hkdef
  have hkpos : 0 < k := mul_pos hApos hMpos
  set z : AddChar G ℂ → ℂ := fun ψ => ((k : ℂ))⁻¹ * (ψ x * dft f ψ) with hzdef
  have hznorm : ∀ ψ ∈ supp (dft f), ‖z ψ‖ = 1 := by
    intro ψ hψ
    rw [hzdef]
    simp only [norm_mul, norm_inv, AddChar.norm_apply, one_mul, Complex.norm_real,
      Real.norm_eq_abs, abs_of_pos hkpos, hflatF ψ hψ]
    field_simp
  have hzsum : ‖∑ ψ ∈ supp (dft f), z ψ‖ = ((supp (dft f)).card : ℝ) := by
    have h1 : ∑ ψ ∈ supp (dft f), z ψ
        = ((k : ℂ))⁻¹ * ((Fintype.card G : ℂ) * f x) := by
      rw [inversion_over_supp f x, Finset.mul_sum]
    rw [h1, norm_mul, norm_inv, Complex.norm_real, Real.norm_eq_abs, abs_of_pos hkpos,
      norm_mul, Complex.norm_natCast, hflatf x hx, hkdef]
    field_simp
    exact hcards.symm
  have hall := eq_of_norm_sum_eq_card hznorm hzsum
  intro ψ hψ χ hχ
  have h := hall ψ hψ χ hχ
  rw [hzdef] at h
  simp only at h
  have hk : ((k : ℂ))⁻¹ ≠ 0 := by
    simp only [ne_eq, inv_eq_zero, Complex.ofReal_eq_zero]
    exact hkpos.ne'
  exact mul_left_cancel₀ hk h

/-! ## The structure theorem -/

/-- **Extremal ⇒ modulated coset indicator.**  Every nonzero function attaining equality in
the Donoho–Stark uncertainty principle is a constant multiple of a character restricted to a
coset. -/
theorem donoho_stark_extremal_structure (hf : f ≠ 0)
    (hext : (supp f).card * (supp (dft f)).card = Fintype.card G) :
    ∃ (H : AddSubgroup G) (a : G) (ψ₁ : AddChar G ℂ) (c : ℂ), c ≠ 0 ∧
      ∀ x : G, (x - a ∈ H → f x = c * ψ₁ x) ∧ (x - a ∉ H → f x = 0) := by
  classical
  obtain ⟨a, ha⟩ := supp_nonempty_of_ne_zero hf
  obtain ⟨ψ₁, hψ₁⟩ := supp_dft_nonempty_of_ne_zero hf
  have hD₁ : dft f ψ₁ ≠ 0 := mem_supp.1 hψ₁
  have hApos : 0 < (supp f).card := Finset.card_pos.2 (supp_nonempty_of_ne_zero hf)
  set S₀ : Finset G := (supp f).image (· - a) with hS₀def
  set T₀ : Finset (AddChar G ℂ) := (supp (dft f)).image (· - ψ₁) with hT₀def
  have hinjG : Set.InjOn (· - a) (supp f) := fun p _ q _ hpq => by
    simpa using sub_left_inj.1 hpq
  have hinjD : Set.InjOn (· - ψ₁) (supp (dft f)) := fun p _ q _ hpq => by
    simpa using sub_left_inj.1 hpq
  have hS₀card : S₀.card = (supp f).card := Finset.card_image_of_injOn hinjG
  have hT₀card : T₀.card = (supp (dft f)).card := Finset.card_image_of_injOn hinjD
  have hS₀ne : S₀.Nonempty := ⟨a - a, Finset.mem_image_of_mem _ ha⟩
  -- the all-ones rectangle
  have hones : ∀ y ∈ S₀, ∀ θ ∈ T₀, θ y = 1 := by
    intro y hy θ hθ
    obtain ⟨x, hx, rfl⟩ := Finset.mem_image.1 hy
    obtain ⟨ψ, hψ, rfl⟩ := Finset.mem_image.1 hθ
    have hDψ : dft f ψ ≠ 0 := mem_supp.1 hψ
    have h1 : ψ x * dft f ψ = ψ₁ x * dft f ψ₁ :=
      phase_eq_of_extremal hf hext hx ψ hψ ψ₁ hψ₁
    have h2 : ψ a * dft f ψ = ψ₁ a * dft f ψ₁ :=
      phase_eq_of_extremal hf hext ha ψ hψ ψ₁ hψ₁
    -- cross-multiplying kills the transform values
    have h3 : ψ₁ x * ψ a = ψ₁ a * ψ x := by
      have e1 : (ψ x * dft f ψ) * ψ a = (ψ₁ x * dft f ψ₁) * ψ a := by rw [h1]
      have e2 : (ψ a * dft f ψ) * ψ x = (ψ₁ a * dft f ψ₁) * ψ x := by rw [h2]
      have e3 : (ψ₁ x * dft f ψ₁) * ψ a = (ψ₁ a * dft f ψ₁) * ψ x := by
        rw [← e1, ← e2]; ring
      have e4 : dft f ψ₁ * (ψ₁ x * ψ a) = dft f ψ₁ * (ψ₁ a * ψ x) := by
        linear_combination e3
      exact mul_left_cancel₀ hD₁ e4
    -- turn the relation into the value of the character `ψ - ψ₁` at `x - a`
    have hpa : ψ (x - a) * ψ a = ψ x := by
      rw [← ψ.map_add_eq_mul, sub_add_cancel]
    have hp₁a : ψ₁ (x - a) * ψ₁ a = ψ₁ x := by
      rw [← ψ₁.map_add_eq_mul, sub_add_cancel]
    have hψa : ψ a ≠ 0 := by
      intro hc
      have : ‖ψ a‖ = 1 := AddChar.norm_apply _ _
      rw [hc] at this; simp at this
    have hψ₁a : ψ₁ a ≠ 0 := by
      intro hc
      have : ‖ψ₁ a‖ = 1 := AddChar.norm_apply _ _
      rw [hc] at this; simp at this
    have hψ₁xa : ψ₁ (x - a) ≠ 0 := by
      intro hc
      have : ‖ψ₁ (x - a)‖ = 1 := AddChar.norm_apply _ _
      rw [hc] at this; simp at this
    have heq : ψ (x - a) = ψ₁ (x - a) := by
      have e5 : (ψ₁ a * ψ a) * ψ (x - a) = (ψ₁ a * ψ a) * ψ₁ (x - a) := by
        calc (ψ₁ a * ψ a) * ψ (x - a) = ψ₁ a * (ψ (x - a) * ψ a) := by ring
          _ = ψ₁ a * ψ x := by rw [hpa]
          _ = ψ₁ x * ψ a := by rw [← h3]
          _ = (ψ₁ (x - a) * ψ₁ a) * ψ a := by rw [hp₁a]
          _ = (ψ₁ a * ψ a) * ψ₁ (x - a) := by ring
      exact mul_left_cancel₀ (mul_ne_zero hψ₁a hψa) e5
    rw [AddChar.sub_apply' ψ ψ₁ (x - a), heq, div_self hψ₁xa]
  have hareas : S₀.card * T₀.card = Fintype.card G := by
    rw [hS₀card, hT₀card]; exact hext
  have hpp : IsPoissonPair S₀ T₀ := (isPoissonPair_iff_rectangle hS₀ne).2 ⟨hones, hareas⟩
  obtain ⟨H, hH, -⟩ := isPoissonPair_converse hpp hS₀ne
  -- read off the shape of `f`
  refine ⟨H, a, ψ₁, dft f ψ₁ / ((supp f).card : ℂ), ?_, ?_⟩
  · refine div_ne_zero hD₁ ?_
    exact Nat.cast_ne_zero.2 hApos.ne'
  · intro x
    have hmemS₀ : x - a ∈ S₀ ↔ x ∈ supp f := by
      rw [hS₀def]
      simp only [Finset.mem_image]
      constructor
      · rintro ⟨y, hy, hxy⟩
        have : y = x := sub_left_injective hxy
        exact this ▸ hy
      · intro hx
        exact ⟨x, hx, rfl⟩
    constructor
    · intro hxH
      have hx : x ∈ supp f := hmemS₀.1 ((hH (x - a)).2 hxH)
      have hall : ∀ ψ ∈ supp (dft f), ψ x * dft f ψ = ψ₁ x * dft f ψ₁ := fun ψ hψ =>
        phase_eq_of_extremal hf hext hx ψ hψ ψ₁ hψ₁
      have hsum : (Fintype.card G : ℂ) * f x
          = ((supp (dft f)).card : ℂ) * (ψ₁ x * dft f ψ₁) := by
        rw [inversion_over_supp f x, Finset.sum_congr rfl hall, Finset.sum_const,
          nsmul_eq_mul]
      have hcardC : ((supp f).card : ℂ) * ((supp (dft f)).card : ℂ)
          = (Fintype.card G : ℂ) := by
        exact_mod_cast congrArg (Nat.cast : ℕ → ℂ) hext
      have hAne : ((supp f).card : ℂ) ≠ 0 := Nat.cast_ne_zero.2 hApos.ne'
      have hGne : (Fintype.card G : ℂ) ≠ 0 := by
        exact_mod_cast (Fintype.card_ne_zero (α := G))
      have key : f x * ((supp f).card : ℂ) = ψ₁ x * dft f ψ₁ := by
        refine mul_left_cancel₀ hGne ?_
        calc (Fintype.card G : ℂ) * (f x * ((supp f).card : ℂ))
            = ((Fintype.card G : ℂ) * f x) * ((supp f).card : ℂ) := by ring
          _ = (((supp (dft f)).card : ℂ) * (ψ₁ x * dft f ψ₁)) * ((supp f).card : ℂ) := by
              rw [hsum]
          _ = (((supp f).card : ℂ) * ((supp (dft f)).card : ℂ)) * (ψ₁ x * dft f ψ₁) := by
              ring
          _ = (Fintype.card G : ℂ) * (ψ₁ x * dft f ψ₁) := by rw [hcardC]
      field_simp
      linear_combination key
    · intro hxH
      have hx : x ∉ supp f := fun hc => hxH ((hH (x - a)).1 (hmemS₀.2 hc))
      by_contra hne
      exact hx (mem_supp.2 hne)

/-! ## The converse -/

/-- **Modulated coset indicator ⇒ extremal.** -/
theorem extremal_of_char_coset (H : AddSubgroup G) [DecidablePred (· ∈ H)] (a : G)
    (ψ₁ : AddChar G ℂ) {c : ℂ} (hc : c ≠ 0) :
    (supp (fun x => if x - a ∈ H then c * ψ₁ x else 0)).card
        * (supp (dft (fun x => if x - a ∈ H then c * ψ₁ x else 0))).card
      = Fintype.card G := by
  classical
  set S : Finset G := (subFinset H).image (· + a) with hSdef
  set g : G → ℂ := fun x => if x - a ∈ H then c * ψ₁ x else 0 with hgdef
  have hmemS : ∀ x : G, x ∈ S ↔ x - a ∈ H := fun x => mem_image_add_subFinset a x
  have hψne : ∀ x : G, ψ₁ x ≠ 0 := by
    intro x hcx
    have : ‖ψ₁ x‖ = 1 := AddChar.norm_apply _ _
    rw [hcx] at this; simp at this
  have hsuppg : supp g = S := by
    ext x
    rw [mem_supp, hgdef, hmemS x]
    by_cases hx : x - a ∈ H
    · simp only [if_pos hx, ne_eq, mul_eq_zero, not_or]
      exact ⟨fun _ => hx, fun _ => ⟨hc, hψne x⟩⟩
    · simp [hx]
  -- rewrite `g` as `c • (ψ₁ · 1_S)`
  have hg_eq : ∀ x : G, g x = c * (ψ₁ x * finIndic S x) := by
    intro x
    simp only [hgdef]
    by_cases hx : x - a ∈ H
    · rw [if_pos hx, finIndic_apply_of_mem ((hmemS x).2 hx)]
      ring
    · rw [if_neg hx, finIndic_apply_of_not_mem (fun hcon => hx ((hmemS x).1 hcon))]
      ring
  have hdftg : ∀ χ : AddChar G ℂ, dft g χ = c * dft (finIndic S) (χ - ψ₁) := by
    intro χ
    have h1 : dft g χ = c * dft (fun x => ψ₁ x * finIndic S x) χ := by
      rw [dft, dft, Finset.mul_sum]
      refine Finset.sum_congr rfl fun x _ => ?_
      rw [hg_eq x]
      ring
    rw [h1, dft_char_mul (finIndic S) ψ₁ χ]
  have hsuppdft : supp (dft g) = (supp (dft (finIndic S))).image (· + ψ₁) := by
    ext χ
    rw [mem_supp, hdftg χ]
    simp only [Finset.mem_image]
    constructor
    · intro hne
      refine ⟨χ - ψ₁, mem_supp.2 ?_, by simp⟩
      intro hcon
      exact hne (by rw [hcon, mul_zero])
    · rintro ⟨θ, hθ, rfl⟩
      have : θ + ψ₁ - ψ₁ = θ := by simp
      rw [this]
      exact mul_ne_zero hc (mem_supp.1 hθ)
  have hcardimg : ((supp (dft (finIndic S))).image (· + ψ₁)).card
      = (supp (dft (finIndic S))).card := by
    refine Finset.card_image_of_injOn fun p _ q _ hpq => ?_
    exact add_left_injective ψ₁ hpq
  rw [hsuppg, hsuppdft, hcardimg]
  exact extremal_of_coset H a

/-- **The equality case of the Donoho–Stark uncertainty principle.**  A nonzero `f` satisfies
`|supp f| * |supp f̂| = |G|` if and only if it is a nonzero multiple of a character restricted
to a coset. -/
theorem donoho_stark_equality_iff (hf : f ≠ 0) :
    (supp f).card * (supp (dft f)).card = Fintype.card G
      ↔ ∃ (H : AddSubgroup G) (a : G) (ψ₁ : AddChar G ℂ) (c : ℂ), c ≠ 0 ∧
          ∀ x : G, (x - a ∈ H → f x = c * ψ₁ x) ∧ (x - a ∉ H → f x = 0) := by
  classical
  constructor
  · intro hext
    exact donoho_stark_extremal_structure hf hext
  · rintro ⟨H, a, ψ₁, c, hc, hform⟩
    have hfeq : f = fun x => if x - a ∈ H then c * ψ₁ x else 0 := by
      funext x
      by_cases hx : x - a ∈ H
      · rw [if_pos hx]
        exact (hform x).1 hx
      · rw [if_neg hx]
        exact (hform x).2 hx
    rw [hfeq]
    exact extremal_of_char_coset H a ψ₁ hc

end FourierFA