/-
# The equality case of the Donoho–Stark uncertainty principle for indicator functions

`Catalog.Shared.FourierFiniteAbelian` proves the Donoho–Stark uncertainty principle
`|supp f| * |supp f̂| ≥ |G|` and exhibits two families of extremals (Dirac deltas, and —
in `Catalog.Shared.FourierSubgroupDuality` — subgroup indicators).  This file settles the
*classification* problem for indicator functions:

  **an indicator `1_S` is extremal if and only if `S` is a coset of a subgroup.**

The proof is a striking application of the converse of Poisson summation.  Extremality
`|S| * |supp (1_S)^| = |G|` forces, by Parseval and a counting argument, the Fourier transform
of `1_S` to have *constant modulus* `|S|` on its support `T`.  The Parseval representation
`|G| * ∑_{x ∈ S} f x = ∑_ψ conj((1_S)^ ψ) * f̂ ψ` then exhibits `(S, T)` as a **twisted Poisson
pair with unimodular weights**, and `FourierFA.twistedPoisson_converse` forces `S` to be a
coset.  No structure theory of finite abelian groups is used anywhere.

## Main results

* `FourierFA.norm_dft_finIndic_le` — the elementary bound `‖(1_S)^ ψ‖ ≤ |S|`.
* `FourierFA.norm_dft_finIndic_eq_of_extremal` — **flatness on the support**: extremality
  forces `‖(1_S)^ ψ‖ = |S|` for every `ψ` in the support of `(1_S)^`.
* `FourierFA.isTwistedPoissonPair_supp` — every nonempty finset is a twisted Poisson set for
  the support of its transform; extremality is exactly what makes the weights unimodular.
* `FourierFA.coset_of_extremal` — extremal ⇒ coset.
* `FourierFA.extremal_of_coset` — coset ⇒ extremal.
* `FourierFA.donoho_stark_equality_iff_coset` — **the classification**, a biconditional.
-/

import Mathlib
import Catalog.Shared.FourierFiniteAbelian
import Catalog.Shared.FourierSubgroupDuality
import Catalog.Applications.PoissonSummationConverse
import Catalog.Applications.PoissonSummationTwisted

open Finset Fintype ComplexConjugate

namespace FourierFA

variable {G : Type*} [AddCommGroup G] [Fintype G] [DecidableEq G]

/-! ## A real-analytic equality lemma -/

/-- If every term of a finite sum is at most `c` and the sum equals `|s| * c`, then every term
equals `c`. -/
lemma eq_of_sum_eq_card_mul {ι : Type*} {s : Finset ι} {g : ι → ℝ} {c : ℝ}
    (hle : ∀ i ∈ s, g i ≤ c) (hsum : ∑ i ∈ s, g i = s.card * c) :
    ∀ i ∈ s, g i = c := by
  intro i hi
  by_contra hne
  have hlt : g i < c := lt_of_le_of_ne (hle i hi) hne
  have := Finset.sum_lt_sum hle ⟨i, hi, hlt⟩
  rw [hsum, Finset.sum_const, nsmul_eq_mul] at this
  exact lt_irrefl _ this

/-! ## Flatness of the transform of an extremal indicator -/

variable {S : Finset G}

/-- The Fourier transform of an indicator is bounded by the size of the set. -/
theorem norm_dft_finIndic_le (S : Finset G) (ψ : AddChar G ℂ) :
    ‖dft (finIndic S) ψ‖ ≤ (S.card : ℝ) := by
  have h1 : dft (finIndic S) ψ = ∑ x ∈ S, conj (ψ x) := by
    rw [dft]
    rw [← Finset.sum_subset (Finset.subset_univ S) ?_]
    · exact Finset.sum_congr rfl fun x hx => by rw [finIndic_apply_of_mem hx, mul_one]
    · intro x _ hx
      rw [finIndic_apply_of_not_mem hx, mul_zero]
  rw [h1]
  calc ‖∑ x ∈ S, conj (ψ x)‖ ≤ ∑ x ∈ S, ‖conj (ψ x)‖ := norm_sum_le _ _
    _ = (S.card : ℝ) := by
        rw [Finset.sum_congr rfl (fun x _ => by
          rw [RCLike.norm_conj, AddChar.norm_apply] : ∀ x ∈ S, ‖conj (ψ x)‖ = (1 : ℝ))]
        simp

