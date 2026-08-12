import Bridges.CosetClassification
import Bridges.FiniteAbelianUncertainty

/-!
# The classification of Donoho–Stark extremals over an arbitrary finite abelian group

`Catalog/Bridges/CosetClassification.lean` classified the equality case of the Donoho–Stark
uncertainty principle on `ZMod N`: an extremal is a nonzero constant times a character times the
indicator of a coset of a subgroup. That proof used the explicit cyclic characters
`stdAddChar (j * k)` throughout. *Conjecture 3* of the thread's `FUTURE_DIRECTIONS.md` asserted
that only two structural inputs are really needed — the nondegeneracy of the pairing
`G × Ĝ → ℂ` and the duality count `|ann H| · |H| = |G|` — and that the classification therefore
holds over every finite abelian group, with the Pontryagin dual `AddChar G ℂ` in place of the
second copy of `ZMod N`.

This file proves that conjecture.

## Main results

* `AbelianCosetClassification.card_annGrp_mul_card` : **duality counting.** For a subgroup `H` of
  the dual group `AddChar G ℂ`, `|ann H| · |H| = |G|`, where `ann H ⊆ G` is the set of points on
  which every character in `H` is trivial. Proved by evaluating the double character sum
  `∑_{x ∈ G} ∑_{ψ ∈ H} ψ x` in the two possible orders.
* `AbelianCosetClassification.flat_of_extremal` : **modulus rigidity.** An extremal has constant
  modulus on its support.
* `AbelianCosetClassification.norm_gdft_eq_of_extremal` : every nonzero Fourier coefficient of an
  extremal has modulus equal to the full `ℓ¹` norm of the function.
* `AbelianCosetClassification.phase_of_extremal` : **phase rigidity**, via the equality case of
  the triangle inequality (`ExtremalCosets.sum_alignment`, reused verbatim).
* `AbelianCosetClassification.extremal_orthogonality` : the orthogonality relation
  `(ψ * ψ'⁻¹) (a - a') = 1` for `a, a'` in the support and `ψ, ψ'` in the spectrum.
* `AbelianCosetClassification.extremal_support_coset` : **the classification.** The support of an
  extremal is a coset of a subgroup of `G` of order `|supp f|`.
* `AbelianCosetClassification.extremal_spectrum_coset` : dually, the spectrum is a coset of the
  annihilator subgroup of the dual group; this comes out of the same cardinality squeeze.
* `AbelianCosetClassification.extremal_eq_modulated_coset_indicator` : the closed form, a nonzero
  constant times a character times a coset indicator.
* `AbelianCosetClassification.uncertainty_strict_of_norms_ne` : the contrapositive strict
  uncertainty principle, valid over every finite abelian group.
* `AbelianCosetClassification.modCosetIndicator_extremal` : **the converse.** Every modulated
  coset indicator is an extremal, proved from the dual duality count
  `card_annChar_mul_card`; hence `extremal_iff_modCosetIndicator`, an exact characterisation of
  the equality case, and `uncertainty_strict_of_not_modCosetIndicator`, the strict inequality for
  everything else.
* `AbelianCosetClassification.zmod_six_extremal` : a concrete instance over `ZMod 6` (the
  subgroup `{0, 3}`), certifying that the hypotheses are satisfiable.
* `AbelianCosetClassification.annGrp_annChar_eq`, `annChar_annGrp_eq`, `annihilator_antiIso` :
  the double annihilator theorem in both directions, i.e. annihilation is an inclusion-reversing
  bijection between the subgroups of `G` and those of its dual — finite Pontryagin duality at
  the level of subgroup lattices.
* `AbelianCosetClassification.extremal_additive_subgroup_order` : the additive uncertainty
  functional of an extremal is `d + |G|/d` for a subgroup order `d`.

Unlike the cyclic proof, no arithmetic of `ZMod N` is used: the only inputs are
`AddChar.sum_apply_eq_ite` (nondegeneracy of the pairing in the group variable) and
`AddChar.sum_eq_zero_of_ne_one` (nondegeneracy in the character variable).
-/

open Finset FiniteAbelianUncertainty

namespace AbelianCosetClassification

variable {G : Type*} [AddCommGroup G] [Fintype G] [DecidableEq G]

/-! ## 1. Annihilators and duality counting -/

open scoped Classical in
/-- The annihilator, inside the dual group, of a finite subset of `G`. -/
noncomputable def annChar (B : Finset G) : Finset (AddChar G ℂ) :=
  Finset.univ.filter fun psi => ∀ b ∈ B, psi b = 1

open scoped Classical in
/-- The annihilator, inside `G`, of a finite set of characters. -/
noncomputable def annGrp (H : Finset (AddChar G ℂ)) : Finset G :=
  Finset.univ.filter fun x => ∀ psi ∈ H, psi x = 1

open scoped Classical in
@[simp]
theorem mem_annChar {B : Finset G} {psi : AddChar G ℂ} :
    psi ∈ annChar B ↔ ∀ b ∈ B, psi b = 1 := by simp [annChar]

open scoped Classical in
omit [DecidableEq G] in
@[simp]
theorem mem_annGrp {H : Finset (AddChar G ℂ)} {x : G} :
    x ∈ annGrp H ↔ ∀ psi ∈ H, psi x = 1 := by simp [annGrp]

theorem one_mem_annChar (B : Finset G) : (1 : AddChar G ℂ) ∈ annChar B := by
  simp

theorem mul_mem_annChar {B : Finset G} {psi phi : AddChar G ℂ}
    (hpsi : psi ∈ annChar B) (hphi : phi ∈ annChar B) : psi * phi ∈ annChar B := by
  rw [mem_annChar] at *
  intro b hb
  rw [AddChar.mul_apply, hpsi b hb, hphi b hb, one_mul]

omit [DecidableEq G] in
theorem zero_mem_annGrp (H : Finset (AddChar G ℂ)) : (0 : G) ∈ annGrp H := by
  simp

omit [DecidableEq G] in
theorem add_mem_annGrp {H : Finset (AddChar G ℂ)} {x y : G}
    (hx : x ∈ annGrp H) (hy : y ∈ annGrp H) : x + y ∈ annGrp H := by
  rw [mem_annGrp] at *
  intro psi hpsi
  rw [AddChar.map_add_eq_mul, hx psi hpsi, hy psi hpsi, one_mul]

omit [DecidableEq G] in
/-- The sum of a character over the whole group: `|G|` for the trivial character, `0` otherwise.
This is nondegeneracy of the pairing in the character variable. -/
theorem sum_char_univ (psi : AddChar G ℂ) :
    ∑ x : G, psi x = if psi = 1 then (Fintype.card G : ℂ) else 0 := by
  classical
  by_cases h : psi = 1
  · subst h
    simp
  · simp [h, AddChar.sum_eq_zero_of_ne_one h]

omit [Fintype G] [DecidableEq G] in
/-- Translating a subgroup of the dual group by one of its elements is a bijection. -/
theorem image_mul_self {H : Finset (AddChar G ℂ)}
    (hmul : ∀ a ∈ H, ∀ b ∈ H, a * b ∈ H) {psi₀ : AddChar G ℂ} (hpsi₀ : psi₀ ∈ H) :
    H.image (fun psi => psi * psi₀) = H := by
  classical
  refine Finset.eq_of_subset_of_card_le ?_ ?_
  · intro x hx
    simp only [Finset.mem_image] at hx
    obtain ⟨psi, hpsi, rfl⟩ := hx
    exact hmul psi hpsi psi₀ hpsi₀
  · rw [Finset.card_image_of_injective _ (mul_left_injective psi₀)]

