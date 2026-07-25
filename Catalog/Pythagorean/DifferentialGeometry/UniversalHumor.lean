import Mathlib

/-!
# Universal properties and metric surprise

This file gives a precise finite model of the proposed connection. Resolutions of a
setup form the chain `Fin (n+1)`, regarded as a thin category. A morphism means
"no more surprising than". The metric surprise of resolution `i` is its distance
from the expected resolution `0` after embedding the chain in `ℝ`.

The main connector theorem says that categorical universality (being terminal) is
*equivalent* to global maximization of metric surprise. Thus the slogan
"the funniest joke is universal" is valid in this model, but because of an explicit
compatibility condition between morphisms and surprise—not as a theorem about
arbitrary categories or empirical humor ratings.
-/

open CategoryTheory CategoryTheory.Limits

namespace UniversalHumor

/-- The finite category of possible resolutions for one setup. -/
abbrev Resolution (n : ℕ) := Fin (n + 1)

instance resolutionCategory (n : ℕ) : SmallCategory (Resolution n) :=
  Preorder.smallCategory (Resolution n)

/-- The expected resolution is the least surprising point of the chain. -/
def expected (n : ℕ) : Resolution n := 0

/-- The canonical maximally displaced punchline. -/
def punchline (n : ℕ) : Resolution n := Fin.last n

/-- Surprise is ordinary Euclidean distance from the expected resolution. -/
def surprise {n : ℕ} (j : Resolution n) : ℝ :=
  dist (j.val : ℝ) ((expected n).val : ℝ)

/-- Proposition asserting that a resolution has the terminal universal property. -/
def Universal {n : ℕ} (j : Resolution n) : Prop := Nonempty (IsTerminal j)

/-
In the ordinal model, metric surprise is exactly the ordinal coordinate.
-/
lemma surprise_eq_val {n : ℕ} (j : Resolution n) : surprise j = j.val := by
  -- By definition of surprise, we have surprise j = dist (j.val : ℝ) 0.
  simp [surprise, expected]

/-
A morphism in the resolution category is equivalent to comparison of indices.
-/
lemma nonempty_hom_iff_le {n : ℕ} (i j : Resolution n) :
    Nonempty (i ⟶ j) ↔ i ≤ j := by
  constructor;
  · rintro ⟨ ⟨ ⟨ h ⟩ ⟩ ⟩ ; exact h;
  · intro h;
    exact ⟨ CategoryTheory.homOfLE h ⟩

/-
The final ordinal is a terminal object of the thin resolution category.
-/
theorem punchline_isTerminal (n : ℕ) : Universal (punchline n) := by
  refine' ⟨ _ ⟩;
  constructor;
  rotate_right;
  exact fun s => CategoryTheory.homOfLE ( Fin.le_last _ );
  · aesop;
  · intro s m hm; exact Subsingleton.elim _ _;

/-
Terminality completely characterizes the final ordinal.
-/
theorem isTerminal_iff_eq_punchline {n : ℕ} (j : Resolution n) :
    Universal j ↔ j = punchline n := by
  constructor;
  · intro hj
    obtain ⟨hj_term⟩ := hj;
    exact le_antisymm ( Fin.le_last _ ) ( nonempty_hom_iff_le _ _ |>.1 ⟨ hj_term.from _ ⟩ );
  · exact fun h => h ▸ punchline_isTerminal n

/-
The canonical punchline has at least as much surprise as every resolution.
-/
theorem surprise_le_punchline {n : ℕ} (j : Resolution n) :
    surprise j ≤ surprise (punchline n) := by
  simp +decide [ surprise_eq_val ];
  exact Fin.le_last _

/-
The metric surprise maximizer is unique.
-/
theorem surprise_maximizer_unique {n : ℕ} (j : Resolution n)
    (h : ∀ k : Resolution n, surprise k ≤ surprise j) :
    j = punchline n := by
  exact Fin.ext <| Nat.le_antisymm ( Fin.le_last _ ) <| by simpa [ surprise_eq_val ] using h ( punchline n )

/-
**Category/metric connector.** A resolution is terminal exactly when it globally
maximizes distance from the expected resolution.
-/
theorem universal_iff_maximizes_surprise {n : ℕ} (j : Resolution n) :
    Universal j ↔ ∀ k : Resolution n, surprise k ≤ surprise j := by
  refine ⟨ fun h k ↦ ?_, fun h ↦ ?_ ⟩;
  · convert surprise_le_punchline k;
    exact isTerminal_iff_eq_punchline j |>.1 h;
  · convert isTerminal_iff_eq_punchline j |>.2 ( surprise_maximizer_unique j h )

/-
The universal resolution has the explicitly computed surprise `n`.
-/
theorem terminal_surprise {n : ℕ} {j : Resolution n} (h : Universal j) :
    surprise j = n := by
  convert surprise_eq_val j using 1 ; rw [ isTerminal_iff_eq_punchline _ |>.1 h ] ; simp +decide;
  exact Eq.symm ( Fin.val_last _ )

/-- Surprise is injective on the finite resolution chain. -/
theorem surprise_injective {n : ℕ} {j k : Resolution n}
    (h : surprise k = surprise j) : k = j := by
  rw [surprise_eq_val, surprise_eq_val] at h
  apply Fin.ext
  exact_mod_cast h

/-
The proposed 100-joke finite test bed really has one hundred resolutions.
-/
theorem hundred_resolution_count : Fintype.card (Resolution 99) = 100 := by
  simp [Resolution]

/-
In that 100-resolution test bed, the universal punchline has surprise 99.
-/
theorem hundred_resolution_universal_surprise
    {j : Resolution 99} (h : Universal j) : surprise j = 99 := by
  convert terminal_surprise h

end UniversalHumor