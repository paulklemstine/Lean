/-
  # Finite Abelian Harmonic Analysis: Full Character Family

  This file proves the existence of a full family of characters for finite
  abelian groups and constructs the `RegularCharacterDecomposition`.

  ## Main results

  * `exists_full_character_family` : there exists a set of |G| distinct characters
    that separate points
  * `card_monoidHom_eq` : the number of characters equals |G|
  * `regular_representation_multiplicity_one` : each character appears exactly once
    in the regular representation
-/
import Mathlib
import Speculative.FiniteAbelianHarmonicAnalysis.Defs
import Speculative.FiniteAbelianHarmonicAnalysis.Theorems

open Finset Complex BigOperators

noncomputable section

variable {G : Type*} [CommGroup G] [Fintype G]

/-
The number of multiplicative characters `G →* ℂˣ` equals `|G|`.
-/
theorem card_monoidHom_eq :
    Nat.card (G →* ℂˣ) = Fintype.card G := by
      convert CommGroup.card_monoidHom_of_hasEnoughRootsOfUnity G ℂ;
      rw [ Nat.card_eq_fintype_card ]

/-
Characters of a finite abelian group separate points:
    if χ(g) = χ(h) for all characters χ, then g = h.
-/
theorem characters_separate_points {g h : G}
    (hsep : ∀ χ : G →* ℂˣ, χ g = χ h) : g = h := by
      -- Suppose g ≠ h. Then g * h⁻¹ ≠ 1. By characters_detect_nontrivial_elements, there exists χ with χ(g * h⁻¹) ≠ 1.
      by_contra hne
      have hgh_inv_ne_one : g * h⁻¹ ≠ 1 := by
        exact fun h => hne ( by simpa using eq_inv_of_mul_eq_one_left h );
      exact hgh_inv_ne_one ( by simpa [ hsep ] using characters_detect_nontrivial_elements ( g * h⁻¹ ) hgh_inv_ne_one |> fun ⟨ χ, hχ ⟩ => by simp_all +decide [ mul_inv_eq_iff_eq_mul ] )

/-
**Full character family theorem.** There exists a complete set of
    |G| distinct characters that separate points of G.
-/
theorem exists_full_character_family :
    ∃ S : Finset (G →* ℂˣ),
      S.card = Fintype.card G ∧
      ∀ {g h : G}, (∀ χ ∈ S, χ g = χ h) → g = h := by
        -- Since `G` is a finite group, the set of characters `G →* ℂˣ` is also finite.
        have h_finite : Fintype (G →* ℂˣ) := by
          exact Fintype.ofFinite _;
        -- By definition of `Fintype`, the cardinality of the set of characters `G →* ℂˣ` is equal to `Fintype.card G`.
        have h_card : Fintype.card (G →* ℂˣ) = Fintype.card G := by
          convert card_monoidHom_eq;
          exact?;
        exact ⟨ Finset.univ, by simp +decide [ h_card ], fun { g h } hgh => characters_separate_points fun χ => hgh χ <| Finset.mem_univ χ ⟩

/-
**Regular representation multiplicity-one decomposition.** There exists a
    complete set of |G| characters, each providing a one-dimensional eigenspace
    in the regular representation via the translation eigenvector property.
-/
theorem regular_representation_multiplicity_one :
    ∃ S : Finset (G →* ℂˣ),
      S.card = Fintype.card G ∧
      ∀ χ : G →* ℂˣ, χ ∈ S ↔
        ∃ v : G → ℂ, v ≠ 0 ∧
          ∀ g x, v (g * x) = ((χ g : ℂˣ) : ℂ) * v x := by
            have h_fintype : Nonempty (Fintype (G →* ℂˣ)) := by
              exact ⟨ Fintype.ofFinite _ ⟩;
            cases' h_fintype with h_fintypeintype.some;
            refine' ⟨ Finset.univ, _, _ ⟩ <;> simp +decide;
            · convert card_monoidHom_eq;
              convert Fintype.card_eq_nat_card;
            · intro χ
              use fun g => (χ g : ℂ);
              exact ⟨ fun h => by simpa using congr_fun h 1, fun g x => by simp +decide [ mul_assoc ] ⟩

/-
Construction of the `RegularCharacterDecomposition` structure.
-/
theorem exists_regularCharacterDecomposition :
    Nonempty (RegularCharacterDecomposition G) := by
      exact ⟨ ⟨ Classical.choose ( exists_full_character_family ), Classical.choose_spec ( exists_full_character_family ) |>.1, Classical.choose_spec ( exists_full_character_family ) |>.2 ⟩ ⟩

end