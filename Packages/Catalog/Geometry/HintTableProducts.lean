/-
# HINT-TABLE-COMPLETION, part III: one negative bit per even factor

Mirror of `Bridges.HintValueMultiFieldCeiling` ("one orientation bit per field") on the floor
side: torsion selectors multiply (`HintTable.TorsionSelector.prod`), so over
`ZMod (2k) × ZMod (2l)` the hint value is at least `-2` bits
(`neg_two_le_hintValue_two_even`), and `square_hintValue_eq_neg_two` shows this is attained
by a four-sample battery over `ZMod 8 × ZMod 8` whose four `(s,d)` readings coincide and whose
four products are distinct.

-- !-- Lab Notes -- !--
Experiment: `P = (0,0),(0,4),(4,0),(4,4)`, `Q = (1,1),(1,5),(5,1),(5,5)` give `(s,d) = ((1,1),(1,1))`
  for every sample and products `(0,0),(0,4),(4,0),(4,4)`; with distinct labels,
  `I(N) = 2`, `I(s,d) = 0`.  Critique: the general `k`-factor statement is conjecture F2 of
  `FUTURE_DIRECTIONS.md`.
-/
import Mathlib
import Geometry.HintTableIndependence

namespace HintTable

open TraceBattery BatterySynergy SumDiffSplit HintValueMultiField Corners

/-! ## 7. One negative bit per even factor -/

/-- **Torsion selectors multiply.** -/
def TorsionSelector.prod {R S F G : Type*} [CommRing R] [CommRing S]
    (S₁ : TorsionSelector R F) (S₂ : TorsionSelector S G) : TorsionSelector (R × S) (F × G) where
  sel a := (S₁.sel a.1, S₂.sel a.2)
  sound a b h hs := by
    have h1 : 2 * a.1 = 2 * b.1 := by simpa using congrArg Prod.fst h
    have h2 : 2 * a.2 = 2 * b.2 := by simpa using congrArg Prod.snd h
    exact Prod.ext (S₁.sound _ _ h1 (congrArg Prod.fst hs))
      (S₂.sound _ _ h2 (congrArg Prod.snd hs))

/-- **The two-factor floor.**  Over a product of two even cyclic rings the hint value is never
below `-2` bits. -/
theorem neg_two_le_hintValue_two_even (k l : ℕ) [NeZero k] [NeZero l] {Ω : Type*} [Fintype Ω]
    [Nonempty Ω] {Λ : Type*} (L : Ω → Λ) (P Q : Ω → ZMod (2 * k) × ZMod (2 * l)) :
    -2 ≤ hintValue L P Q := by
  have := neg_logb_le_hintValue L P Q ((halfSelector k).prod (halfSelector l))
  have h4 : Real.logb 2 ((Fintype.card (Bool × Bool) : ℕ) : ℝ) = 2 := by
    rw [Fintype.card_prod, Fintype.card_bool,
      show (((2 * 2 : ℕ)) : ℝ) = 2 ^ (2 : ℕ) by norm_num, Real.logb_pow]
    simp
  linarith

namespace Square

/-- First factors of the four-sample collision battery over `ZMod 8 × ZMod 8`. -/
def P : Fin 4 → ZMod 8 × ZMod 8 := ![(0, 0), (0, 4), (4, 0), (4, 4)]
/-- Second factors of the four-sample collision battery. -/
def Q : Fin 4 → ZMod 8 × ZMod 8 := ![(1, 1), (1, 5), (5, 1), (5, 5)]

theorem residue_const (x y : Fin 4) : residueView P Q x = residueView P Q y := by
  fin_cases x <;> fin_cases y <;> decide

theorem product_determines (x y : Fin 4) :
    productView P Q x = productView P Q y → Lid x = Lid y := by
  fin_cases x <;> fin_cases y <;> decide

end Square

/-- **The two-factor floor is attained**: all four residue pairs coincide, all four products
differ, so the hint value is exactly `-2` bits. -/
theorem square_hintValue_eq_neg_two : hintValue Lid Square.P Square.Q = -2 := by
  rw [hintValue, MIb_eq_zero_of_const _ _ Square.residue_const,
    MIb_eq_label_entropy_of_determines _ _ Square.product_determines, Hb_Lid]
  norm_num

end HintTable