/-- The character sum over a subgroup of the dual group, at a fixed point of `G`: it is the order
of the subgroup on the annihilator and vanishes elsewhere. -/
theorem sum_subgroup_apply {H : Finset (AddChar G ℂ)}
    (hmul : ∀ a ∈ H, ∀ b ∈ H, a * b ∈ H) (x : G) :
    ∑ psi ∈ H, psi x = if x ∈ annGrp H then (H.card : ℂ) else 0 := by
  classical
  by_cases hx : x ∈ annGrp H
  · simp only [hx, if_true]
    rw [mem_annGrp] at hx
    rw [Finset.sum_congr rfl fun psi hpsi => hx psi hpsi]
    simp
  · simp only [hx, if_false]
    rw [mem_annGrp] at hx
    push_neg at hx
    obtain ⟨psi₀, hpsi₀, hne⟩ := hx
    have hshift : ∑ psi ∈ H, psi x = psi₀ x * ∑ psi ∈ H, psi x := by
      conv_lhs => rw [← image_mul_self hmul hpsi₀]
      rw [Finset.sum_image fun a _ b _ hab => mul_left_injective psi₀ hab, Finset.mul_sum]
      exact Finset.sum_congr rfl fun psi _ => by rw [AddChar.mul_apply, mul_comm]
    have hzero : (1 - psi₀ x) * ∑ psi ∈ H, psi x = 0 := by
      rw [sub_mul, one_mul, ← hshift, sub_self]
    rcases mul_eq_zero.1 hzero with hz | hz
    · exact absurd (by linear_combination -hz : psi₀ x = 1) hne
    · exact hz

