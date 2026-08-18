/-
# Flatness on both sides does **not** imply extremality

The rigidity proof in `Catalog.Novelty.FourierUncertaintyRigidity` shows that an extremal
function for the Donoho–Stark uncertainty principle satisfies two "flatness" conditions:

* `|f|` is constant on `supp f` (`FourierFA.IsExtremal.norm_eq_of_mem_supp`), and
* `|f̂|` is constant on `supp f̂` (`FourierFA.IsExtremal.norm_dft_const`).

It is tempting to conjecture that these two conditions *characterise* extremality.  This file
refutes that conjecture, in every nontrivial case, by an explicit construction:

on the self-dual group `G = K × K̂` put `f (x, ψ) = ψ x` (the "evaluation pairing", a discrete
analogue of the Gauss kernel `e^{ixξ}`).  Then

* `|f| ≡ 1` on all of `G` (`FourierFA.pairingFn_norm`),
* `|f̂| ≡ |K|` on all of `Ĝ` (`FourierFA.norm_dft_pairingFn`), so both flatness conditions hold
  in the strongest possible form,
* yet `|supp f| · |supp f̂| = |G|²`, so `f` is as far from extremal as possible
  (`FourierFA.pairingFn_not_isExtremal`).

The moral, recorded in `FourierFA.biflat_not_sufficient`: the equality analysis really needs the
*coupling* between the phases at different spectral characters, not merely the two modulus
conditions separately.  This is what the phase subgroup in the rigidity proof encodes.
-/

import Mathlib
import Catalog.Shared.FourierFiniteAbelian
import Catalog.Novelty.FourierUncertaintyRigidity

open Finset Fintype ComplexConjugate

namespace FourierFA

variable (K : Type*) [AddCommGroup K] [Fintype K] [DecidableEq K]

/-- The evaluation pairing on the self-dual group `K × K̂`, `f (x, ψ) = ψ x`. -/
def pairingFn : K × AddChar K ℂ → ℂ := fun p => p.2 p.1

variable {K}

omit [Fintype K] [DecidableEq K] in
@[simp] lemma pairingFn_apply (x : K) (ψ : AddChar K ℂ) : pairingFn K (x, ψ) = ψ x := rfl

omit [DecidableEq K] in
/-- The pairing function is unimodular: `|f| ≡ 1`. -/
lemma pairingFn_norm (p : K × AddChar K ℂ) : ‖pairingFn K p‖ = 1 :=
  AddChar.norm_apply _ _

omit [DecidableEq K] in
lemma pairingFn_ne_zero (p : K × AddChar K ℂ) : pairingFn K p ≠ 0 := by
  intro h
  have hn := pairingFn_norm p
  rw [h] at hn
  simp at hn

/-- **The Fourier transform of the pairing function is again unimodular (up to the factor
`|K|`)**: `f̂ (χ) = |K| · conj (χ (z, 0))` where `z` is the point of `K` representing the
restriction of `χ` to the dual factor under Pontryagin duality. -/
theorem norm_dft_pairingFn (χ : AddChar (K × AddChar K ℂ) ℂ) :
    ‖dft (pairingFn K) χ‖ = (Fintype.card K : ℝ) := by
  classical
  -- restrict `χ` to the second factor and use Pontryagin duality
  set χ₂ : AddChar (AddChar K ℂ) ℂ :=
    χ.compAddMonoidHom (AddMonoidHom.inr K (AddChar K ℂ)) with hχ₂
  obtain ⟨z, hz⟩ := AddChar.doubleDualEmb_bijective.surjective χ₂
  have hzval : ∀ ψ : AddChar K ℂ, χ (0, ψ) = ψ z := by
    intro ψ
    have h1 : χ₂ ψ = χ (0, ψ) := rfl
    rw [← h1, ← hz]
    rfl
  have hsplit : ∀ (x : K) (ψ : AddChar K ℂ), χ (x, ψ) = χ (x, 0) * ψ z := by
    intro x ψ
    have h : χ (x, ψ) = χ (x, 0) * χ (0, ψ) := by
      rw [← AddChar.map_add_eq_mul]
      norm_num
    rw [h, hzval]
  -- compute the transform
  have hval : dft (pairingFn K) χ = (Fintype.card K : ℂ) * conj (χ (z, 0)) := by
    rw [dft, Fintype.sum_prod_type]
    have hinner : ∀ x : K, ∑ ψ : AddChar K ℂ, conj (χ (x, ψ)) * pairingFn K (x, ψ)
        = conj (χ (x, 0)) * (if x = z then (Fintype.card K : ℂ) else 0) := by
      intro x
      have hstep : ∀ ψ : AddChar K ℂ, conj (χ (x, ψ)) * pairingFn K (x, ψ)
          = conj (χ (x, 0)) * (ψ x * conj (ψ z)) := by
        intro ψ
        rw [pairingFn_apply, hsplit x ψ, map_mul]
        ring
      simp_rw [hstep]
      rw [← Finset.mul_sum, sum_char_sub]
    simp_rw [hinner]
    rw [Finset.sum_eq_single z]
    · simp [mul_comm]
    · intro x _ hx
      simp [hx]
    · intro h
      exact absurd (Finset.mem_univ z) h
  have hnorm : ‖conj (χ (z, 0))‖ = 1 := by
    rw [RCLike.norm_conj]
    exact AddChar.norm_apply _ _
  rw [hval, norm_mul, hnorm, mul_one, Complex.norm_natCast]

