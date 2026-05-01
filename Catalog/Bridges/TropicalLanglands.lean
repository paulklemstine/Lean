import Mathlib

/-! # CatalogBuild.Bridges.TropicalLanglands

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 15
-/

noncomputable section

/-- Tree moves in the Berggren tree -/
inductive BerggrenMove
  | L  -- Apply M₁
  | M  -- Apply M₂
  | R  -- Apply M₃
  deriving DecidableEq, Repr

/-- A path in the Berggren tree -/
abbrev BerggrenPath := List BerggrenMove

/-- Apply a single Berggren move to a triple -/
def applyMove (m : BerggrenMove) (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  match m with
  | .L => (t.1 - 2*t.2.1 + 2*t.2.2,
           2*t.1 - t.2.1 + 2*t.2.2,
           2*t.1 - 2*t.2.1 + 3*t.2.2)
  | .M => (t.1 + 2*t.2.1 + 2*t.2.2,
           2*t.1 + t.2.1 + 2*t.2.2,
           2*t.1 + 2*t.2.1 + 3*t.2.2)
  | .R => (-t.1 + 2*t.2.1 + 2*t.2.2,
           -2*t.1 + t.2.1 + 2*t.2.2,
           -2*t.1 + 2*t.2.1 + 3*t.2.2)

/-- Apply a path (sequence of moves) to a triple -/
def applyPath (path : BerggrenPath) (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  path.foldl (fun acc m => applyMove m acc) t

/-- Every move preserves the quadratic form a² + b² - c² -/
theorem applyMove_quad_form (m : BerggrenMove) (a b c : ℤ) :
    let t := applyMove m (a, b, c)
    t.1^2 + t.2.1^2 - t.2.2^2 = a^2 + b^2 - c^2 := by
  cases m <;> simp [applyMove] <;> ring

/-- Every move preserves the Pythagorean relation -/
theorem applyMove_preserves_pyth (m : BerggrenMove) (a b c : ℤ)
    (h : a^2 + b^2 = c^2) :
    let t := applyMove m (a, b, c)
    t.1^2 + t.2.1^2 = t.2.2^2 := by
  have := applyMove_quad_form m a b c
  omega

/-- The empty path is the identity -/
theorem applyPath_nil (t : ℤ × ℤ × ℤ) : applyPath [] t = t := rfl

/-- Concatenation of paths composes the actions -/
theorem applyPath_append (p q : BerggrenPath) (t : ℤ × ℤ × ℤ) :
    applyPath (p ++ q) t = applyPath q (applyPath p t) := by
  simp [applyPath, List.foldl_append]

/-- Under M₂, the hypotenuse strictly increases for positive triples -/
theorem move_M_hyp_increase (a b c : ℤ)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    c < (applyMove .M (a, b, c)).2.2 := by
  simp [applyMove]; linarith

/-- The root (3,4,5) children -/
theorem root_child_L : applyMove .L (3, 4, 5) = (5, 12, 13) := by decide

/-- [Section: # CatalogBuild.Bridges.TropicalLanglands
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 15] -/
theorem root_child_M : applyMove .M (3, 4, 5) = (21, 20, 29) := by decide

/-- [Section: # CatalogBuild.Bridges.TropicalLanglands
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 15] -/
theorem root_child_R : applyMove .R (3, 4, 5) = (15, 8, 17) := by decide

/-- Grandchildren -/
theorem root_grandchild_LL :
    applyPath [.L, .L] (3, 4, 5) = (7, 24, 25) := by decide

theorem root_grandchild_LM :
    applyPath [.L, .M] (3, 4, 5) = (55, 48, 73) := by decide

theorem pyth_perimeter_even (a b c : ℤ) (h : a^2 + b^2 = c^2)
    (hparity : (a % 2 = 0 ∧ b % 2 = 1) ∨ (a % 2 = 1 ∧ b % 2 = 0)) :
    2 ∣ (a + b + c) := by
  replace h := congr_arg ( · % 4 ) h ; rcases Int.even_or_odd' a with ⟨ k, rfl | rfl ⟩ <;> rcases Int.even_or_odd' b with ⟨ l, rfl | rfl ⟩ <;> rcases Int.even_or_odd' c with ⟨ m, rfl | rfl ⟩ <;> ring_nf at * <;> norm_num [ Int.add_emod, Int.mul_emod ] at *;

