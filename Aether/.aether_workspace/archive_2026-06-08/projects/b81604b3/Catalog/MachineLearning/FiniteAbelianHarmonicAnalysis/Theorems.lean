/-
  # Finite Abelian Harmonic Analysis: Core Theorems

  This file contains the main theorems establishing the spectral theory
  of the regular representation of finite abelian groups over ℂ.

  ## Main results

  * `charVec_translate` : character vectors are eigenvectors of left translation
  * `convolution_eigenvalue_formula` : convolution acts on character vectors by
    scalar multiplication with the Fourier coefficient as eigenvalue
  * `character_is_convolution_eigenvector` : existential version
  * `characters_detect_nontrivial_elements` : characters separate elements from identity
  * `charVec_orthogonality` : distinct characters give orthogonal vectors
-/
import Mathlib
import Speculative.FiniteAbelianHarmonicAnalysis.Defs

open Finset Complex BigOperators

noncomputable section

variable {G : Type*} [CommGroup G] [Fintype G]

/-! ## Translation eigenvector property -/

/-- Character vectors are eigenvectors of left translation:
    `charVec χ (g * x) = χ(g) * charVec χ x`. This is the fundamental property
    making characters the natural basis for spectral decomposition. -/
theorem charVec_translate (χ : G →* ℂˣ) (g x : G) :
    charVec χ (g * x) = ((χ g : ℂˣ) : ℂ) * charVec χ x := by
  simp [charVec]

/-! ## Convolution eigenvalue formula -/

/-- **Convolution Eigenvalue Formula.** Character vectors are eigenvectors of
    convolution operators, with eigenvalue equal to the Fourier coefficient.
    This is the algebraic heart of spectral filtering on finite abelian groups:
    it says that convolution with any kernel `f` acts on the character vector `χ`
    by multiplication with `∑ y, f(y) · χ(y)⁻¹`. -/
theorem convolution_eigenvalue_formula [DecidableEq G]
    (f : G → ℂ) (χ : G →* ℂˣ) :
    let ev := ∑ y : G, f y * ((χ y : ℂˣ) : ℂ)⁻¹
    ∀ x, convFun G f (charVec χ) x = ev * ((χ x : ℂˣ) : ℂ) := by
  simp +decide [convFun, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, charVec]

/-- Existential form: character vectors are eigenvectors of convolution. -/
theorem character_is_convolution_eigenvector [DecidableEq G]
    (f : G → ℂ) (χ : G →* ℂˣ) :
    ∃ ev : ℂ, ∀ x,
      convFun G f (fun t => ((χ t : ℂˣ) : ℂ)) x
        = ev * ((χ x : ℂˣ) : ℂ) :=
  ⟨_, convolution_eigenvalue_formula f χ⟩

/-! ## Character orthogonality -/

/-- Sum of a nontrivial character over the whole group vanishes.
    This is the fundamental orthogonality relation in finite harmonic analysis. -/