/-- **Duality counting over an arbitrary finite abelian group.** A subgroup `H` of the dual group
and its annihilator in `G` have orders multiplying to `|G|`. -/
theorem card_annGrp_mul_card {H : Finset (AddChar G ℂ)} (h1 : (1 : AddChar G ℂ) ∈ H)
    (hmul : ∀ a ∈ H, ∀ b ∈ H, a * b ∈ H) :
    (annGrp H).card * H.card = Fintype.card G := by
  classical
  have key : ((annGrp H).card * H.card : ℂ) = (Fintype.card G : ℂ) := by
    have hswap : ∑ x : G, ∑ psi ∈ H, psi x = ∑ psi ∈ H, ∑ x : G, psi x := Finset.sum_comm
    have hleft : ∑ x : G, ∑ psi ∈ H, psi x = ((annGrp H).card * H.card : ℂ) := by
      rw [Finset.sum_congr rfl fun x _ => sum_subgroup_apply hmul x, Finset.sum_ite_mem]
      simp [Finset.univ_inter, Finset.sum_const, nsmul_eq_mul]
    have hright : ∑ psi ∈ H, ∑ x : G, psi x = (Fintype.card G : ℂ) := by
      rw [Finset.sum_congr rfl fun psi _ => sum_char_univ psi,
        Finset.sum_ite_eq' H (1 : AddChar G ℂ) (fun _ => (Fintype.card G : ℂ)), if_pos h1]
    rw [← hleft, hswap, hright]
  exact_mod_cast key

/-! ## 2. The equality analysis of the Donoho–Stark chain -/

omit [DecidableEq G] in
/-- The Fourier transform as a sum over the support. -/
theorem gdft_sum_gsupport (f : G → ℂ) (psi : AddChar G ℂ) :
    gdft f psi = ∑ a ∈ gsupport f, psi (-a) * f a := by
  classical
  rw [gdft]
  refine (Finset.sum_subset (Finset.subset_univ _) ?_).symm
  intro x _ hx
  have : f x = 0 := by
    by_contra h
    exact hx (mem_gsupport.2 h)
  simp [this]

omit [DecidableEq G] in
/-- Every Fourier coefficient is bounded by the `ℓ¹` norm of the function. -/
theorem norm_gdft_le_sum (f : G → ℂ) (psi : AddChar G ℂ) :
    ‖gdft f psi‖ ≤ ∑ a ∈ gsupport f, ‖f a‖ := by
  classical
  rw [gdft_sum_gsupport]
  refine (norm_sum_le _ _).trans (Finset.sum_le_sum fun a _ => ?_)
  rw [norm_mul, AddChar.norm_apply, one_mul]

omit [AddCommGroup G] [Fintype G] [DecidableEq G] in
/-- The maximum of `‖f‖` is positive when `f ≠ 0`. -/
theorem max_norm_pos {f : G → ℂ} (hf : f ≠ 0) {b : G} (hb : ∀ a, ‖f a‖ ≤ ‖f b‖) :
    0 < ‖f b‖ := by
  rcases lt_or_eq_of_le (norm_nonneg (f b)) with h | h
  · exact h
  · exact absurd (funext fun a => by
      have : ‖f a‖ ≤ 0 := by linarith [hb a]
      simpa using le_antisymm this (norm_nonneg _)) hf

/-- The spectrum of a nonzero function is nonempty. -/
theorem dsupport_nonempty {f : G → ℂ} (hf : f ≠ 0) : (dsupport (gdft f)).Nonempty := by
  classical
  by_contra h
  rw [Finset.not_nonempty_iff_eq_empty] at h
  have hzero : ∀ psi : AddChar G ℂ, gdft f psi = 0 := by
    intro psi
    by_contra hne
    have : psi ∈ dsupport (gdft f) := mem_dsupport.2 hne
    rw [h] at this
    simp at this
  apply hf
  funext b
  have hinv := gdft_inversion f b
  rw [Finset.sum_congr rfl fun psi _ => by rw [hzero psi, mul_zero]] at hinv
  simp only [Finset.sum_const_zero] at hinv
  have hG : (Fintype.card G : ℂ) ≠ 0 := by
    have : 0 < Fintype.card G := Fintype.card_pos
    exact_mod_cast this.ne'
  have := (mul_eq_zero.1 hinv.symm).resolve_left hG
  simpa using this

omit [AddCommGroup G] [DecidableEq G] in
/-- The support of a nonzero function is nonempty. -/
theorem gsupport_nonempty {f : G → ℂ} (hf : f ≠ 0) : (gsupport f).Nonempty := by
  classical
  rcases Function.ne_iff.1 hf with ⟨a, ha⟩
  exact ⟨a, mem_gsupport.2 (by simpa using ha)⟩

/-- **The core equality analysis.** For an extremal, the `ℓ¹` norm is exactly `|supp f|` times the
maximal modulus, *and* every spectral coefficient has modulus equal to that `ℓ¹` norm. Both
statements come from the single chain
`|G|·M = ‖∑_ψ ψ(b) 𝓖f(ψ)‖ ≤ ∑_{ψ ∈ spec} ‖𝓖f ψ‖ ≤ |spec|·‖f‖₁ ≤ |spec|·|supp f|·M = |G|·M`,
all of whose inequalities must therefore be equalities. -/
theorem extremal_chain {f : G → ℂ} (hf : f ≠ 0) {b : G} (hb : ∀ a, ‖f a‖ ≤ ‖f b‖)
    (hext : (gsupport f).card * (dsupport (gdft f)).card = Fintype.card G) :
    (∑ a ∈ gsupport f, ‖f a‖) = (gsupport f).card * ‖f b‖ ∧
      ∀ psi ∈ dsupport (gdft f), ‖gdft f psi‖ = ∑ a ∈ gsupport f, ‖f a‖ := by
  classical
  set M : ℝ := ‖f b‖ with hM
  set s : ℕ := (gsupport f).card with hs
  set t : ℕ := (dsupport (gdft f)).card with ht
  set S : ℝ := ∑ a ∈ gsupport f, ‖f a‖ with hS
  have hMpos : 0 < M := max_norm_pos hf hb
  -- the upper bound `‖f‖₁ ≤ s · M`
  have hSupper : S ≤ (s : ℝ) * M := by
    have := Finset.sum_le_card_nsmul (gsupport f) (fun a => ‖f a‖) M fun a _ => hb a
    simpa [hS, hs, nsmul_eq_mul] using this
  -- the lower bound coming from inversion
  have hA : ‖∑ psi : AddChar G ℂ, psi b * gdft f psi‖ = (Fintype.card G : ℝ) * M := by
    rw [gdft_inversion f b, norm_mul, hM]
    simp
  have hB : ‖∑ psi : AddChar G ℂ, psi b * gdft f psi‖
      ≤ ∑ psi ∈ dsupport (gdft f), ‖gdft f psi‖ := by
    have hrestrict : ∑ psi : AddChar G ℂ, psi b * gdft f psi
        = ∑ psi ∈ dsupport (gdft f), psi b * gdft f psi := by
      refine (Finset.sum_subset (Finset.subset_univ _) ?_).symm
      intro psi _ hpsi
      have : gdft f psi = 0 := by
        by_contra h
        exact hpsi (mem_dsupport.2 h)
      simp [this]
    rw [hrestrict]
    refine (norm_sum_le _ _).trans (le_of_eq (Finset.sum_congr rfl fun psi _ => ?_))
    rw [norm_mul, AddChar.norm_apply, one_mul]
  have hC : ∑ psi ∈ dsupport (gdft f), ‖gdft f psi‖ ≤ (t : ℝ) * S := by
    have := Finset.sum_le_card_nsmul (dsupport (gdft f)) (fun psi => ‖gdft f psi‖) S
      fun psi _ => norm_gdft_le_sum f psi
    simpa [ht, nsmul_eq_mul] using this
  have hst : (t : ℝ) * (s : ℝ) = (Fintype.card G : ℝ) := by
    have hcast : (s * t : ℕ) = Fintype.card G := hext
    push_cast [← hcast]; ring
  have hGM : (Fintype.card G : ℝ) * M ≤ (t : ℝ) * S := by
    rw [← hA]; exact hB.trans hC
  have htpos : (0 : ℝ) < t := by
    rcases Nat.eq_zero_or_pos t with h | h
    · exfalso
      rw [h] at hGM
      simp only [Nat.cast_zero, zero_mul] at hGM
      have hGpos : (0 : ℝ) < Fintype.card G := by exact_mod_cast Fintype.card_pos
      nlinarith
    · exact_mod_cast h
  -- the `ℓ¹` norm is exactly `s · M`
  have hSeq : S = (s : ℝ) * M := by
    have h4 : (t : ℝ) * ((s : ℝ) * M) ≤ (t : ℝ) * S := by
      calc (t : ℝ) * ((s : ℝ) * M) = ((t : ℝ) * (s : ℝ)) * M := by ring
        _ = (Fintype.card G : ℝ) * M := by rw [hst]
        _ ≤ (t : ℝ) * S := hGM
    have := le_of_mul_le_mul_left h4 htpos
    linarith
  refine ⟨hSeq, ?_⟩
  -- the spectral coefficients all have the maximal modulus
  have hsum : ∑ psi ∈ dsupport (gdft f), ‖gdft f psi‖ = ∑ _psi ∈ dsupport (gdft f), S := by
    have hge : (t : ℝ) * S ≤ ∑ psi ∈ dsupport (gdft f), ‖gdft f psi‖ := by
      refine le_trans (le_of_eq ?_) (hA ▸ hB)
      calc (t : ℝ) * S = ((t : ℝ) * (s : ℝ)) * M := by rw [hSeq]; ring
        _ = (Fintype.card G : ℝ) * M := by rw [hst]
    have hconst : ∑ _psi ∈ dsupport (gdft f), S = (t : ℝ) * S := by
      rw [Finset.sum_const, nsmul_eq_mul, ht]
    rw [hconst]
    exact le_antisymm hC hge
  exact fun psi hpsi =>
    (Finset.sum_eq_sum_iff_of_le fun psi _ => norm_gdft_le_sum f psi).1 hsum psi hpsi

/-- **Modulus rigidity over an arbitrary finite abelian group.** An extremal of the Donoho–Stark
inequality has constant modulus on its support. -/
theorem flat_of_extremal {f : G → ℂ} (hf : f ≠ 0)
    (hext : (gsupport f).card * (dsupport (gdft f)).card = Fintype.card G)
    {a a' : G} (ha : a ∈ gsupport f) (ha' : a' ∈ gsupport f) : ‖f a‖ = ‖f a'‖ := by
  classical
  obtain ⟨b, -, hb'⟩ :=
    Finset.exists_max_image (Finset.univ : Finset G) (fun a => ‖f a‖) ⟨0, mem_univ 0⟩
  have hb : ∀ a, ‖f a‖ ≤ ‖f b‖ := fun a => hb' a (mem_univ a)
  obtain ⟨hSeq, -⟩ := extremal_chain hf hb hext
  have hconst : ∑ _a ∈ gsupport f, ‖f b‖ = (gsupport f).card * ‖f b‖ := by
    rw [Finset.sum_const, nsmul_eq_mul]
  have heq : ∑ a ∈ gsupport f, ‖f a‖ = ∑ _a ∈ gsupport f, ‖f b‖ := by rw [hSeq, hconst]
  have hall := (Finset.sum_eq_sum_iff_of_le fun a _ => hb a).1 heq
  rw [hall a ha, hall a' ha']

/-- **A strict uncertainty principle over an arbitrary finite abelian group.** A function taking
two distinct nonzero moduli is never extremal. -/
theorem uncertainty_strict_of_norms_ne {f : G → ℂ} {a a' : G}
    (ha : f a ≠ 0) (ha' : f a' ≠ 0) (hne : ‖f a‖ ≠ ‖f a'‖) :
    Fintype.card G < (gsupport f).card * (dsupport (gdft f)).card := by
  classical
  have hf : f ≠ 0 := fun h => ha (by rw [h]; rfl)
  refine lt_of_le_of_ne (donoho_stark_finite_abelian f hf) fun hEq => hne ?_
  exact flat_of_extremal hf hEq.symm (mem_gsupport.2 ha) (mem_gsupport.2 ha')

/-- **The Fourier coefficients of an extremal are as large as possible.** -/
theorem norm_gdft_eq_of_extremal {f : G → ℂ} (hf : f ≠ 0)
    (hext : (gsupport f).card * (dsupport (gdft f)).card = Fintype.card G)
    {psi : AddChar G ℂ} (hpsi : psi ∈ dsupport (gdft f)) :
    ‖gdft f psi‖ = ∑ a ∈ gsupport f, ‖f a‖ := by
  classical
  obtain ⟨b, -, hb'⟩ :=
    Finset.exists_max_image (Finset.univ : Finset G) (fun a => ‖f a‖) ⟨0, mem_univ 0⟩
  have hb : ∀ a, ‖f a‖ ≤ ‖f b‖ := fun a => hb' a (mem_univ a)
  exact (extremal_chain hf hb hext).2 psi hpsi

/-! ## 3. Phase rigidity and the orthogonality relation -/

/-- **Phase rigidity.** For every spectral character `ψ` of an extremal, all the terms
`ψ(-a) f a`, `a ∈ supp f`, are equal to `‖f a‖` times one and the same unimodular number. -/
theorem phase_of_extremal {f : G → ℂ} (hf : f ≠ 0)
    (hext : (gsupport f).card * (dsupport (gdft f)).card = Fintype.card G)
    {psi : AddChar G ℂ} (hpsi : psi ∈ dsupport (gdft f)) :
    ∀ a ∈ gsupport f,
      psi (-a) * f a = (‖f a‖ : ℂ) * (gdft f psi / (‖gdft f psi‖ : ℂ)) := by
  classical
  have hne : gdft f psi ≠ 0 := mem_dsupport.1 hpsi
  set θ : ℂ := gdft f psi / (‖gdft f psi‖ : ℂ) with hθdef
  have hθ : ‖θ‖ = 1 := by
    rw [hθdef, norm_div, Complex.norm_real, norm_norm, div_self (norm_ne_zero_iff.2 hne)]
  set F : G → ℂ := fun a => psi (-a) * f a with hF
  have hFnorm : ∀ a, ‖F a‖ = ‖f a‖ := by
    intro a
    rw [hF, norm_mul, AddChar.norm_apply, one_mul]
  have hsum : ∑ a ∈ gsupport f, F a = ((∑ a ∈ gsupport f, ‖F a‖ : ℝ) : ℂ) * θ := by
    have h1 : ∑ a ∈ gsupport f, F a = gdft f psi := (gdft_sum_gsupport f psi).symm
    have h2 : (∑ a ∈ gsupport f, ‖F a‖) = ‖gdft f psi‖ := by
      simp only [hFnorm]
      exact (norm_gdft_eq_of_extremal hf hext hpsi).symm
    rw [h1, h2, hθdef]
    field_simp
    exact (div_self (by simpa using norm_ne_zero_iff.2 hne)).symm
  intro a ha
  have := ExtremalCosets.sum_alignment (gsupport f) F θ hθ hsum a ha
  rw [hFnorm a] at this
  exact this

/-- On its support, an extremal is a single modulated flat function. -/
theorem extremal_char_on_support {f : G → ℂ} (hf : f ≠ 0)
    (hext : (gsupport f).card * (dsupport (gdft f)).card = Fintype.card G)
    {a a' : G} {psi : AddChar G ℂ} (ha : a ∈ gsupport f) (ha' : a' ∈ gsupport f)
    (hpsi : psi ∈ dsupport (gdft f)) :
    f a = psi (a - a') * f a' := by
  have hnorm : ‖f a‖ = ‖f a'‖ := flat_of_extremal hf hext ha ha'
  have h1 := phase_of_extremal hf hext hpsi a ha
  have h2 := phase_of_extremal hf hext hpsi a' ha'
  have h3 : psi (-a) * f a = psi (-a') * f a' := by rw [h1, h2, hnorm]
  have hcancel : psi a * psi (-a) = 1 := by
    rw [← AddChar.map_add_eq_mul, add_neg_cancel, AddChar.map_zero_eq_one]
  have hcomb : psi a * psi (-a') = psi (a - a') := by
    rw [← AddChar.map_add_eq_mul]
    congr 1
    abel
  calc f a = (psi a * psi (-a)) * f a := by rw [hcancel, one_mul]
    _ = psi a * (psi (-a) * f a) := by ring
    _ = psi a * (psi (-a') * f a') := by rw [h3]
    _ = (psi a * psi (-a')) * f a' := by ring
    _ = psi (a - a') * f a' := by rw [hcomb]

/-- **The orthogonality relation.** For an extremal, every quotient of two spectral characters is
trivial on the difference set of the support. -/
theorem extremal_orthogonality {f : G → ℂ} (hf : f ≠ 0)
    (hext : (gsupport f).card * (dsupport (gdft f)).card = Fintype.card G)
    {a a' : G} {psi psi' : AddChar G ℂ} (ha : a ∈ gsupport f) (ha' : a' ∈ gsupport f)
    (hpsi : psi ∈ dsupport (gdft f)) (hpsi' : psi' ∈ dsupport (gdft f)) :
    (psi * psi'⁻¹) (a - a') = 1 := by
  have e1 := extremal_char_on_support hf hext ha ha' hpsi
  have e2 := extremal_char_on_support hf hext ha ha' hpsi'
  have ha'ne : f a' ≠ 0 := mem_gsupport.1 ha'
  have hchar : psi (a - a') = psi' (a - a') := mul_right_cancel₀ ha'ne (e1.symm.trans e2)
  have hunit : psi' (a - a') ≠ 0 := by
    intro h
    have h1 : ‖psi' (a - a')‖ = 1 := AddChar.norm_apply _ _
    rw [h] at h1
    simp at h1
  rw [AddChar.mul_apply, AddChar.inv_apply]
  have hinv : psi' (-(a - a')) = (psi' (a - a'))⁻¹ := by
    have : psi' (a - a') * psi' (-(a - a')) = 1 := by
      rw [← AddChar.map_add_eq_mul, add_neg_cancel, AddChar.map_zero_eq_one]
    field_simp at this ⊢
    linear_combination this
  rw [hinv, hchar]
  exact mul_inv_cancel₀ hunit

/-! ## 4. The classification -/

/-- **The classification of Donoho–Stark extremals over an arbitrary finite abelian group
(Conjecture 3 of the previous cycle).** If a nonzero `f : G → ℂ` satisfies
`|supp f| · |supp 𝓖f| = |G|`, then its support is a coset `a₀ + K` of a subgroup `K ≤ G` of order
`|supp f|`, and simultaneously its spectrum is the coset `ψ₀ · H` of the annihilator subgroup
`H = ann K ≤ Ĝ`. -/
theorem extremal_support_and_spectrum_coset {f : G → ℂ} (hf : f ≠ 0)
    (hext : (gsupport f).card * (dsupport (gdft f)).card = Fintype.card G) :
    ∃ (K : Finset G) (H : Finset (AddChar G ℂ)) (a₀ : G) (psi₀ : AddChar G ℂ),
      (0 : G) ∈ K ∧ (∀ x ∈ K, ∀ y ∈ K, x + y ∈ K) ∧
      (1 : AddChar G ℂ) ∈ H ∧ (∀ x ∈ H, ∀ y ∈ H, x * y ∈ H) ∧
      K.card = (gsupport f).card ∧ H.card = (dsupport (gdft f)).card ∧
      gsupport f = K.image (fun x => a₀ + x) ∧
      dsupport (gdft f) = H.image (fun x => psi₀ * x) ∧
      psi₀ ∈ dsupport (gdft f) ∧ a₀ ∈ gsupport f := by
  classical
  obtain ⟨a₀, ha₀⟩ := gsupport_nonempty hf
  obtain ⟨psi₀, hpsi₀⟩ := dsupport_nonempty hf
  set B : Finset G := (gsupport f).image (fun a => a - a₀) with hB
  set C : Finset (AddChar G ℂ) := (dsupport (gdft f)).image (fun psi => psi * psi₀⁻¹) with hC
  set H : Finset (AddChar G ℂ) := annChar B with hH
  set K : Finset G := annGrp H with hK
  have h1H : (1 : AddChar G ℂ) ∈ H := one_mem_annChar B
  have hmulH : ∀ x ∈ H, ∀ y ∈ H, x * y ∈ H := fun x hx y hy => mul_mem_annChar hx hy
  -- orthogonality puts the spectrum quotients in `H`
  have hCH : C ⊆ H := by
    intro chi hchi
    rw [hC, Finset.mem_image] at hchi
    obtain ⟨psi, hpsi, rfl⟩ := hchi
    rw [hH, mem_annChar]
    intro b hb
    rw [hB, Finset.mem_image] at hb
    obtain ⟨a, ha, rfl⟩ := hb
    exact extremal_orthogonality hf hext ha ha₀ hpsi hpsi₀
  -- `B` sits inside the double annihilator `K`
  have hBK : B ⊆ K := by
    intro b hb
    rw [hK, mem_annGrp]
    intro chi hchi
    rw [hH, mem_annChar] at hchi
    exact hchi b hb
  have hcount : K.card * H.card = Fintype.card G := card_annGrp_mul_card h1H hmulH
  have hsB : B.card = (gsupport f).card := by
    rw [hB, Finset.card_image_of_injective _ (fun x y h => by
      simpa using sub_left_injective h)]
  have htC : C.card = (dsupport (gdft f)).card := by
    rw [hC, Finset.card_image_of_injective _ (mul_left_injective psi₀⁻¹)]
  have hsK : B.card ≤ K.card := Finset.card_le_card hBK
  have htH : C.card ≤ H.card := Finset.card_le_card hCH
  have hprod : B.card * C.card = Fintype.card G := by rw [hsB, htC]; exact hext
  have hCpos : 0 < C.card :=
    Finset.card_pos.2 ⟨1, by
      rw [hC, Finset.mem_image]
      exact ⟨psi₀, hpsi₀, mul_inv_cancel psi₀⟩⟩
  have hKpos : 0 < K.card := Finset.card_pos.2 ⟨0, zero_mem_annGrp H⟩
  have hHC : H.card = C.card := by
    have h1 : K.card * H.card ≤ K.card * C.card := by
      calc K.card * H.card = B.card * C.card := hcount.trans hprod.symm
        _ ≤ K.card * C.card := Nat.mul_le_mul_right _ hsK
    have h2 : K.card * C.card ≤ K.card * H.card := Nat.mul_le_mul_left _ htH
    exact Nat.eq_of_mul_eq_mul_left hKpos (le_antisymm h1 h2)
  have hBeqK : B.card = K.card := by
    refine Nat.eq_of_mul_eq_mul_right hCpos ?_
    rw [hprod, ← hHC]
    exact hcount.symm
  have hBK' : B = K := Finset.eq_of_subset_of_card_le hBK (le_of_eq hBeqK.symm)
  have hCH' : C = H := Finset.eq_of_subset_of_card_le hCH (le_of_eq hHC)
  refine ⟨K, H, a₀, psi₀, zero_mem_annGrp H, fun x hx y hy => add_mem_annGrp hx hy,
    h1H, hmulH, by rw [← hBeqK, hsB], by rw [← hCH', htC], ?_, ?_, hpsi₀, ha₀⟩
  · ext a
    simp only [Finset.mem_image]
    constructor
    · intro ha
      refine ⟨a - a₀, ?_, by abel⟩
      rw [← hBK', hB, Finset.mem_image]
      exact ⟨a, ha, rfl⟩
    · rintro ⟨x, hx, rfl⟩
      rw [← hBK', hB, Finset.mem_image] at hx
      obtain ⟨a, ha, rfl⟩ := hx
      simpa using ha
  · ext psi
    simp only [Finset.mem_image]
    constructor
    · intro hpsi
      refine ⟨psi * psi₀⁻¹, ?_, by rw [mul_comm psi psi₀⁻¹, mul_inv_cancel_left]⟩
      rw [← hCH', hC, Finset.mem_image]
      exact ⟨psi, hpsi, rfl⟩
    · rintro ⟨chi, hchi, rfl⟩
      rw [← hCH', hC, Finset.mem_image] at hchi
      obtain ⟨psi, hpsi, rfl⟩ := hchi
      have : psi₀ * (psi * psi₀⁻¹) = psi := by
        rw [mul_comm psi psi₀⁻¹, mul_inv_cancel_left]
      rwa [this]

/-- **The support of an extremal is a coset**, over any finite abelian group. -/
theorem extremal_support_coset {f : G → ℂ} (hf : f ≠ 0)
    (hext : (gsupport f).card * (dsupport (gdft f)).card = Fintype.card G) :
    ∃ (K : Finset G) (a₀ : G), (0 : G) ∈ K ∧ (∀ x ∈ K, ∀ y ∈ K, x + y ∈ K) ∧
      K.card = (gsupport f).card ∧ gsupport f = K.image (fun x => a₀ + x) := by
  obtain ⟨K, -, a₀, -, h0, hadd, -, -, hcard, -, himg, -, -, -⟩ :=
    extremal_support_and_spectrum_coset hf hext
  exact ⟨K, a₀, h0, hadd, hcard, himg⟩

/-- **The spectrum of an extremal is a coset of a subgroup of the dual group.** -/
theorem extremal_spectrum_coset {f : G → ℂ} (hf : f ≠ 0)
    (hext : (gsupport f).card * (dsupport (gdft f)).card = Fintype.card G) :
    ∃ (H : Finset (AddChar G ℂ)) (psi₀ : AddChar G ℂ),
      (1 : AddChar G ℂ) ∈ H ∧ (∀ x ∈ H, ∀ y ∈ H, x * y ∈ H) ∧
        H.card = (dsupport (gdft f)).card ∧
        dsupport (gdft f) = H.image (fun x => psi₀ * x) := by
  obtain ⟨-, H, -, psi₀, -, -, h1, hmul, -, hcard, -, himg, -, -⟩ :=
    extremal_support_and_spectrum_coset hf hext
  exact ⟨H, psi₀, h1, hmul, hcard, himg⟩

/-- **The full classification.** An extremal is a nonzero constant times a character times the
indicator of a coset of a subgroup of `G` whose order is the size of the support. -/
theorem extremal_eq_modulated_coset_indicator {f : G → ℂ} (hf : f ≠ 0)
    (hext : (gsupport f).card * (dsupport (gdft f)).card = Fintype.card G) :
    ∃ (K : Finset G) (a₀ : G) (psi₀ : AddChar G ℂ) (c : ℂ),
      c ≠ 0 ∧ (0 : G) ∈ K ∧ (∀ x ∈ K, ∀ y ∈ K, x + y ∈ K) ∧
        K.card = (gsupport f).card ∧
        ∀ a, f a = if a - a₀ ∈ K then c * psi₀ a else 0 := by
  classical
  obtain ⟨K, -, a₀, psi₀, h0K, haddK, -, -, hcard, -, himg, -, hpsi₀, ha₀⟩ :=
    extremal_support_and_spectrum_coset hf hext
  have hmem : ∀ a, a ∈ gsupport f ↔ a - a₀ ∈ K := by
    intro a
    rw [himg, Finset.mem_image]
    constructor
    · rintro ⟨x, hx, rfl⟩
      simpa using hx
    · intro h
      exact ⟨a - a₀, h, by abel⟩
  have hpsi₀ne : psi₀ a₀ ≠ 0 := by
    intro h
    have h1 : ‖psi₀ a₀‖ = 1 := AddChar.norm_apply _ _
    rw [h] at h1
    simp at h1
  refine ⟨K, a₀, psi₀, f a₀ / psi₀ a₀, div_ne_zero (mem_gsupport.1 ha₀) hpsi₀ne,
    h0K, haddK, hcard, ?_⟩
  intro a
  by_cases ha : a - a₀ ∈ K
  · rw [if_pos ha]
    have has : a ∈ gsupport f := (hmem a).2 ha
    have hchar := extremal_char_on_support hf hext has ha₀ hpsi₀
    have hsplit : psi₀ (a - a₀) = psi₀ a / psi₀ a₀ := AddChar.map_sub_eq_div psi₀ a a₀
    rw [hchar, hsplit]
    field_simp
  · rw [if_neg ha]
    by_contra hne
    exact ha ((hmem a).1 (mem_gsupport.2 hne))

omit [DecidableEq G] in
/-- The support size of an extremal divides `|G|`. -/
theorem card_gsupport_dvd_of_extremal {f : G → ℂ}
    (hext : (gsupport f).card * (dsupport (gdft f)).card = Fintype.card G) :
    (gsupport f).card ∣ Fintype.card G := ⟨_, hext.symm⟩

/-! ## 5. The converse: every modulated coset indicator is an extremal -/

omit [Fintype G] [DecidableEq G] in
/-- A nonempty finite subset of a finite abelian group that is closed under addition is closed
under negation, hence is a subgroup. -/
theorem neg_mem_of_add_closed {K : Finset G} (h0 : (0 : G) ∈ K)
    (hadd : ∀ x ∈ K, ∀ y ∈ K, x + y ∈ K) {x : G} (hx : x ∈ K) : -x ∈ K := by
  classical
  have himg : K.image (fun y => x + y) = K := by
    refine Finset.eq_of_subset_of_card_le ?_ ?_
    · intro z hz
      simp only [Finset.mem_image] at hz
      obtain ⟨y, hy, rfl⟩ := hz
      exact hadd x hx y hy
    · rw [Finset.card_image_of_injective _ (add_right_injective x)]
  have : (0 : G) ∈ K.image (fun y => x + y) := by rw [himg]; exact h0
  simp only [Finset.mem_image] at this
  obtain ⟨y, hy, hxy⟩ := this
  have : y = -x := by
    have := hxy
    linear_combination (norm := abel) this
  rwa [← this]

/-- The character sum over a subgroup of `G`: the order of the subgroup on its annihilator, and
zero elsewhere. This is the mirror image of `sum_subgroup_apply`. -/
theorem sum_char_over_subgroup {K : Finset G} (hadd : ∀ x ∈ K, ∀ y ∈ K, x + y ∈ K)
    (psi : AddChar G ℂ) :
    ∑ a ∈ K, psi a = if psi ∈ annChar K then (K.card : ℂ) else 0 := by
  classical
  by_cases hpsi : psi ∈ annChar K
  · simp only [hpsi, if_true]
    rw [mem_annChar] at hpsi
    rw [Finset.sum_congr rfl fun a ha => hpsi a ha]
    simp
  · simp only [hpsi, if_false]
    rw [mem_annChar] at hpsi
    push_neg at hpsi
    obtain ⟨a₀, ha₀, hne⟩ := hpsi
    have himg : K.image (fun a => a + a₀) = K := by
      refine Finset.eq_of_subset_of_card_le ?_ ?_
      · intro z hz
        simp only [Finset.mem_image] at hz
        obtain ⟨a, ha, rfl⟩ := hz
        exact hadd a ha a₀ ha₀
      · rw [Finset.card_image_of_injective _ (add_left_injective a₀)]
    have hshift : ∑ a ∈ K, psi a = psi a₀ * ∑ a ∈ K, psi a := by
      conv_lhs => rw [← himg]
      rw [Finset.sum_image fun a _ b _ hab => add_left_injective a₀ hab, Finset.mul_sum]
      exact Finset.sum_congr rfl fun a _ => by rw [AddChar.map_add_eq_mul, mul_comm]
    have hzero : (1 - psi a₀) * ∑ a ∈ K, psi a = 0 := by
      rw [sub_mul, one_mul, ← hshift, sub_self]
    rcases mul_eq_zero.1 hzero with hz | hz
    · exact absurd (by linear_combination -hz : psi a₀ = 1) hne
    · exact hz

/-- **Duality counting, group side.** A subgroup of `G` and its annihilator in the dual group
have orders multiplying to `|G|`. -/
theorem card_annChar_mul_card {K : Finset G} (h0 : (0 : G) ∈ K)
    (hadd : ∀ x ∈ K, ∀ y ∈ K, x + y ∈ K) :
    (annChar K).card * K.card = Fintype.card G := by
  classical
  have key : ((annChar K).card * K.card : ℂ) = (Fintype.card G : ℂ) := by
    have hswap : ∑ psi : AddChar G ℂ, ∑ a ∈ K, psi a = ∑ a ∈ K, ∑ psi : AddChar G ℂ, psi a :=
      Finset.sum_comm
    have hleft : ∑ psi : AddChar G ℂ, ∑ a ∈ K, psi a = ((annChar K).card * K.card : ℂ) := by
      rw [Finset.sum_congr rfl fun psi _ => sum_char_over_subgroup hadd psi, Finset.sum_ite_mem]
      simp [Finset.univ_inter, Finset.sum_const, nsmul_eq_mul]
    have hright : ∑ a ∈ K, ∑ psi : AddChar G ℂ, psi a = (Fintype.card G : ℂ) := by
      rw [Finset.sum_congr rfl fun a _ => AddChar.sum_apply_eq_ite a,
        Finset.sum_ite_eq' K (0 : G) (fun _ => (Fintype.card G : ℂ)), if_pos h0]
    rw [← hleft, hswap, hright]
  exact_mod_cast key

open scoped Classical in
/-- A modulated coset indicator: `c` times the character `ψ₀` on the coset `a₀ + K`, and zero
outside it. By `extremal_eq_modulated_coset_indicator` every Donoho–Stark extremal has this
form. -/
noncomputable def modCosetIndicator (K : Finset G) (a₀ : G) (psi₀ : AddChar G ℂ) (c : ℂ) :
    G → ℂ := fun a => if a - a₀ ∈ K then c * psi₀ a else 0

theorem gsupport_modCosetIndicator {K : Finset G} {a₀ : G} {psi₀ : AddChar G ℂ} {c : ℂ}
    (hc : c ≠ 0) : gsupport (modCosetIndicator K a₀ psi₀ c) = K.image (fun x => a₀ + x) := by
  classical
  have hpsi₀ : ∀ a : G, psi₀ a ≠ 0 := by
    intro a h
    have h1 : ‖psi₀ a‖ = 1 := AddChar.norm_apply _ _
    rw [h] at h1
    simp at h1
  ext a
  simp only [mem_gsupport, modCosetIndicator, Finset.mem_image]
  constructor
  · intro h
    by_cases ha : a - a₀ ∈ K
    · exact ⟨a - a₀, ha, by abel⟩
    · rw [if_neg ha] at h; exact absurd rfl h
  · rintro ⟨x, hx, rfl⟩
    have : a₀ + x - a₀ ∈ K := by simpa using hx
    rw [if_pos this]
    exact mul_ne_zero hc (hpsi₀ _)

/-- The Fourier transform of a modulated coset indicator is a character sum over the subgroup. -/
theorem gdft_modCosetIndicator {K : Finset G} (hadd : ∀ x ∈ K, ∀ y ∈ K, x + y ∈ K)
    {a₀ : G} {psi₀ : AddChar G ℂ} {c : ℂ} (hc : c ≠ 0) (psi : AddChar G ℂ) :
    gdft (modCosetIndicator K a₀ psi₀ c) psi
      = (c * psi₀ a₀ * psi (-a₀)) *
          (if psi₀ * psi⁻¹ ∈ annChar K then (K.card : ℂ) else 0) := by
  classical
  rw [gdft_sum_gsupport, gsupport_modCosetIndicator hc,
    Finset.sum_image fun a _ b _ hab => add_right_injective a₀ hab]
  have hterm : ∀ k ∈ K, psi (-(a₀ + k)) * modCosetIndicator K a₀ psi₀ c (a₀ + k)
      = (c * psi₀ a₀ * psi (-a₀)) * (psi₀ * psi⁻¹) k := by
    intro k hk
    have hmem : a₀ + k - a₀ ∈ K := by simpa using hk
    have hsplit : psi (-(a₀ + k)) = psi (-a₀) * psi (-k) := by
      rw [← AddChar.map_add_eq_mul]; congr 1; abel
    rw [modCosetIndicator, if_pos hmem, hsplit, AddChar.map_add_eq_mul,
      AddChar.mul_apply, AddChar.inv_apply]
    ring
  rw [Finset.sum_congr rfl hterm, ← Finset.mul_sum, sum_char_over_subgroup hadd]

/-- **The converse of the classification.** Every modulated coset indicator (with a nonzero
constant, over a subgroup `K`) is a Donoho–Stark extremal. Together with
`extremal_eq_modulated_coset_indicator` this characterises the equality case exactly, over every
finite abelian group. -/
theorem modCosetIndicator_extremal {K : Finset G} (h0 : (0 : G) ∈ K)
    (hadd : ∀ x ∈ K, ∀ y ∈ K, x + y ∈ K) (a₀ : G) (psi₀ : AddChar G ℂ) {c : ℂ} (hc : c ≠ 0) :
    (gsupport (modCosetIndicator K a₀ psi₀ c)).card *
        (dsupport (gdft (modCosetIndicator K a₀ psi₀ c))).card = Fintype.card G := by
  classical
  have hKpos : (K.card : ℂ) ≠ 0 := by
    have : 0 < K.card := Finset.card_pos.2 ⟨0, h0⟩
    exact_mod_cast this.ne'
  have hunit : ∀ (chi : AddChar G ℂ) (a : G), chi a ≠ 0 := by
    intro chi a h
    have h1 : ‖chi a‖ = 1 := AddChar.norm_apply _ _
    rw [h] at h1
    simp at h1
  -- the support is the coset, of size `|K|`
  have hs : (gsupport (modCosetIndicator K a₀ psi₀ c)).card = K.card := by
    rw [gsupport_modCosetIndicator hc, Finset.card_image_of_injective _ (add_right_injective a₀)]
  -- the spectrum is the coset `ψ₀ · (ann K)⁻¹`, of size `|ann K|`
  have hspec : dsupport (gdft (modCosetIndicator K a₀ psi₀ c))
      = (annChar K).image (fun chi => psi₀ * chi⁻¹) := by
    ext psi
    rw [mem_dsupport, gdft_modCosetIndicator hadd hc]
    simp only [Finset.mem_image]
    constructor
    · intro h
      by_cases hmem : psi₀ * psi⁻¹ ∈ annChar K
      · refine ⟨psi₀ * psi⁻¹, hmem, ?_⟩
        rw [mul_inv, inv_inv, ← mul_assoc, mul_comm psi₀ psi₀⁻¹, inv_mul_cancel, one_mul]
      · rw [if_neg hmem, mul_zero] at h
        exact absurd rfl h
    · rintro ⟨chi, hchi, rfl⟩
      have hmem : psi₀ * (psi₀ * chi⁻¹)⁻¹ ∈ annChar K := by
        have : psi₀ * (psi₀ * chi⁻¹)⁻¹ = chi := by
          rw [mul_inv, inv_inv, ← mul_assoc, mul_comm psi₀ psi₀⁻¹, inv_mul_cancel, one_mul]
        rwa [this]
      rw [if_pos hmem]
      exact mul_ne_zero (mul_ne_zero (mul_ne_zero hc (hunit _ _)) (hunit _ _)) hKpos
  have ht : (dsupport (gdft (modCosetIndicator K a₀ psi₀ c))).card = (annChar K).card := by
    rw [hspec, Finset.card_image_of_injective]
    intro x y hxy
    have : x⁻¹ = y⁻¹ := mul_left_cancel hxy
    simpa using this
  rw [hs, ht, Nat.mul_comm]
  exact card_annChar_mul_card h0 hadd

/-- **Exact characterisation of the equality case, over every finite abelian group.** A nonzero
`f : G → ℂ` is a Donoho–Stark extremal if and only if it is a modulated coset indicator. -/
theorem extremal_iff_modCosetIndicator {f : G → ℂ} (hf : f ≠ 0) :
    (gsupport f).card * (dsupport (gdft f)).card = Fintype.card G ↔
      ∃ (K : Finset G) (a₀ : G) (psi₀ : AddChar G ℂ) (c : ℂ),
        c ≠ 0 ∧ (0 : G) ∈ K ∧ (∀ x ∈ K, ∀ y ∈ K, x + y ∈ K) ∧
          f = modCosetIndicator K a₀ psi₀ c := by
  classical
  constructor
  · intro hext
    obtain ⟨K, a₀, psi₀, c, hc, h0, hadd, -, hval⟩ :=
      extremal_eq_modulated_coset_indicator hf hext
    exact ⟨K, a₀, psi₀, c, hc, h0, hadd, funext hval⟩
  · rintro ⟨K, a₀, psi₀, c, hc, h0, hadd, rfl⟩
    exact modCosetIndicator_extremal h0 hadd a₀ psi₀ hc

/-- **The sharpest form of the uncertainty principle available here.** A nonzero function that is
not a modulated coset indicator satisfies the *strict* inequality
`|G| < |supp f| · |supp 𝓖f|`. -/
theorem uncertainty_strict_of_not_modCosetIndicator {f : G → ℂ} (hf : f ≠ 0)
    (hnot : ¬ ∃ (K : Finset G) (a₀ : G) (psi₀ : AddChar G ℂ) (c : ℂ),
      c ≠ 0 ∧ (0 : G) ∈ K ∧ (∀ x ∈ K, ∀ y ∈ K, x + y ∈ K) ∧
        f = modCosetIndicator K a₀ psi₀ c) :
    Fintype.card G < (gsupport f).card * (dsupport (gdft f)).card :=
  lt_of_le_of_ne (donoho_stark_finite_abelian f hf) fun hEq =>
    hnot ((extremal_iff_modCosetIndicator hf).1 hEq.symm)

/-! ## 6. A concrete instance: the subgroup `{0, 3}` of `ZMod 6` -/

/-- Non-vacuity of the classification: `{0, 3} ≤ ZMod 6` is a subgroup, so the indicator of any
of its cosets, modulated by any character, is a Donoho–Stark extremal — the support has two
elements and the spectrum has three. -/
theorem zmod_six_extremal (a₀ : ZMod 6) (psi₀ : AddChar (ZMod 6) ℂ) {c : ℂ} (hc : c ≠ 0) :
    (gsupport (modCosetIndicator ({0, 3} : Finset (ZMod 6)) a₀ psi₀ c)).card *
        (dsupport (gdft (modCosetIndicator ({0, 3} : Finset (ZMod 6)) a₀ psi₀ c))).card = 6 := by
  have h0 : (0 : ZMod 6) ∈ ({0, 3} : Finset (ZMod 6)) := by decide
  have hadd : ∀ x ∈ ({0, 3} : Finset (ZMod 6)), ∀ y ∈ ({0, 3} : Finset (ZMod 6)),
      x + y ∈ ({0, 3} : Finset (ZMod 6)) := by decide
  have := modCosetIndicator_extremal h0 hadd a₀ psi₀ hc
  simpa using this

/-! ## 7. The annihilator Galois connection is an anti-isomorphism of subgroup lattices -/

/-- Annihilation reverses inclusions, on the group side. -/
theorem annChar_antitone {K K' : Finset G} (h : K ⊆ K') : annChar K' ⊆ annChar K := by
  intro psi hpsi
  rw [mem_annChar] at *
  exact fun b hb => hpsi b (h hb)

omit [DecidableEq G] in
/-- Annihilation reverses inclusions, on the dual side. -/
theorem annGrp_antitone {H H' : Finset (AddChar G ℂ)} (h : H ⊆ H') :
    annGrp H' ⊆ annGrp H := by
  intro x hx
  rw [mem_annGrp] at *
  exact fun psi hpsi => hx psi (h hpsi)

/-- A subgroup is contained in its double annihilator. -/
theorem subset_annGrp_annChar (K : Finset G) : K ⊆ annGrp (annChar K) := by
  intro x hx
  rw [mem_annGrp]
  intro psi hpsi
  exact (mem_annChar.1 hpsi) x hx

/-- A subgroup of the dual group is contained in its double annihilator. -/
theorem subset_annChar_annGrp (H : Finset (AddChar G ℂ)) : H ⊆ annChar (annGrp H) := by
  intro psi hpsi
  rw [mem_annChar]
  intro x hx
  exact (mem_annGrp.1 hx) psi hpsi

/-- **The double annihilator theorem, group side.** For a subgroup `K ≤ G` the double
annihilator is `K` itself. This is finite Pontryagin duality for subgroups, obtained by putting
the two counting theorems together. -/
theorem annGrp_annChar_eq {K : Finset G} (h0 : (0 : G) ∈ K)
    (hadd : ∀ x ∈ K, ∀ y ∈ K, x + y ∈ K) : annGrp (annChar K) = K := by
  classical
  have hcount₁ : (annChar K).card * K.card = Fintype.card G := card_annChar_mul_card h0 hadd
  have hcount₂ : (annGrp (annChar K)).card * (annChar K).card = Fintype.card G :=
    card_annGrp_mul_card (one_mem_annChar K) (fun a ha b hb => mul_mem_annChar ha hb)
  have hpos : 0 < (annChar K).card := Finset.card_pos.2 ⟨1, one_mem_annChar K⟩
  have hcard : (annGrp (annChar K)).card = K.card := by
    have : (annChar K).card * (annGrp (annChar K)).card = (annChar K).card * K.card := by
      rw [Nat.mul_comm (annChar K).card (annGrp (annChar K)).card, hcount₂, hcount₁]
    exact Nat.eq_of_mul_eq_mul_left hpos this
  exact (Finset.eq_of_subset_of_card_le (subset_annGrp_annChar K) (le_of_eq hcard)).symm

/-- **The double annihilator theorem, dual side.** -/
theorem annChar_annGrp_eq {H : Finset (AddChar G ℂ)} (h1 : (1 : AddChar G ℂ) ∈ H)
    (hmul : ∀ a ∈ H, ∀ b ∈ H, a * b ∈ H) : annChar (annGrp H) = H := by
  classical
  have hcount₁ : (annGrp H).card * H.card = Fintype.card G := card_annGrp_mul_card h1 hmul
  have hcount₂ : (annChar (annGrp H)).card * (annGrp H).card = Fintype.card G :=
    card_annChar_mul_card (zero_mem_annGrp H) (fun x hx y hy => add_mem_annGrp hx hy)
  have hpos : 0 < (annGrp H).card := Finset.card_pos.2 ⟨0, zero_mem_annGrp H⟩
  have hcard : (annChar (annGrp H)).card = H.card := by
    have : (annGrp H).card * (annChar (annGrp H)).card = (annGrp H).card * H.card := by
      rw [Nat.mul_comm (annGrp H).card (annChar (annGrp H)).card, hcount₂, hcount₁]
    exact Nat.eq_of_mul_eq_mul_left hpos this
  exact (Finset.eq_of_subset_of_card_le (subset_annChar_annGrp H) (le_of_eq hcard)).symm

/-- **Annihilation is an inclusion-reversing bijection between the subgroups of `G` and the
subgroups of its dual group**, with `|K| · |ann K| = |G|`. This is the lattice anti-isomorphism
underlying the classification of the extremals. -/
theorem annihilator_antiIso {K K' : Finset G} (h0 : (0 : G) ∈ K)
    (hadd : ∀ x ∈ K, ∀ y ∈ K, x + y ∈ K) (h0' : (0 : G) ∈ K')
    (hadd' : ∀ x ∈ K', ∀ y ∈ K', x + y ∈ K') :
    ((1 : AddChar G ℂ) ∈ annChar K ∧ (∀ a ∈ annChar K, ∀ b ∈ annChar K, a * b ∈ annChar K)) ∧
      annGrp (annChar K) = K ∧
      (annChar K).card * K.card = Fintype.card G ∧
      (K ⊆ K' ↔ annChar K' ⊆ annChar K) := by
  refine ⟨⟨one_mem_annChar K, fun a ha b hb => mul_mem_annChar ha hb⟩,
    annGrp_annChar_eq h0 hadd, card_annChar_mul_card h0 hadd, ?_, ?_⟩
  · exact annChar_antitone
  · intro h
    have := annGrp_antitone h
    rwa [annGrp_annChar_eq h0 hadd, annGrp_annChar_eq h0' hadd'] at this

/-- **The additive uncertainty functional of an extremal is a subgroup-order sum.** For an
extremal over any finite abelian group, `|supp f| + |supp 𝓖f| = d + |G|/d` where `d` is the order
of a subgroup of `G`. -/
theorem extremal_additive_subgroup_order {f : G → ℂ} (hf : f ≠ 0)
    (hext : (gsupport f).card * (dsupport (gdft f)).card = Fintype.card G) :
    ∃ K : Finset G, (0 : G) ∈ K ∧ (∀ x ∈ K, ∀ y ∈ K, x + y ∈ K) ∧
      (gsupport f).card + (dsupport (gdft f)).card = K.card + Fintype.card G / K.card := by
  classical
  obtain ⟨K, -, h0, hadd, hcard, -⟩ := extremal_support_coset hf hext
  refine ⟨K, h0, hadd, ?_⟩
  have hpos : 0 < K.card := Finset.card_pos.2 ⟨0, h0⟩
  have hdiv : Fintype.card G / K.card = (dsupport (gdft f)).card := by
    refine Nat.div_eq_of_eq_mul_left hpos ?_
    rw [hcard]
    exact hext.symm.trans (Nat.mul_comm _ _)
  rw [hdiv, hcard]

end AbelianCosetClassification