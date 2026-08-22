import Cryptography.TernaryReversible.Core

/-!
# A reversible ternary radius-one rule whose inverse is not radius one

The refutation in `Cryptography.TernaryReversible.Refutation` produces rules that are
bijective on every cycle but still decode with a *radius-one* inverse (they are
involutions).  This file goes one step further and exhibits a rule for which local
reversibility is genuinely non-local: the **conditional-transposition rule**

`gTwist a b c = if (b ≠ 0 ∧ c = 2) then swap01 a else a`,

which copies the left neighbour, transposing the values `0` and `1` exactly when the
pattern `(b ≠ 0, c = 2)` occurs to its right.

## Main results

* `gTwist_decoder4` / `gTwist_cycleBijective`: `gTwist` is bijective on every nonempty
  finite cycle, because a window-*four* decoder reconstructs each cell from the four
  output cells to its right.
* `gTwist_no_window3_decoder`: **no** window-three decoder exists, at *any* of the five
  possible offsets; so the inverse automaton has neighbourhood width at least four.
* `gTwist_no_radiusOne_inverse`: in particular `gTwist` has no radius-one inverse
  cellular automaton.
* `gTwist_deps`: `gTwist` also uses two cells of its window, hence is one more
  counterexample to the classification claim, of a shape different from the
  sign-twisted involutions.

The mechanism: the transposition `swap01` fixes the letter `2`, so the positions
carrying `2` are visible in the output, but deciding whether the *condition* fired at a
cell requires knowing whether its right neighbour is nonzero, which in turn requires
looking one cell further right.  The information needed to invert therefore travels a
bounded but strictly larger distance than the rule itself.
-/

namespace Cryptography
namespace TernaryReversible

/-- The transposition of `0` and `1` fixing `2`. -/
def swap01 (x : Alph) : Alph := if x = 2 then 2 else 1 - x

/-- The conditional-transposition rule. -/
def gTwist : LocalRule := fun a b c => if b ≠ 0 ∧ c = 2 then swap01 a else a

/-- The window-four decoder for `gTwist`: it recovers the *leftmost* cell of a window
from the four output cells it determines. -/
def dTwist (u₀ u₁ u₂ u₃ : Alph) : Alph :=
  if u₂ = 2 ∧ (if u₃ = 2 then u₁ ≠ 1 else u₁ ≠ 0) then swap01 u₀ else u₀

/-- **Decoding identity.** `dTwist` inverts `gTwist` on words of length six. -/
theorem gTwist_decoder4 : ∀ x₀ x₁ x₂ x₃ x₄ x₅ : Alph,
    dTwist (gTwist x₀ x₁ x₂) (gTwist x₁ x₂ x₃) (gTwist x₂ x₃ x₄) (gTwist x₃ x₄ x₅) = x₀ := by
  decide

/-- `gTwist` is bijective on every nonempty finite cycle. -/
theorem gTwist_cycleBijective : CycleBijective gTwist :=
  cycleBijective_of_decoder4R gTwist dTwist gTwist_decoder4

/-! ## The inverse is not radius one -/

/-- No window-three decoder recovers the leftmost cell. -/
theorem gTwist_no_decoder_pos0 (d : LocalRule) :
    ¬ ∀ v w x y z : Alph, d (gTwist v w x) (gTwist w x y) (gTwist x y z) = v := by
  intro h
  have h1 := h 0 0 2 0 0
  have h2 := h 1 1 2 2 0
  rw [show gTwist 1 1 2 = gTwist 0 0 2 from by decide,
      show gTwist 1 2 2 = gTwist 0 2 0 from by decide,
      show gTwist 2 2 0 = gTwist 2 0 0 from by decide] at h2
  rw [h1] at h2
  exact absurd h2 (by decide)

/-- No window-three decoder recovers the second cell. -/
theorem gTwist_no_decoder_pos1 (d : LocalRule) :
    ¬ ∀ v w x y z : Alph, d (gTwist v w x) (gTwist w x y) (gTwist x y z) = w := by
  intro h
  have h1 := h 0 0 0 0 0
  have h2 := h 0 1 1 2 2
  rw [show gTwist 0 1 1 = gTwist 0 0 0 from by decide,
      show gTwist 1 1 2 = gTwist 0 0 0 from by decide,
      show gTwist 1 2 2 = gTwist 0 0 0 from by decide] at h2
  rw [h1] at h2
  exact absurd h2 (by decide)

/-- No window-three decoder recovers the middle cell. -/
theorem gTwist_no_decoder_pos2 (d : LocalRule) :
    ¬ ∀ v w x y z : Alph, d (gTwist v w x) (gTwist w x y) (gTwist x y z) = x := by
  intro h
  have h1 := h 0 0 0 0 0
  have h2 := h 0 0 1 1 2
  rw [show gTwist 0 0 1 = gTwist 0 0 0 from by decide,
      show gTwist 0 1 1 = gTwist 0 0 0 from by decide,
      show gTwist 1 1 2 = gTwist 0 0 0 from by decide] at h2
  rw [h1] at h2
  exact absurd h2 (by decide)