theorem sum_char_eq_zero [DecidableEq G] (χ : G →* ℂˣ) (hχ : χ ≠ 1) :
    ∑ g : G, ((χ g : ℂˣ) : ℂ) = 0 := by
  obtain ⟨g₀, hg₀⟩ : ∃ g₀, ((χ g₀ : ℂˣ) : ℂ) ≠ 1 :=
    not_forall.mp fun h => hχ <| MonoidHom.ext fun g => Units.ext <| h g
  set S : ℂ := ∑ g : G, ((χ g : ℂˣ) : ℂ)
  have h₁ : ((χ g₀ : ℂˣ) : ℂ) * S = ∑ g : G, ((χ (g₀ * g) : ℂˣ) : ℂ) := by
    simp [S, Finset.mul_sum _ _ _]
  exact mul_left_cancel₀ (sub_ne_zero_of_ne hg₀) (by
    rw [show ∑ g : G, (χ (g₀ * g) : ℂ) = S from
      Equiv.sum_comp (Equiv.mulLeft g₀) fun g => (χ g : ℂ)] at h₁
    linear_combination' h₁)

/-
**Orthogonality of distinct characters.**
    If χ ≠ ψ, then `∑ g, χ(g) * conj(ψ(g)) = 0`.
-/
theorem charVec_orthogonality [DecidableEq G] (χ ψ : G →* ℂˣ) (hne : χ ≠ ψ) :
    ∑ g : G, ((χ g : ℂˣ) : ℂ) * starRingEnd ℂ ((ψ g : ℂˣ) : ℂ) = 0 := by
      -- Since ψ is a unit, |ψ(g)| = 1, so conj(ψ(g)) = ψ(g)⁻¹.
      have h_conj : ∀ g : G, (starRingEnd ℂ) ((ψ g : ℂˣ) : ℂ) = ((ψ g : ℂˣ) : ℂ)⁻¹ := by
        intro g
        have h_abs : ‖(ψ g : ℂ)‖ = 1 := by
          have h_abs : ∀ g : G, ‖(ψ g : ℂ)‖ = 1 := by
            intro g
            have h_order : (ψ g : ℂ) ^ Fintype.card G = 1 := by
              norm_cast;
              simp +decide [ ← map_pow, pow_card_eq_one ]
            simpa [ pow_eq_one_iff_of_nonneg ] using congr_arg Norm.norm h_order;
          exact h_abs g;
        simp +decide [ Complex.inv_def, Complex.normSq_eq_norm_sq, h_abs ];
      convert sum_char_eq_zero ( χ * ψ⁻¹ ) _ using 1;
      · simp +decide [ h_conj ];
      · simp_all +decide [ funext_iff, MonoidHom.ext_iff ];
        exact hne.imp fun x hx => by rw [ mul_inv_eq_one ] ; exact hx;

/-! ## Characters detect nontrivial elements -/

/-
**Characters detect nontrivial elements.** For every non-identity element `g`
    of a finite abelian group, there exists a character `χ` with `χ(g) ≠ 1`.
    This is the exact theorem expressing that the regular action's faithfulness
    lifts to a faithful linear character-theoretic probe.
-/
theorem characters_detect_nontrivial_elements
    (g : G) (hg : g ≠ 1) : ∃ χ : G →* ℂˣ, χ g ≠ 1 := by
      convert CommGroup.exists_apply_ne_one_of_hasEnoughRootsOfUnity G ℂ hg using 1

/-! ## Convolution preserves character eigenspaces -/

/-- Translation-equivariant operators preserve each character line:
    if `T` commutes with left translation, then `T(charVec χ)` is proportional
    to `charVec χ`. -/
theorem translation_equivariant_preserves_charVec [DecidableEq G]
    (T : (G → ℂ) → (G → ℂ)) (hT : IsTranslationEquivariant T)
    (hlin : ∀ (c : ℂ) (v : G → ℂ), T (fun x => c * v x) = fun x => c * T v x)
    (χ : G →* ℂˣ) :
    ∃ ev : ℂ, ∀ x, T (charVec χ) x = ev * charVec χ x := by
  use T (charVec χ) 1
  intro x
  have := hT x (charVec χ) 1
  simp_all +decide [charVec_translate]
  exact this.symm.trans (mul_comm _ _)

/-! ## Character self-inner-product -/

/-
The self-inner-product of any character equals |G|.
-/
theorem charVec_self_inner_product (χ : G →* ℂˣ) :
    ∑ g : G, ((χ g : ℂˣ) : ℂ) * starRingEnd ℂ ((χ g : ℂˣ) : ℂ) =
      (Fintype.card G : ℂ) := by
        -- Since χ is a character, χ(g) is a root of unity, so its norm is 1.
        have h_norm : ∀ g : G, Complex.normSq ((χ g : ℂˣ) : ℂ) = 1 := by
          intro g
          have h_abs : Complex.normSq ((χ g : ℂˣ) : ℂ) = 1 := by
            have h_order : (χ g : ℂˣ) ^ (Fintype.card G) = 1 := by
              rw [ ← map_pow, pow_card_eq_one, map_one ]
            replace h_order := congr_arg ( fun x : ℂˣ => ( x : ℂ ) ) h_order ; simp_all +decide [ pow_eq_one_iff_of_nonneg ];
            replace h_order := congr_arg Complex.normSq h_order ; simp_all +decide [ Complex.normSq_eq_norm_sq ];
            exact Or.imp ( fun h => by rw [ pow_eq_one_iff_of_nonneg ( norm_nonneg _ ) ] at h <;> aesop ) ( fun h => by linarith [ pow_nonneg ( norm_nonneg ( χ g : ℂ ) ) ( Fintype.card G ) ] ) h_order;
          exact h_abs;
        simp_all +decide [ Complex.mul_conj, Complex.normSq_eq_norm_sq ];
        exact Eq.symm ( by rw [ Finset.sum_congr rfl fun x _ => by rw [ show ‖ ( χ x : ℂ )‖ = 1 by cases h_norm x <;> linarith [ norm_nonneg ( χ x : ℂ ) ] ] ] ; simp +decide )

end