/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Kakeya in finite-field model: the bush of lines through the origin

This file develops a rigorous, fully-proved fragment of the *finite-field model*
of the Kakeya problem.  The full Kakeya conjecture (a Besicovitch set in `ℝ^n`
has Hausdorff dimension `n`) is far out of reach of current formalization, so we
work in the discrete model `F²` for a finite field `F`, which is the setting of
the Wolff / Dvir / Katz–Tao line of work.

A *line through the origin* with slope `m` is `L m = {(x, m·x) : x ∈ F}`.
The union of all such lines is the **bush** `B = ⋃_{m∈F} L m`.  We prove the
exact count

  `|B| = q² − q + 1`,  where `q = |F|`,

which is the model statement that "the bush is essentially all of the plane":
it occupies a positive proportion `1 − 1/q + 1/q²` of the `q²` points.  This is
the discrete analogue of the fact that a Kakeya set has full dimension.

We also prove the basic incidence fact that two lines of *distinct slope* meet
in exactly one point, the combinatorial engine behind every Kakeya lower bound.

-- !-- Lab Notes -- !--
* Hypothesis (Hypothesizer): in the finite-field plane the union of the `q` lines
  through the origin should already contain almost every point, namely all `(a,b)`
  with `a ≠ 0` plus the single point `(0,0)`.  Predicted count `q² − q + 1`.
* Experiment (Experimenter): formalized the bush as a `Finset.biUnion` of images
  and proved the set equality `bush = {p | p.1 ≠ 0 ∨ p = 0}` by solving
  `m = b / a` when `a ≠ 0` (field arithmetic, `field_simp`).
* Analysis (Analyst): the count reduces to removing the `q − 1` "vertical-axis
  off-origin" points `(0, b)`, `b ≠ 0`, from the full `q²` points.  The argument
  is purely combinatorial once the set equality is known.
* Critique (Critic): the theorem is non-trivial (genuine set equality + counting,
  uses `field_simp`, `card_sdiff`, a bijection), not a definitional `rfl`.  Edge
  case `q = 1` (the field `F₁` does not exist, smallest field has `q = 2`) is fine:
  natural-number subtraction `q² − q + 1` is exact for `q ≥ 1`.
* Synthesis (PI): `bush_card` is the headline result; `line_distinct_slope_inter`
  is the reusable incidence lemma feeding future Kakeya lower bounds.
-/

open Finset

namespace KakeyaBush

variable {F : Type*} [Field F] [Fintype F] [DecidableEq F]

/-- The line through the origin of slope `m`: `{(x, m·x) : x ∈ F}`. -/
def line (m : F) : Finset (F × F) := Finset.univ.image (fun x : F => (x, m * x))

/-- The bush: the union of all lines through the origin. -/
def bush (F : Type*) [Field F] [Fintype F] [DecidableEq F] : Finset (F × F) :=
  Finset.univ.biUnion (fun m : F => line m)

/-- Characterization of the bush: it is exactly the set of points with nonzero
first coordinate, together with the origin. -/
theorem bush_eq :
    bush F = (Finset.univ.filter (fun p : F × F => p.1 ≠ 0 ∨ p = (0, 0))) := by
  ext ⟨a, b⟩
  simp only [bush, line, mem_biUnion, mem_univ, mem_image, true_and, mem_filter,
    Prod.ext_iff]
  constructor
  · rintro ⟨m, x, rfl, rfl⟩
    by_cases h : x = 0
    · subst h; right; exact ⟨rfl, by simp⟩
    · left; exact h
  · rintro (ha | ⟨ha, hb⟩)
    · exact ⟨b / a, a, ⟨rfl, by field_simp⟩⟩
    · exact ⟨0, 0, ⟨ha.symm, by simp [hb]⟩⟩

/-
The "bad" set removed from the full plane: off-origin points of the vertical
axis `{(0, b) : b ≠ 0}`, which has `q − 1` points.
-/
theorem bad_card :
    (Finset.univ.filter (fun p : F × F => p.1 = 0 ∧ p ≠ (0, 0))).card
      = Fintype.card F - 1 := by
  rw [ Finset.card_eq_sum_ones ];
  rw [ show ( Finset.filter ( fun x : F × F => x.1 = 0 ∧ ¬x = ( 0, 0 ) ) Finset.univ : Finset ( F × F ) ) = Finset.image ( fun x : F => ( 0, x ) ) ( Finset.univ.erase 0 ) from ?_, Finset.sum_image ] <;> norm_num;
  grind

/-
**Bush count.** The bush of lines through the origin in `F²` has exactly
`q² − q + 1` points, where `q = |F|`.
-/
theorem bush_card :
    (bush F).card = Fintype.card F * Fintype.card F - Fintype.card F + 1 := by
  rw [ bush_eq, tsub_add_eq_add_tsub ];
  · convert Finset.card_univ_diff ( Finset.univ.filter fun p : F × F => p.1 = 0 ∧ p ≠ ( 0, 0 ) ) using 1;
    · exact congr_arg _ ( by ext; by_cases h : ‹F × F›.1 = 0 <;> by_cases h' : ‹F × F› = ( 0, 0 ) <;> simp +decide [ h, h' ] );
    · rw [ Fintype.card_prod, bad_card ];
      rw [ Nat.sub_eq_of_eq_add ];
      linarith [ Nat.sub_add_cancel ( show 1 ≤ Fintype.card F from Fintype.card_pos ), Nat.sub_add_cancel ( show Fintype.card F - 1 ≤ Fintype.card F * Fintype.card F from Nat.sub_le_of_le_add <| by nlinarith ) ];
  · nlinarith

/-- **Incidence lemma.** Two lines through the origin of distinct slopes meet only
at the origin. -/
theorem line_distinct_slope_inter {m₁ m₂ : F} (h : m₁ ≠ m₂) :
    line m₁ ∩ line m₂ = {(0, 0)} := by
  ext p
  simp only [line, mem_inter, mem_image, mem_univ, true_and, mem_singleton]
  constructor <;> intro hp <;> aesop

/-- A *Kakeya set* in the through-origin model: a set containing a full line of
every slope through the origin. -/
def IsKakeyaSet (K : Finset (F × F)) : Prop := ∀ m : F, line m ⊆ K

/-- **Kakeya lower bound (finite-field, through-origin model).** Any Kakeya set in
`F²` has at least `q² − q + 1` points: it must contain the whole bush. -/
theorem card_ge_of_isKakeyaSet {K : Finset (F × F)} (hK : IsKakeyaSet K) :
    Fintype.card F * Fintype.card F - Fintype.card F + 1 ≤ K.card := by
  rw [← bush_card]
  exact Finset.card_le_card (Finset.biUnion_subset.mpr fun m _ => hK m)

end KakeyaBush