/-- No window-three decoder recovers the fourth cell. -/
theorem gTwist_no_decoder_pos3 (d : LocalRule) :
    ¬ ∀ v w x y z : Alph, d (gTwist v w x) (gTwist w x y) (gTwist x y z) = y := by
  intro h
  have h1 := h 0 0 0 0 0
  have h2 := h 0 0 0 1 0
  rw [show gTwist 0 0 1 = gTwist 0 0 0 from by decide,
      show gTwist 0 1 0 = gTwist 0 0 0 from by decide] at h2
  rw [h1] at h2
  exact absurd h2 (by decide)

/-- No window-three decoder recovers the rightmost cell. -/
theorem gTwist_no_decoder_pos4 (d : LocalRule) :
    ¬ ∀ v w x y z : Alph, d (gTwist v w x) (gTwist w x y) (gTwist x y z) = z := by
  intro h
  have h1 := h 0 0 0 0 0
  have h2 := h 0 0 0 0 1
  rw [show gTwist 0 0 1 = gTwist 0 0 0 from by decide] at h2
  rw [h1] at h2
  exact absurd h2 (by decide)

/-- **No window-three decoder at any offset.** Whatever local rule `d` and whichever of
the five cells of the input window one tries to recover, three consecutive outputs never
suffice.  Together with `gTwist_decoder4` this pins the decoding width of `gTwist` at
exactly four. -/
theorem gTwist_no_window3_decoder (d : LocalRule) :
    (¬ ∀ v w x y z : Alph, d (gTwist v w x) (gTwist w x y) (gTwist x y z) = v) ∧
    (¬ ∀ v w x y z : Alph, d (gTwist v w x) (gTwist w x y) (gTwist x y z) = w) ∧
    (¬ ∀ v w x y z : Alph, d (gTwist v w x) (gTwist w x y) (gTwist x y z) = x) ∧
    (¬ ∀ v w x y z : Alph, d (gTwist v w x) (gTwist w x y) (gTwist x y z) = y) ∧
    (¬ ∀ v w x y z : Alph, d (gTwist v w x) (gTwist w x y) (gTwist x y z) = z) :=
  ⟨gTwist_no_decoder_pos0 d, gTwist_no_decoder_pos1 d, gTwist_no_decoder_pos2 d,
    gTwist_no_decoder_pos3 d, gTwist_no_decoder_pos4 d⟩

/-- Two configurations on the five-cycle that a radius-one inverse could not separate:
the constant `0` configuration and `(0,0,1,1,2)` have the same image in positions
`1, 2, 3` but differ in position `2`. -/
def conf5 : ZMod 5 → Alph := fun i => if i = 2 then 1 else if i = 3 then 1 else
  if i = 4 then 2 else 0

/-- **No radius-one inverse automaton.** There is no local rule `d` whose global maps
invert those of `gTwist` on all cycles. -/
theorem gTwist_no_radiusOne_inverse :
    ¬ ∃ d : LocalRule, ∀ (n : ℕ) (s : ZMod n → Alph),
        globalMap d (globalMap gTwist s) = s := by
  rintro ⟨d, hd⟩
  have h1 := congrFun (hd 5 (fun _ => 0)) 2
  have h2 := congrFun (hd 5 conf5) 2
  have e1 : globalMap gTwist conf5 (2 - 1) = globalMap gTwist (fun _ : ZMod 5 => 0) (2 - 1) := by
    decide
  have e2 : globalMap gTwist conf5 2 = globalMap gTwist (fun _ : ZMod 5 => 0) 2 := by
    decide
  have e3 : globalMap gTwist conf5 (2 + 1) = globalMap gTwist (fun _ : ZMod 5 => 0) (2 + 1) := by
    decide
  have key : globalMap d (globalMap gTwist conf5) 2
      = globalMap d (globalMap gTwist (fun _ : ZMod 5 => 0)) 2 := by
    show d (globalMap gTwist conf5 (2 - 1)) (globalMap gTwist conf5 2)
        (globalMap gTwist conf5 (2 + 1))
      = d (globalMap gTwist (fun _ : ZMod 5 => 0) (2 - 1))
        (globalMap gTwist (fun _ : ZMod 5 => 0) 2)
        (globalMap gTwist (fun _ : ZMod 5 => 0) (2 + 1))
    rw [e1, e2, e3]
  rw [h1, h2] at key
  exact absurd key (by decide)

/-! ## `gTwist` is a counterexample of a new shape -/

theorem gTwist_dependsLeft : DependsLeft gTwist := by decide

theorem gTwist_dependsMiddle : DependsMiddle gTwist := by decide

theorem gTwist_dependsRight : DependsRight gTwist := by decide

theorem gTwist_not_singleCoordinatePerm : ¬ SingleCoordinatePerm gTwist :=
  not_singleCoordinatePerm_of_twoDeps (Or.inl ⟨gTwist_dependsLeft, gTwist_dependsMiddle⟩)

/-- A rule that is bijective on every finite cycle, is not of the predicted form, and —
unlike the sign-twisted involutions — is not even invertible by a radius-one automaton. -/
theorem exists_counterexample_with_large_inverse_radius :
    ∃ g : LocalRule, CycleBijective g ∧ ¬ SingleCoordinatePerm g ∧
      ¬ ∃ d : LocalRule, ∀ (n : ℕ) (s : ZMod n → Alph),
          globalMap d (globalMap g s) = s :=
  ⟨gTwist, gTwist_cycleBijective, gTwist_not_singleCoordinatePerm, gTwist_no_radiusOne_inverse⟩

end TernaryReversible
end Cryptography