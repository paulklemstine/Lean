/-! # CatalogBuild.Pythagorean.Berggren.BerggrenTree

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 11
-/

import Mathlib

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

/-- A path in the ternary Berggren tree. -/

def TreePath.depth : TreePath → ℕ
  | .root    => 0
  | .left p  => p.depth + 1
  | .mid p   => p.depth + 1
  | .right p => p.depth + 1

/-- Computable version of the Berggren triple at a given tree path.
    Returns (a, b, c) where a² + b² = c². -/

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

/-!
## Key algebraic properties of the Berggren transformations

The Berggren matrices preserve:
1. The Pythagorean property (proved above)
2. Primitivity (gcd(a,b,c) = 1)
3. Positivity of all components (when starting from positive triples)

The tree is **complete**: every primitive Pythagorean triple with a odd, b even
appears exactly once.
-/

/-
PROBLEM
The Berggren M₁ transformation preserves the Pythagorean property (iff version).

PROVIDED SOLUTION
Both directions follow from expanding the squares and algebraic manipulation.
Use constructor, then nlinarith for each direction.
-/

theorem berggren_A_iff (a b c : ℤ) :
    (a - 2 * b + 2 * c) ^ 2 + (2 * a - b + 2 * c) ^ 2 =
    (2 * a - 2 * b + 3 * c) ^ 2 ↔ a ^ 2 + b ^ 2 = c ^ 2 := by
  grind

/-
PROBLEM
The Berggren M₂ transformation preserves the Pythagorean property (iff version).

PROVIDED SOLUTION
Both directions follow from expanding the squares and algebraic manipulation.
Use constructor, then nlinarith for each direction.
-/

theorem berggren_B_iff (a b c : ℤ) :
    (a + 2 * b + 2 * c) ^ 2 + (2 * a + b + 2 * c) ^ 2 =
    (2 * a + 2 * b + 3 * c) ^ 2 ↔ a ^ 2 + b ^ 2 = c ^ 2 := by
  constructor <;> intro h <;> linarith [ berggren_B_pyth_eq a b c ( by linarith ) ]

/-
PROBLEM
The Berggren M₃ transformation preserves the Pythagorean property (iff version).

PROVIDED SOLUTION
Both directions follow from expanding the squares and algebraic manipulation.
Use constructor, then nlinarith for each direction.
-/

theorem berggren_C_iff (a b c : ℤ) :
    (-a + 2 * b + 2 * c) ^ 2 + (-2 * a + b + 2 * c) ^ 2 =
    (-2 * a + 2 * b + 3 * c) ^ 2 ↔ a ^ 2 + b ^ 2 = c ^ 2 := by
  constructor <;> intro h <;> linarith [ berggren_C_pyth_eq a b c ( by linarith ) ]

/-!
## Computational examples

We can evaluate the tree to verify it generates known triples.
-/

#eval berggrenTripleAux .root                           -- (3, 4, 5)
#eval berggrenTripleAux (.left .root)                   -- (5, 12, 13)
#eval berggrenTripleAux (.mid .root)                    -- (21, 20, 29)
#eval berggrenTripleAux (.right .root)                  -- (15, 8, 17)
#eval berggrenTripleAux (.left (.left .root))           -- (7, 24, 25)
#eval berggrenTripleAux (.mid (.left .root))            -- (55, 48, 73)
#eval berggrenTripleAux (.right (.left .root))          -- (45, 28, 53)

/-- At depth d, the hypotenuse c of the M₂ child satisfies c' = 2a + 2b + 3c ≥ 3c
    when a, b > 0. This implies exponential growth: max hypotenuse at depth d ≥ 3^d · 5. -/

theorem hypotenuse_growth (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) :
    2 * a + 2 * b + 3 * c ≥ 3 * c := by
  linarith