/-- **Flatness on the support.**  If the indicator `1_S` is extremal for the uncertainty
principle, then its Fourier transform has constant modulus `|S|` on its support. -/
theorem norm_dft_finIndic_eq_of_extremal (hS : S.Nonempty)
    (hext : S.card * (supp (dft (finIndic S))).card = Fintype.card G)
    (ψ : AddChar G ℂ) (hψ : ψ ∈ supp (dft (finIndic S))) :
    ‖dft (finIndic S) ψ‖ = (S.card : ℝ) := by
  set T := supp (dft (finIndic S)) with hT
  have hcardS : (0 : ℝ) < (S.card : ℝ) := by
    exact_mod_cast Finset.card_pos.2 hS
  -- Parseval
  have hpar := parseval_norm (finIndic S)
  have hR : ∑ x : G, ‖finIndic S x‖ ^ 2 = (S.card : ℝ) := by
    have hx : ∀ x : G, ‖finIndic S x‖ ^ 2 = if x ∈ S then (1 : ℝ) else 0 := by
      intro x
      by_cases hx : x ∈ S <;> simp [finIndic, hx]
    simp_rw [hx]
    rw [Finset.sum_ite_mem, Finset.univ_inter, Finset.sum_const, nsmul_eq_mul, mul_one]
  have hL : ∑ ψ : AddChar G ℂ, ‖dft (finIndic S) ψ‖ ^ 2
      = ∑ ψ ∈ T, ‖dft (finIndic S) ψ‖ ^ 2 := by
    refine (Finset.sum_subset (Finset.subset_univ _) ?_).symm
    intro ψ _ hψ'
    have : dft (finIndic S) ψ = 0 := by
      by_contra hc
      exact hψ' (mem_supp.2 hc)
    rw [this]
    simp
  rw [hL, hR] at hpar
  -- the total mass is exactly `|T| * |S|²`
  have hsum : ∑ ψ ∈ T, ‖dft (finIndic S) ψ‖ ^ 2 = (T.card : ℝ) * (S.card : ℝ) ^ 2 := by
    rw [hpar]
    have : ((Fintype.card G : ℕ) : ℝ) = (S.card : ℝ) * (T.card : ℝ) := by
      exact_mod_cast congrArg (Nat.cast : ℕ → ℝ) hext.symm
    rw [this]
    ring
  have hle : ∀ ψ' ∈ T, ‖dft (finIndic S) ψ'‖ ^ 2 ≤ (S.card : ℝ) ^ 2 := by
    intro ψ' _
    have h1 := norm_dft_finIndic_le S ψ'
    have h2 : (0 : ℝ) ≤ ‖dft (finIndic S) ψ'‖ := norm_nonneg _
    nlinarith
  have hflat := eq_of_sum_eq_card_mul hle hsum ψ hψ
  -- extract the modulus from its square
  have h2 : (0 : ℝ) ≤ ‖dft (finIndic S) ψ‖ := norm_nonneg _
  have hfac : (‖dft (finIndic S) ψ‖ - (S.card : ℝ)) * (‖dft (finIndic S) ψ‖ + (S.card : ℝ))
      = 0 := by nlinarith
  rcases mul_eq_zero.1 hfac with h | h
  · linarith
  · linarith

/-! ## Extremal indicators are twisted Poisson pairs -/

/-- Every nonempty finset is a twisted Poisson set paired with the support of the transform
of its indicator; the weights are the normalised Fourier coefficients.  (Extremality is what
will later make these weights unimodular.) -/
theorem isTwistedPoissonPair_supp (hS : S.Nonempty) :
    IsTwistedPoissonPair S (supp (dft (finIndic S)))
      (fun ψ => (S.card : ℂ)⁻¹ * conj (dft (finIndic S) ψ)) := by
  intro f
  have hScard : (S.card : ℂ) ≠ 0 :=
    Nat.cast_ne_zero.2 (Finset.card_pos.2 hS).ne'
  rw [poisson_repr S f]
  have hrestrict : ∑ ψ : AddChar G ℂ, conj (dft (finIndic S) ψ) * dft f ψ
      = ∑ ψ ∈ supp (dft (finIndic S)), conj (dft (finIndic S) ψ) * dft f ψ := by
    refine (Finset.sum_subset (Finset.subset_univ _) ?_).symm
    intro ψ _ hψ
    have : dft (finIndic S) ψ = 0 := by
      by_contra hc
      exact hψ (mem_supp.2 hc)
    rw [this, map_zero, zero_mul]
  rw [hrestrict, Finset.mul_sum]
  refine Finset.sum_congr rfl fun ψ _ => ?_
  field_simp

/-! ## The classification -/