lemma dft_pairingFn_ne_zero (hK : 0 < Fintype.card K) (χ : AddChar (K × AddChar K ℂ) ℂ) :
    dft (pairingFn K) χ ≠ 0 := by
  intro h
  have hn := norm_dft_pairingFn χ
  rw [h, norm_zero] at hn
  have : (0 : ℝ) < (Fintype.card K : ℝ) := by exact_mod_cast hK
  linarith [hn ▸ this]

omit [DecidableEq K] in
/-- Both supports are everything, so the uncertainty product is `|G|²`. -/
theorem supp_pairingFn : supp (pairingFn K) = (Finset.univ : Finset (K × AddChar K ℂ)) := by
  ext p
  simp [mem_supp, pairingFn_ne_zero p]

theorem supp_dft_pairingFn :
    supp (dft (pairingFn K)) = (Finset.univ : Finset (AddChar (K × AddChar K ℂ) ℂ)) := by
  ext χ
  have hK : 0 < Fintype.card K := Fintype.card_pos
  simp [mem_supp, dft_pairingFn_ne_zero hK χ]

/-- **The pairing function is not extremal** as soon as `K` is nontrivial, even though it is
flat and has a flat Fourier transform. -/
theorem pairingFn_not_isExtremal (hK : 1 < Fintype.card K) : ¬ IsExtremal (pairingFn K) := by
  classical
  intro hext
  rw [IsExtremal, supp_pairingFn, supp_dft_pairingFn, Finset.card_univ, Finset.card_univ,
    AddChar.card_eq] at hext
  have hcardG : 1 < Fintype.card (K × AddChar K ℂ) := by
    rw [Fintype.card_prod, AddChar.card_eq]
    nlinarith
  nlinarith [hext, hcardG]

/-- **Adversarial conclusion.**  For every nontrivial finite abelian group `K` there is a
function on `G = K × K̂` whose modulus is constant on its (full) support and whose Fourier
transform has constant modulus on its (full) support, but which is *not* extremal for the
Donoho–Stark uncertainty principle.  Hence the two flatness conditions extracted from the
rigidity proof are jointly insufficient: they do not characterise extremality. -/
theorem biflat_not_sufficient (hK : 1 < Fintype.card K) :
    ∃ f : K × AddChar K ℂ → ℂ,
      (∀ p, ‖f p‖ = 1) ∧
      (∀ χ : AddChar (K × AddChar K ℂ) ℂ, ‖dft f χ‖ = (Fintype.card K : ℝ)) ∧
      ¬ IsExtremal f :=
  ⟨pairingFn K, pairingFn_norm, norm_dft_pairingFn, pairingFn_not_isExtremal hK⟩

/-- A concrete instance of the counterexample, witnessing that the hypothesis `1 < |K|` is
satisfiable: on `ℤ/2 × (ℤ/2)^` the pairing function is bi-flat but not extremal. -/
theorem pairingFn_zmod_two_not_isExtremal : ¬ IsExtremal (pairingFn (ZMod 2)) := by
  refine pairingFn_not_isExtremal ?_
  simp

end FourierFA