/-! # CatalogBuild.Pythagorean.Berggren.BerggrenTree

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 11
-/

import Mathlib

/-- Berggren matrix M₁ preserves the Pythagorean property. -/
theorem berggren_A_pyth_eq (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a - 2 * b + 2 * c) ^ 2 + (2 * a - b + 2 * c) ^ 2 =
    (2 * a - 2 * b + 3 * c) ^ 2 := by
  nlinarith


/-- Berggren matrix M₂ preserves the Pythagorean property. -/
theorem berggren_B_pyth_eq (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a + 2 * b + 2 * c) ^ 2 + (2 * a + b + 2 * c) ^ 2 =
    (2 * a + 2 * b + 3 * c) ^ 2 := by
  nlinarith


/-- Berggren matrix M₃ preserves the Pythagorean property. -/
theorem berggren_C_pyth_eq (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (-a + 2 * b + 2 * c) ^ 2 + (-2 * a + b + 2 * c) ^ 2 =
    (-2 * a + 2 * b + 3 * c) ^ 2 := by
  nlinarith


/-- The root of the Berggren tree: the triple (3, 4, 5). -/
def rootTriple : PythTriple where
  a := 3
  b := 4
  c := 5
  pyth := by norm_num


/-- The depth of a tree path. -/
def TreePath.depth : TreePath → ℕ
  | .root    => 0
  | .left p  => p.depth + 1
  | .mid p   => p.depth + 1
  | .right p => p.depth + 1


theorem berggrenTripleAux_pyth (p : TreePath) :
    (berggrenA p) ^ 2 + (berggrenB p) ^ 2 = (berggrenC p) ^ 2 := by
  -- We can prove this by induction on the tree path.
  induction p with
  | root => rfl
  | left p ih =>
  convert berggren_A_pyth_eq ( berggrenA p ) ( berggrenB p ) ( berggrenC p ) ih using 1
  | mid p hp =>
  convert berggren_B_pyth_eq ( berggrenA p ) ( berggrenB p ) ( berggrenC p ) hp using 1
  | right p hp => convert
  berggren_C_pyth_eq ( berggrenA p ) ( berggrenB p ) ( berggrenC p ) hp using 1


/-- The set of all triples reachable at depth ≤ d. -/
def treeTriplesAtDepth (d : ℕ) : Set (ℤ × ℤ × ℤ) :=
  { t | ∃ p : TreePath, p.depth ≤ d ∧ berggrenTripleAux p = t }


theorem berggren_A_iff (a b c : ℤ) :
    (a - 2 * b + 2 * c) ^ 2 + (2 * a - b + 2 * c) ^ 2 =
    (2 * a - 2 * b + 3 * c) ^ 2 ↔ a ^ 2 + b ^ 2 = c ^ 2 := by
  grind


theorem berggren_B_iff (a b c : ℤ) :
    (a + 2 * b + 2 * c) ^ 2 + (2 * a + b + 2 * c) ^ 2 =
    (2 * a + 2 * b + 3 * c) ^ 2 ↔ a ^ 2 + b ^ 2 = c ^ 2 := by
  constructor <;> intro h <;> linarith [ berggren_B_pyth_eq a b c ( by linarith ) ]


theorem berggren_C_iff (a b c : ℤ) :
    (-a + 2 * b + 2 * c) ^ 2 + (-2 * a + b + 2 * c) ^ 2 =
    (-2 * a + 2 * b + 3 * c) ^ 2 ↔ a ^ 2 + b ^ 2 = c ^ 2 := by
  constructor <;> intro h <;> linarith [ berggren_C_pyth_eq a b c ( by linarith ) ]


/-- At depth d, the hypotenuse c of the M₂ child satisfies c' = 2a + 2b + 3c ≥ 3c
when a, b > 0. This implies exponential growth: max hypotenuse at depth d ≥ 3^d · 5. -/
theorem hypotenuse_growth (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) :
    2 * a + 2 * b + 3 * c ≥ 3 * c := by
  linarith