/-- **Extremal ⇒ coset.**  If `1_S` attains equality in the Donoho–Stark uncertainty
principle, then `S` is a coset of a subgroup of `G`. -/
theorem coset_of_extremal (hS : S.Nonempty)
    (hext : S.card * (supp (dft (finIndic S))).card = Fintype.card G) :
    ∃ (H : AddSubgroup G) (a : G), a ∈ S ∧ ∀ x : G, x ∈ S ↔ x - a ∈ H := by
  have hpair := isTwistedPoissonPair_supp hS
  have hScard : (0 : ℝ) < (S.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hS
  have hw : ∀ ψ ∈ supp (dft (finIndic S)),
      ‖(S.card : ℂ)⁻¹ * conj (dft (finIndic S) ψ)‖ = 1 := by
    intro ψ hψ
    rw [norm_mul, RCLike.norm_conj, norm_inv, Complex.norm_natCast,
      norm_dft_finIndic_eq_of_extremal hS hext ψ hψ]
    field_simp
  obtain ⟨H, a, ha, hmem, -, -⟩ := twistedPoisson_converse hpair hS hw
  exact ⟨H, a, ha, hmem⟩

/-- The Fourier transform of the indicator of a coset is a phase times the transform of the
indicator of the underlying subgroup. -/
theorem dft_finIndic_coset (H : AddSubgroup G) [DecidablePred (· ∈ H)] (a : G)
    (ψ : AddChar G ℂ) :
    ψ a * dft (finIndic ((subFinset H).image (· + a))) ψ = dft (indic H) ψ := by
  rw [← dft_comp_add]
  refine congrArg (fun g => dft g ψ) (funext fun x => ?_)
  by_cases hx : x ∈ H
  · rw [finIndic_apply_of_mem (mem_image_add_subFinset a (x + a) |>.2 (by simpa using hx))]
    simp [indic, hx]
  · have hnot : x + a ∉ (subFinset H).image (· + a) := by
      intro hc
      exact hx (by simpa using (mem_image_add_subFinset a (x + a)).1 hc)
    rw [finIndic_apply_of_not_mem hnot]
    simp [indic, hx]

/-- **Coset ⇒ extremal.**  The indicator of any coset of any subgroup attains equality in the
Donoho–Stark uncertainty principle.  This strictly extends the two extremal families in the
catalog (Dirac deltas `a + ⊥`, and subgroups `0 + H`). -/
theorem extremal_of_coset (H : AddSubgroup G) [DecidablePred (· ∈ H)] (a : G) :
    ((subFinset H).image (· + a)).card
        * (supp (dft (finIndic ((subFinset H).image (· + a))))).card
      = Fintype.card G := by
  classical
  set S := (subFinset H).image (· + a) with hSdef
  have hinj : Set.InjOn (· + a) (subFinset H) := fun x _ y _ hxy => by
    simpa using add_right_cancel hxy
  have hcard : S.card = (subFinset H).card := Finset.card_image_of_injOn hinj
  have hsupp : supp (dft (finIndic S)) = annih H := by
    rw [← supp_dft_indic (H := H)]
    ext ψ
    have hkey := dft_finIndic_coset H a ψ
    have hne : ψ a ≠ 0 := by
      intro hc
      have : ‖ψ a‖ = 1 := AddChar.norm_apply _ _
      rw [hc] at this
      simp at this
    have hmul : (ψ a * dft (finIndic S) ψ ≠ 0) ↔ (dft (finIndic S) ψ ≠ 0) := by
      constructor
      · intro h hz
        exact h (by rw [hz, mul_zero])
      · intro h hz
        rcases mul_eq_zero.1 hz with h1 | h2
        · exact hne h1
        · exact h h2
    rw [mem_supp, mem_supp, ← hkey]
    exact hmul.symm
  rw [hcard, hsupp]
  exact card_subgroup_mul_card_annihilator

/-- **Classification of the extremals of the Donoho–Stark uncertainty principle among
indicator functions**: `|supp 1_S| * |supp (1_S)^| = |G|` holds exactly when `S` is a coset. -/
theorem donoho_stark_equality_iff_coset (hS : S.Nonempty) :
    (supp (finIndic S)).card * (supp (dft (finIndic S))).card = Fintype.card G
      ↔ ∃ (H : AddSubgroup G) (a : G), ∀ x : G, x ∈ S ↔ x - a ∈ H := by
  classical
  rw [supp_finIndic]
  constructor
  · intro hext
    obtain ⟨H, a, -, hmem⟩ := coset_of_extremal hS hext
    exact ⟨H, a, hmem⟩
  · rintro ⟨H, a, hmem⟩
    have hSeq : S = (subFinset H).image (· + a) := by
      ext x
      rw [mem_image_add_subFinset a x]
      exact hmem x
    rw [hSeq]
    exact extremal_of_coset H a

end FourierFA