/-
# Closure of the extremal class under convolution

The classification of the extremals of the Donoho–Stark uncertainty principle
(`Catalog.Probability.FourierExtremalConverse`) makes the extremal class a *rigid*, purely
algebraic object. `Catalog.Probability.FourierExtremalAlgebra` shows it is closed under
pointwise products; this file proves the dual statement, which is genuinely harder because the
support of a convolution is not determined pointwise: the convolution of two extremal functions
is either `0` or extremal.

The proof is a two-sided squeeze:

* on the *frequency* side, `dft (u ∗ v) = û · v̂` shows that `supp (u ∗ v)^` is the intersection
  of two cosets of annihilators, i.e. empty or a coset of `(K ⊔ K')^⊥`;
* on the *space* side, `supp (u ∗ v) ⊆ (a + a') + (K ⊔ K')`;
* the two bounds multiply to exactly `|G|` by `|H| · |H^⊥| = |G|`, so the uncertainty principle
  `|supp w| * |supp ŵ| ≥ |G|` must be an equality.

Main results:

* `FourierFA.annihSub` : the annihilator of a subgroup as a subgroup of the dual group.
* `FourierFA.annihSub_sup` : `(K ⊔ K')^⊥ = K^⊥ ⊓ K'^⊥`.
* `FourierFA.card_coset_filter` : a coset has the same cardinality as its subgroup.
* `FourierFA.dft_ne_zero_iff_of_coset_values` : the frequency support of a coset modulation.
* `FourierFA.isExtremal_conv` : the extremal class is closed under convolution.
-/

import Mathlib
import Shared.FourierFiniteAbelian
import Shared.FourierSubgroupDuality
import Shared.FourierExtremals
import Probability.FourierExtremalConverse
import Probability.FourierExtremalAlgebra

open Finset ComplexConjugate

namespace FourierFA

variable {G : Type*} [AddCommGroup G] [Fintype G] [DecidableEq G]

/-! ## The annihilator as a subgroup of the dual -/

