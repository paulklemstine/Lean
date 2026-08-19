/-
# Twisted Poisson summation: cosets, phases, and the exact boundary of rigidity

`Catalog.Applications.PoissonSummationConverse` classifies the pairs `(S, T)` satisfying the
*untwisted* Poisson identity: they are exactly the subgroups paired with their annihilators.
Cosets, however, also satisfy a Poisson identity, at the cost of a **phase**:

  `|G| * ∑_{x ∈ a + H} f x = |H| * ∑_{ψ ∈ H^⊥} ψ a * f̂ ψ`.

This file studies the *weighted* ("twisted") relation

  `|G| * ∑_{x ∈ S} f x = |S| * ∑_{ψ ∈ T} w ψ * f̂ ψ`   for all `f`   (`IsTwistedPoissonPair S T w`)

and determines exactly how much rigidity survives.

## Main results

* `FourierFA.dft_comp_add`, `FourierFA.dft_char_mul` — the covariance of the DFT under
  translation and modulation.
* `FourierFA.twistedPoisson_coset` — **Poisson summation over a coset** (the forward
  direction, with the phase `ψ ↦ ψ a`).
* `FourierFA.twistedPoisson_converse` — **the twisted converse**: if the weights are
  *unimodular* then `S` must be a coset `a + H`, `T` must be `H^⊥`, and the weight is forced
  to be the phase `w ψ = ψ a`.  Rigidity is therefore complete in the unimodular category.
* `FourierFA.twisted_of_nonempty` — **the boundary**: *without* the unimodularity hypothesis
  the statement collapses completely — **every** nonempty `S` whatsoever is a twisted Poisson
  set (with `T = Ĝ` and weights read off from `1_S` by Parseval).
* `FourierFA.not_coset_of_not_card_dvd` and
  `FourierFA.twisted_counterexample_zmod_three` — an explicit witness that the collapse is
  real: `S = {0, 1} ⊆ ℤ/3` carries a twisted Poisson identity but is not a coset.

Together these say that unimodularity of the weight is not a technical convenience: it is
precisely the hypothesis that separates the rigid regime from the vacuous one.
-/

import Mathlib
import Catalog.Shared.FourierFiniteAbelian
import Catalog.Shared.FourierSubgroupDuality
import Catalog.Applications.PoissonSummationConverse

open Finset Fintype ComplexConjugate

namespace FourierFA

variable {G : Type*} [AddCommGroup G] [Fintype G] [DecidableEq G]

/-! ## Covariance of the discrete Fourier transform -/

omit [DecidableEq G] in
/-- Translating the argument multiplies the Fourier transform by a phase. -/
theorem dft_comp_add (f : G → ℂ) (b : G) (ψ : AddChar G ℂ) :
    dft (fun x => f (x + b)) ψ = ψ b * dft f ψ := by
  have h : ∀ y : G, conj (ψ (y - b)) = ψ b * conj (ψ y) := by
    intro y
    rw [sub_eq_add_neg, ψ.map_add_eq_mul, map_mul, AddChar.map_neg_eq_conj,
      RCLike.conj_conj]
    ring
  rw [dft, ← Equiv.sum_comp (Equiv.subRight b) (fun x => conj (ψ x) * f (x + b))]
  have hsub : ∀ y : G, (Equiv.subRight b) y = y - b := fun _ => rfl
  simp_rw [hsub, sub_add_cancel, h]
  rw [dft, Finset.mul_sum]
  exact Finset.sum_congr rfl fun y _ => by ring

