/-
  Mathematics of Science Fiction — Chapter 12: The Grandfather Paradox and Diagonal Arguments
  Cantor's theorem, Russell's paradox, Lawvere's fixed point theorem.
  Author: Paul Klemstine | Soli Deo Gloria
-/
import Mathlib

open Function Set

/-! ## Cantor's Diagonal Theorem

  For any set A, there is no surjection f : A → 𝒫(A).
  This is structurally identical to the grandfather paradox. -/

/-
Cantor's theorem: no surjection from a set to its power set.
-/
theorem cantor_diagonal (A : Type*) (f : A → Set A) : ¬ Surjective f := by
  by_contra h_surj;
  -- Apply Cantor's diagonal theorem to obtain a contradiction.
  apply cantor_surjective; assumption

/-
The diagonal set is always a witness.
-/
theorem cantor_diagonal_witness (A : Type*) (f : A → Set A) :
    {a : A | a ∉ f a} ∉ Set.range f := by
  simp +zetaDelta at *;
  intro x hx; replace hx := Set.ext_iff.mp hx x; by_cases h : x ∈ f x <;> simp +decide [ h ] at hx;

/-! ## Russell's Paradox

  There is no "set of all sets that do not contain themselves." -/

/-
Russell-style: the diagonal set cannot be in the range of f.
-/
theorem russell_style (A : Type*) (f : A → Set A) :
    ∀ a : A, f a ≠ {x | x ∉ f x} := by
  intro a h; have := Set.ext_iff.mp h a; simp +decide at this;

/-! ## Lawvere's Fixed Point Theorem

  If φ : A → B^A is point-surjective, then every f : B → B has a fixed point.
  Contrapositive: if some f : B → B has no fixed point, no such surjection exists. -/

/-
Lawvere's fixed point theorem (simplified).
-/
theorem lawvere_fixedpoint {A B : Type*} (φ : A → A → B)
    (h_surj : ∀ g : A → B, ∃ a, φ a = g) (f : B → B) :
    ∃ b : B, f b = b := by
  obtain ⟨ a, ha ⟩ := h_surj ( fun x ↦ f ( φ x x ) );
  exact ⟨ _, congr_fun ha a |> Eq.symm ⟩

/-
Contrapositive of Lawvere: a fixed-point-free endomorphism
    prevents point-surjectivity.
-/
theorem lawvere_contrapositive {A B : Type*} (f : B → B) (hf : ∀ b, f b ≠ b)
    (φ : A → A → B) : ¬ (∀ g : A → B, ∃ a, φ a = g) := by
  contrapose! hf with h;
  convert lawvere_fixedpoint φ h f