/-- The annihilator of a subgroup `H ≤ G`, as a subgroup of the dual group. -/
def annihSub (H : AddSubgroup G) : AddSubgroup (AddChar G ℂ) where
  carrier := {ψ : AddChar G ℂ | ∀ x ∈ H, ψ x = 1}
  zero_mem' := by intro x _; rfl
  add_mem' := by
    intro ψ χ hψ hχ x hx
    rw [AddChar.add_apply, hψ x hx, hχ x hx, one_mul]
  neg_mem' := by
    intro ψ hψ x hx
    rw [AddChar.neg_apply', hψ x hx, inv_one]

omit [Fintype G] [DecidableEq G] in
@[simp] lemma mem_annihSub {H : AddSubgroup G} {ψ : AddChar G ℂ} :
    ψ ∈ annihSub H ↔ ∀ x ∈ H, ψ x = 1 := Iff.rfl

omit [DecidableEq G] in
lemma annih_eq_annihSub (H : AddSubgroup G) [DecidablePred (· ∈ H)]
    [DecidablePred (· ∈ annihSub H)] : annih H = subFinset (annihSub H) := by
  ext ψ
  rw [mem_annih, mem_subFinset, mem_annihSub]

omit [Fintype G] [DecidableEq G] in
/-- The annihilator turns joins into meets. -/
theorem annihSub_sup (K K' : AddSubgroup G) :
    annihSub (K ⊔ K') = annihSub K ⊓ annihSub K' := by
  refine le_antisymm ?_ ?_
  · intro ψ hψ
    refine AddSubgroup.mem_inf.2 ⟨?_, ?_⟩
    · exact mem_annihSub.2 fun x hx => mem_annihSub.1 hψ x (AddSubgroup.mem_sup_left hx)
    · exact mem_annihSub.2 fun x hx => mem_annihSub.1 hψ x (AddSubgroup.mem_sup_right hx)
  · intro ψ hψ
    obtain ⟨h1, h2⟩ := AddSubgroup.mem_inf.1 hψ
    refine mem_annihSub.2 fun x hx => ?_
    -- the set where `ψ` is trivial is a subgroup containing both `K` and `K'`
    have hsub : K ⊔ K' ≤ eqSubgroup ψ 0 := by
      refine sup_le ?_ ?_
      · intro y hy
        exact mem_eqSubgroup.2 (by rw [mem_annihSub.1 h1 y hy]; rfl)
      · intro y hy
        exact mem_eqSubgroup.2 (by rw [mem_annihSub.1 h2 y hy]; rfl)
    have := mem_eqSubgroup.1 (hsub hx)
    simpa using this

/-! ## Cosets have the cardinality of their subgroup -/

lemma card_coset_filter (A : AddSubgroup G) [DecidablePred (· ∈ A)] (ξ : G) :
    (Finset.univ.filter (fun x : G => x - ξ ∈ A)).card = (subFinset A).card := by
  classical
  have himg : Finset.univ.filter (fun x : G => x - ξ ∈ A) = (subFinset A).image (fun k => ξ + k) := by
    ext x
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_image, mem_subFinset]
    constructor
    · intro hx
      exact ⟨x - ξ, hx, by abel⟩
    · rintro ⟨k, hk, rfl⟩
      simpa using hk
  rw [himg, Finset.card_image_of_injective _ (add_right_injective ξ)]

/-! ## The frequency support of a coset modulation -/

omit [Fintype G] [DecidableEq G] in
/-- A function given by coset-modulation data equals the corresponding coset modulation. -/
lemma eq_coset_modulation_of_values {f : G → ℂ} {K : AddSubgroup G} [DecidablePred (· ∈ K)]
    {χ : AddChar G ℂ} {a : G} {c : ℂ}
    (h1 : ∀ x, x - a ∈ K → f x = c * χ x) (h2 : ∀ x, x - a ∉ K → f x = 0) :
    f = c • modul χ (transl a (indic K)) := by
  funext x
  have hval : (c • modul χ (transl a (indic K))) x
      = c * (χ x * (if x - a ∈ K then (1 : ℂ) else 0)) := rfl
  rw [hval]
  by_cases hx : x - a ∈ K
  · rw [if_pos hx, h1 x hx]; ring
  · rw [if_neg hx, h2 x hx]; ring

omit [DecidableEq G] in
/-- The Fourier transform of a coset modulation is supported exactly on the coset `χ + K^⊥`. -/
theorem dft_ne_zero_iff_of_coset_values {f : G → ℂ} {K : AddSubgroup G} {χ : AddChar G ℂ}
    {a : G} {c : ℂ} (hc : c ≠ 0)
    (h1 : ∀ x, x - a ∈ K → f x = c * χ x) (h2 : ∀ x, x - a ∉ K → f x = 0) (ψ : AddChar G ℂ) :
    dft f ψ ≠ 0 ↔ ψ - χ ∈ annihSub K := by
  classical
  letI : DecidablePred (· ∈ K) := fun _ => Classical.dec _
  rw [eq_coset_modulation_of_values h1 h2, dft_coset_modulation]
  by_cases h : ψ - χ ∈ annih K
  · rw [if_pos h]
    have hK : ((subFinset K).card : ℂ) ≠ 0 := by
      have hpos := card_subFinset_pos (H := K)
      have hne : (subFinset K).card ≠ 0 := by omega
      exact_mod_cast hne
    have hchar : conj ((ψ - χ) a) ≠ 0 := by
      simp only [ne_eq, map_eq_zero]
      intro h0
      have := AddChar.norm_apply (ψ - χ) a
      rw [h0] at this
      simp at this
    constructor
    · intro _
      exact mem_annihSub.2 (mem_annih.1 h)
    · intro _
      exact mul_ne_zero (mul_ne_zero hc hchar) hK
  · rw [if_neg h]
    constructor
    · intro h0; exact absurd rfl h0
    · intro hc'
      exact absurd (mem_annih.2 (mem_annihSub.1 hc')) h

/-! ## Convolution closure -/

/-- **The extremal class is closed under convolution.** The convolution of two extremal
functions is either identically zero (when the two frequency cosets are disjoint) or extremal. -/
theorem isExtremal_conv {u v : G → ℂ} (hu0 : u ≠ 0) (hv0 : v ≠ 0)
    (hu : IsExtremal u) (hv : IsExtremal v) :
    conv u v = 0 ∨ IsExtremal (conv u v) := by
  classical
  obtain ⟨K, χ, a, c, hc, h1, h2⟩ := exists_coset_modulation_of_isExtremal u hu0 hu
  obtain ⟨K', χ', a', c', hc', h1', h2'⟩ := exists_coset_modulation_of_isExtremal v hv0 hv
  letI : DecidablePred (· ∈ K ⊔ K') := fun _ => Classical.dec _
  letI : DecidablePred (· ∈ annihSub (K ⊔ K')) := fun _ => Classical.dec _
  set w := conv u v with hw
  -- the frequency support of `w`
  have hdftw : ∀ ψ : AddChar G ℂ,
      dft w ψ ≠ 0 ↔ (ψ - χ ∈ annihSub K ∧ ψ - χ' ∈ annihSub K') := by
    intro ψ
    rw [hw, dft_conv, mul_ne_zero_iff, dft_ne_zero_iff_of_coset_values hc h1 h2,
      dft_ne_zero_iff_of_coset_values hc' h1' h2']
  by_cases hnone : ∀ ψ : AddChar G ℂ, dft w ψ = 0
  · left
    have : dft w = 0 := funext hnone
    exact dft_injective (by rw [this, dft_zero])
  · right
    push_neg at hnone
    obtain ⟨ξ, hξ⟩ := hnone
    obtain ⟨hξ1, hξ2⟩ := (hdftw ξ).1 hξ
    -- frequency side: `supp ŵ` is a coset of `(K ⊔ K')^⊥`
    have hsuppdft : supp (dft w) = Finset.univ.filter
        (fun ψ : AddChar G ℂ => ψ - ξ ∈ annihSub (K ⊔ K')) := by
      ext ψ
      rw [mem_supp, Finset.mem_filter]
      constructor
      · intro hψ
        refine ⟨Finset.mem_univ _, ?_⟩
        have := (hdftw ψ).1 hψ
        rw [annihSub_sup]
        exact (inter_coset (K := annihSub K) (K' := annihSub K') hξ1 hξ2 ψ).1 this
      · rintro ⟨-, hψ⟩
        rw [annihSub_sup] at hψ
        exact (hdftw ψ).2 ((inter_coset (K := annihSub K) (K' := annihSub K') hξ1 hξ2 ψ).2 hψ)
    have hcarddft : (supp (dft w)).card = (annih (K ⊔ K')).card := by
      rw [hsuppdft, card_coset_filter, ← annih_eq_annihSub]
    -- space side: `supp w` is contained in the coset `(a + a') + (K ⊔ K')`
    have hsuppw : ∀ x ∈ supp w, x - (a + a') ∈ K ⊔ K' := by
      intro x hx
      have hne : w x ≠ 0 := mem_supp.1 hx
      rw [hw] at hne
      simp only [FourierFA.conv] at hne
      obtain ⟨y, -, hy⟩ := Finset.exists_ne_zero_of_sum_ne_zero hne
      have hyu : y - a ∈ K := by
        by_contra hcon
        exact hy (by rw [h2 y hcon, zero_mul])
      have hyv : (x - y) - a' ∈ K' := by
        by_contra hcon
        exact hy (by rw [h2' (x - y) hcon, mul_zero])
      have hsplit : x - (a + a') = (y - a) + ((x - y) - a') := by abel
      rw [hsplit]
      exact (K ⊔ K').add_mem (AddSubgroup.mem_sup_left hyu) (AddSubgroup.mem_sup_right hyv)
    have hcardw : (supp w).card ≤ (subFinset (K ⊔ K')).card := by
      have hsub : supp w ⊆ Finset.univ.filter (fun x : G => x - (a + a') ∈ K ⊔ K') :=
        fun x hx => Finset.mem_filter.2 ⟨Finset.mem_univ x, hsuppw x hx⟩
      have hle := Finset.card_le_card hsub
      rwa [card_coset_filter (K ⊔ K') (a + a')] at hle
    -- the two bounds multiply to `|G|`
    have hw0 : w ≠ 0 := by
      intro h0
      rw [h0, dft_zero] at hξ
      exact hξ rfl
    have hlower := uncertainty w hw0
    have hupper : (supp w).card * (supp (dft w)).card ≤ Fintype.card G := by
      rw [hcarddft]
      calc (supp w).card * (annih (K ⊔ K')).card
          ≤ (subFinset (K ⊔ K')).card * (annih (K ⊔ K')).card :=
            Nat.mul_le_mul_right _ hcardw
        _ = Fintype.card G := card_subgroup_mul_card_annihilator
    exact le_antisymm hupper hlower

end FourierFA