omit [DecidableEq G] in
/-- Modulating by a character translates the Fourier transform. -/
theorem dft_char_mul (f : G → ℂ) (ψ₀ χ : AddChar G ℂ) :
    dft (fun x => ψ₀ x * f x) χ = dft f (χ - ψ₀) := by
  rw [dft, dft]
  refine Finset.sum_congr rfl fun x _ => ?_
  have hu : (conj (ψ₀ x))⁻¹ = ψ₀ x := by
    refine inv_eq_of_mul_eq_one_right ?_
    rw [Complex.conj_mul', AddChar.norm_apply]
    norm_num
  have h : conj ((χ - ψ₀) x) = conj (χ x) * ψ₀ x := by
    rw [AddChar.sub_apply' χ ψ₀ x, map_div₀, div_eq_mul_inv, hu]
  rw [h]
  ring

/-! ## Twisted Poisson pairs -/

/-- `IsTwistedPoissonPair S T w` : the weighted Poisson identity
`|G| * ∑_{x ∈ S} f x = |S| * ∑_{ψ ∈ T} w ψ * f̂ ψ` holds for every `f`. -/
def IsTwistedPoissonPair (S : Finset G) (T : Finset (AddChar G ℂ))
    (w : AddChar G ℂ → ℂ) : Prop :=
  ∀ f : G → ℂ, (Fintype.card G : ℂ) * ∑ x ∈ S, f x
    = (S.card : ℂ) * ∑ ψ ∈ T, w ψ * dft f ψ

variable {S : Finset G} {T : Finset (AddChar G ℂ)} {w : AddChar G ℂ → ℂ}

omit [DecidableEq G] in
/-- An untwisted Poisson pair is a twisted one with all weights `1`. -/
theorem IsPoissonPair.toTwisted (h : IsPoissonPair S T) :
    IsTwistedPoissonPair S T (fun _ => 1) := by
  intro f
  rw [h f]
  exact congrArg _ (Finset.sum_congr rfl fun ψ _ => (one_mul _).symm)

omit [DecidableEq G] in
/-- Conversely, weights identically `1` on `T` give an untwisted Poisson pair. -/
theorem IsTwistedPoissonPair.toPoisson (h : IsTwistedPoissonPair S T w)
    (hw : ∀ ψ ∈ T, w ψ = 1) : IsPoissonPair S T := by
  intro f
  rw [h f]
  exact congrArg _ (Finset.sum_congr rfl fun ψ hψ => by rw [hw ψ hψ, one_mul])

/-- **Translation covariance of the twisted Poisson relation.**  Translating `S` by `b`
multiplies the weights by the phase `ψ b`. -/
theorem IsTwistedPoissonPair.translate (h : IsTwistedPoissonPair S T w) (b : G) :
    IsTwistedPoissonPair (S.image (· + b)) T (fun ψ => w ψ * ψ b) := by
  intro g
  have hinj : Set.InjOn (· + b) S := fun x _ y _ hxy => by
    simpa using add_right_cancel hxy
  have hcard : (S.image (· + b)).card = S.card :=
    Finset.card_image_of_injOn hinj
  have hsum : ∑ u ∈ S.image (· + b), g u = ∑ x ∈ S, g (x + b) :=
    Finset.sum_image (fun x hx y hy hxy => hinj hx hy hxy)
  rw [hsum, hcard, h (fun x => g (x + b))]
  refine congrArg _ (Finset.sum_congr rfl fun ψ _ => ?_)
  rw [dft_comp_add g b ψ]
  ring

/-! ## Test functions -/

omit [DecidableEq G] in
/-- The character test for a twisted pair. -/
theorem twisted_char_test (h : IsTwistedPoissonPair S T w) (ψ₀ : AddChar G ℂ) :
    ∑ x ∈ S, ψ₀ x = (S.card : ℂ) * (if ψ₀ ∈ T then w ψ₀ else 0) := by
  classical
  have hcard : (Fintype.card G : ℂ) ≠ 0 := by
    exact_mod_cast (Fintype.card_ne_zero (α := G))
  have hd : ∀ χ : AddChar G ℂ,
      w χ * dft (fun x => ψ₀ x) χ
        = if ψ₀ = χ then w χ * (Fintype.card G : ℂ) else 0 := by
    intro χ
    have hdft : dft (fun x => ψ₀ x) χ = if ψ₀ = χ then (Fintype.card G : ℂ) else 0 := by
      rw [dft, ← sum_char_mul_conj ψ₀ χ]
      exact Finset.sum_congr rfl fun x _ => mul_comm _ _
    rw [hdft, mul_ite, mul_zero]
  have key := h (fun x => ψ₀ x)
  rw [Finset.sum_congr rfl (fun χ (_ : χ ∈ T) => hd χ),
    Finset.sum_ite_eq T ψ₀ (fun χ => w χ * (Fintype.card G : ℂ))] at key
  refine mul_left_cancel₀ hcard ?_
  rw [key]
  by_cases hT : ψ₀ ∈ T
  · rw [if_pos hT, if_pos hT]; ring
  · rw [if_neg hT, if_neg hT]; ring

/-! ## Poisson summation over a coset -/

/-- Membership in a translated subgroup. -/
lemma mem_image_add_subFinset {H : AddSubgroup G} [DecidablePred (· ∈ H)] (a x : G) :
    x ∈ (subFinset H).image (· + a) ↔ x - a ∈ H := by
  classical
  simp only [Finset.mem_image, mem_subFinset]
  constructor
  · rintro ⟨y, hy, rfl⟩
    simpa using hy
  · intro hx
    exact ⟨x - a, hx, by simp⟩

/-- **Poisson summation over a coset.**  For a subgroup `H` and any `a : G`,
`|G| * ∑_{x ∈ a + H} f x = |H| * ∑_{ψ ∈ H^⊥} ψ a * f̂ ψ`. -/
theorem twistedPoisson_coset (H : AddSubgroup G) [DecidablePred (· ∈ H)] (a : G) :
    IsTwistedPoissonPair ((subFinset H).image (· + a)) (annih H) (fun ψ => ψ a) := by
  have h := (isPoissonPair_subgroup H).toTwisted.translate a
  intro f
  have := h f
  simpa using this

/-! ## The twisted converse -/

/-- **Twisted converse of Poisson summation.**  If the weights are unimodular on `T`, then a
nonempty twisted Poisson set is a *coset* `a + H`, `T` is the annihilator `H^⊥`, and the
weights are forced to be the phases `w ψ = ψ a`. -/
theorem twistedPoisson_converse (h : IsTwistedPoissonPair S T w) (hS : S.Nonempty)
    (hw : ∀ ψ ∈ T, ‖w ψ‖ = 1) :
    ∃ (H : AddSubgroup G) (a : G), a ∈ S ∧
      (∀ x : G, x ∈ S ↔ x - a ∈ H) ∧
      (∀ ψ : AddChar G ℂ, ψ ∈ T ↔ ∀ y ∈ H, ψ y = 1) ∧
      (∀ ψ ∈ T, w ψ = ψ a) := by
  classical
  obtain ⟨a, ha⟩ := hS
  -- translate `S` so that it contains `0`
  set S₀ : Finset G := S.image (· + (-a)) with hS₀def
  set v : AddChar G ℂ → ℂ := fun ψ => w ψ * ψ (-a) with hvdef
  have htr : IsTwistedPoissonPair S₀ T v := h.translate (-a)
  have hmem : ∀ x : G, x - a ∈ S₀ ↔ x ∈ S := by
    intro x
    simp only [hS₀def, Finset.mem_image]
    constructor
    · rintro ⟨y, hy, hxy⟩
      have : y = x := by
        have := hxy
        rw [← sub_eq_add_neg] at this
        exact sub_left_injective this
      exact this ▸ hy
    · intro hx
      exact ⟨x, hx, by rw [← sub_eq_add_neg]⟩
  have hzero : (0 : G) ∈ S₀ := by
    have := (hmem a).2 ha
    simpa using this
  have hS₀ : S₀.Nonempty := ⟨0, hzero⟩
  -- unimodular weights: `v` is identically `1` on `T`
  have hvnorm : ∀ ψ ∈ T, ‖v ψ‖ = 1 := by
    intro ψ hψ
    rw [hvdef]
    simp only [norm_mul, hw ψ hψ, AddChar.norm_apply, mul_one]
  have hv1 : ∀ ψ ∈ T, v ψ = 1 := by
    intro ψ₀ hψ₀
    have hc := twisted_char_test htr ψ₀
    rw [if_pos hψ₀] at hc
    have hconj : conj (v ψ₀) * v ψ₀ = 1 := by
      rw [Complex.conj_mul', hvnorm ψ₀ hψ₀]
      norm_num
    have hsum : ∑ x ∈ S₀, conj (v ψ₀) * ψ₀ x = (S₀.card : ℂ) := by
      rw [← Finset.mul_sum, hc, ← mul_assoc, mul_comm (conj (v ψ₀)) (S₀.card : ℂ),
        mul_assoc, hconj, mul_one]
    have hnorm : ∀ x ∈ S₀, ‖conj (v ψ₀) * ψ₀ x‖ = 1 := by
      intro x _
      rw [norm_mul, RCLike.norm_conj, hvnorm ψ₀ hψ₀, AddChar.norm_apply, mul_one]
    have h0 := eq_one_of_sum_eq_card hnorm hsum 0 hzero
    rw [AddChar.map_zero_eq_one, mul_one] at h0
    have : conj (conj (v ψ₀)) = conj (1 : ℂ) := congrArg conj h0
    simpa using this
  -- now the pair is untwisted, so the classification applies
  have hpp : IsPoissonPair S₀ T := htr.toPoisson hv1
  obtain ⟨H, hH, hHT⟩ := isPoissonPair_converse hpp hS₀
  refine ⟨H, a, ha, ?_, hHT, ?_⟩
  · intro x
    rw [← hmem x, hH (x - a)]
  · intro ψ hψ
    have := hv1 ψ hψ
    simp only [hvdef] at this
    have hphase : ψ (-a) * ψ a = 1 := by
      rw [← ψ.map_add_eq_mul, neg_add_cancel, AddChar.map_zero_eq_one]
    calc w ψ = w ψ * (ψ (-a) * ψ a) := by rw [hphase, mul_one]
      _ = (w ψ * ψ (-a)) * ψ a := by ring
      _ = ψ a := by rw [this, one_mul]

/-! ## The boundary: dropping unimodularity destroys all rigidity -/

/-- The indicator function of a finset. -/
noncomputable def finIndic (S : Finset G) : G → ℂ := fun x => if x ∈ S then 1 else 0

omit [AddCommGroup G] [Fintype G] in
@[simp] lemma finIndic_apply_of_mem {S : Finset G} {x : G} (hx : x ∈ S) :
    finIndic S x = 1 := by simp [finIndic, hx]

omit [AddCommGroup G] [Fintype G] in
@[simp] lemma finIndic_apply_of_not_mem {S : Finset G} {x : G} (hx : x ∉ S) :
    finIndic S x = 0 := by simp [finIndic, hx]

omit [AddCommGroup G] in
lemma supp_finIndic (S : Finset G) : supp (finIndic S) = S := by
  ext x
  by_cases hx : x ∈ S <;> simp [mem_supp, hx]

/-- **The Parseval representation of a partial sum**: summing `f` over an arbitrary finset `S`
is a Fourier-side pairing against the transform of the indicator of `S`.  This is the
"universal" Poisson identity from which all the twisted ones are specialisations. -/
theorem poisson_repr (S : Finset G) (f : G → ℂ) :
    (Fintype.card G : ℂ) * ∑ x ∈ S, f x
      = ∑ ψ : AddChar G ℂ, conj (dft (finIndic S) ψ) * dft f ψ := by
  have hpar := parseval f (finIndic S)
  have hR : ∑ x : G, f x * conj (finIndic S x) = ∑ x ∈ S, f x := by
    have hx : ∀ x : G, f x * conj (finIndic S x) = if x ∈ S then f x else 0 := by
      intro x
      by_cases hx : x ∈ S <;> simp [finIndic, hx]
    simp_rw [hx]
    rw [Finset.sum_ite_mem, Finset.univ_inter]
  rw [hR] at hpar
  rw [← hpar]
  exact Finset.sum_congr rfl fun ψ _ => mul_comm _ _

/-- **Without unimodularity there is no rigidity at all**: *every* nonempty finset `S`
satisfies a twisted Poisson identity, with `T = Ĝ` and weights obtained from `1_S` by
Parseval.  Hence the hypothesis `‖w ψ‖ = 1` in `twistedPoisson_converse` cannot be dropped. -/
theorem twisted_of_nonempty (S : Finset G) :
    IsTwistedPoissonPair S (Finset.univ : Finset (AddChar G ℂ))
      (fun ψ => (S.card : ℂ)⁻¹ * conj (dft (finIndic S) ψ)) := by
  intro f
  have hpar := parseval f (finIndic S)
  have hR : ∑ x : G, f x * conj (finIndic S x) = ∑ x ∈ S, f x := by
    have : ∀ x : G, f x * conj (finIndic S x) = if x ∈ S then f x else 0 := by
      intro x
      by_cases hx : x ∈ S <;> simp [finIndic, hx]
    simp_rw [this]
    rw [Finset.sum_ite_mem, Finset.univ_inter]
  rw [hR] at hpar
  by_cases hS : S.Nonempty
  · have hScard : (S.card : ℂ) ≠ 0 :=
      Nat.cast_ne_zero.2 (Finset.card_ne_zero_of_mem hS.choose_spec)
    rw [← hpar, Finset.mul_sum]
    refine Finset.sum_congr rfl fun ψ _ => ?_
    field_simp
  · rw [Finset.not_nonempty_iff_eq_empty] at hS
    subst hS
    simp

/-! ## An explicit non-coset witness -/

/-- If `|S|` does not divide `|G|` then `S` is not a coset of any subgroup. -/
theorem not_coset_of_not_card_dvd (hdvd : ¬ S.card ∣ Fintype.card G) :
    ¬ ∃ (H : AddSubgroup G) (a : G), ∀ x : G, x ∈ S ↔ x - a ∈ H := by
  classical
  rintro ⟨H, a, hH⟩
  refine hdvd ?_
  have hSeq : S = (subFinset H).image (· + a) := by
    ext x
    rw [mem_image_add_subFinset a x]
    exact hH x
  have hinj : Set.InjOn (· + a) (subFinset H) := fun x _ y _ hxy => by
    simpa using add_right_cancel hxy
  have hcard : S.card = (subFinset H).card := by
    rw [hSeq, Finset.card_image_of_injOn hinj]
  rw [hcard]
  exact ⟨(annih H).card, card_subgroup_mul_card_annihilator.symm⟩

/-- **The collapse is real.**  In `ℤ/3` the set `{0, 1}` is not a coset of any subgroup, yet
it carries a twisted Poisson identity (with non-unimodular weights).  This is a genuine
counterexample to the twisted converse without the hypothesis `‖w ψ‖ = 1`. -/
theorem twisted_counterexample_zmod_three :
    (∃ w : AddChar (ZMod 3) ℂ → ℂ,
        IsTwistedPoissonPair ({0, 1} : Finset (ZMod 3)) Finset.univ w) ∧
      ¬ ∃ (H : AddSubgroup (ZMod 3)) (a : ZMod 3),
          ∀ x : ZMod 3, x ∈ ({0, 1} : Finset (ZMod 3)) ↔ x - a ∈ H := by
  constructor
  · exact ⟨_, twisted_of_nonempty ({0, 1} : Finset (ZMod 3))⟩
  · refine not_coset_of_not_card_dvd ?_
    have hcard : ({0, 1} : Finset (ZMod 3)).card = 2 := by decide
    rw [hcard]
    simp only [ZMod.card]
    decide

end FourierFA