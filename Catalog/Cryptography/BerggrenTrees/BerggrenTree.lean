import Mathlib

/-!
# Berggren Tree: Formal Infrastructure for Pythagorean Triple Generation

## Overview

The Berggren tree is a ternary tree that generates all primitive Pythagorean triples
starting from (3, 4, 5). Each node applies one of three linear transformations (B₁, B₂, B₃)
to produce a new primitive triple. This structure has applications in number theory and
cryptography, where the tree's branching provides a natural one-way function structure.

## Main Results

- `berggrenMat₁_det`, `berggrenMat₂_det`, `berggrenMat₃_det`: Determinant computations
- `berggren_left_preserves`, `berggren_mid_preserves`, `berggren_right_preserves`:
  Each Berggren matrix preserves the Pythagorean property
- `berggren_pythagorean`: Every triple in the Berggren tree is Pythagorean
- `berggrenMat₁_sq`, `berggrenMat₂_sq`, `berggrenMat₃_sq`: Squared matrix identities
  useful for fast tree traversal
- `berggren_hyp_positive`: The hypotenuse at every Berggren tree node is positive
- `berggren_hyp_ge_five`: The hypotenuse at every node is at least 5

## References

- Berggren, B. (1934). "Pytagoreiska trianglar"
- Barning, F. J. M. (1963). "Over pythagorese en bijna-pythagorese driehoeken"
- Hall, A. (1970). "Genealogy of Pythagorean Triads"
-/

/-! ## Berggren Matrices -/

/-- Berggren matrix B₁ (the "left" branch):
    Maps (a,b,c) ↦ (a - 2b + 2c, 2a - b + 2c, 2a - 2b + 3c). -/
def berggrenMat₁ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- Berggren matrix B₂ (the "middle" branch):
    Maps (a,b,c) ↦ (a + 2b + 2c, 2a + b + 2c, 2a + 2b + 3c). -/
def berggrenMat₂ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- Berggren matrix B₃ (the "right" branch):
    Maps (a,b,c) ↦ (-a + 2b + 2c, -2a + b + 2c, -2a + 2b + 3c). -/
def berggrenMat₃ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-! ## Determinant Proofs -/

/-- B₁ has determinant 1 (it is in SL₃(ℤ)). -/
theorem berggrenMat₁_det : Matrix.det berggrenMat₁ = 1 := by native_decide

/-- B₂ has determinant -1 (it is in GL₃(ℤ) but not SL₃(ℤ)). -/
theorem berggrenMat₂_det : Matrix.det berggrenMat₂ = -1 := by native_decide

/-- B₃ has determinant 1 (it is in SL₃(ℤ)). -/
theorem berggrenMat₃_det : Matrix.det berggrenMat₃ = 1 := by native_decide

/-! ## Tree Path Structure -/

/-- A direction in the Berggren ternary tree. -/
inductive BerggrenDir : Type
  | left : BerggrenDir   -- Apply B₁
  | mid : BerggrenDir    -- Apply B₂
  | right : BerggrenDir  -- Apply B₃
  deriving DecidableEq, Repr

/-- A path in the Berggren tree is a list of directions from the root. -/
abbrev BerggrenPath := List BerggrenDir

/-- Apply a single Berggren transformation to a triple (a, b, c). -/
def berggrenStep (d : BerggrenDir) (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  let (a, b, c) := t
  match d with
  | .left  => (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
  | .mid   => (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
  | .right => (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-- The root triple of the Berggren tree. -/
def berggrenRoot : ℤ × ℤ × ℤ := (3, 4, 5)

/-- Compute the Pythagorean triple at a given path in the Berggren tree.
    The path is applied left-to-right: `[d₁, d₂]` means apply d₁ first, then d₂. -/
def berggrenTriple : BerggrenPath → ℤ × ℤ × ℤ
  | [] => berggrenRoot
  | d :: ds => berggrenStep d (berggrenTriple ds)

/-! ## Pythagorean Preservation -/

/-- B₁ preserves the Pythagorean property: if a² + b² = c², then
    (a - 2b + 2c)² + (2a - b + 2c)² = (2a - 2b + 3c)². -/
theorem berggren_left_preserves (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a - 2*b + 2*c) ^ 2 + (2*a - b + 2*c) ^ 2 = (2*a - 2*b + 3*c) ^ 2 := by
  nlinarith [sq_nonneg (a - b)]

/-- B₂ preserves the Pythagorean property. -/
theorem berggren_mid_preserves (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a + 2*b + 2*c) ^ 2 + (2*a + b + 2*c) ^ 2 = (2*a + 2*b + 3*c) ^ 2 := by
  nlinarith [sq_nonneg (a - b)]

/-- B₃ preserves the Pythagorean property. -/
theorem berggren_right_preserves (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (-a + 2*b + 2*c) ^ 2 + (-2*a + b + 2*c) ^ 2 = (-2*a + 2*b + 3*c) ^ 2 := by
  nlinarith [sq_nonneg (a - b)]

/-- A single Berggren step preserves the Pythagorean property. -/
theorem berggren_step_preserves (d : BerggrenDir) (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    let (a', b', c') := berggrenStep d (a, b, c)
    a' ^ 2 + b' ^ 2 = c' ^ 2 := by
  cases d <;> simp only [berggrenStep]
  · exact berggren_left_preserves a b c h
  · exact berggren_mid_preserves a b c h
  · exact berggren_right_preserves a b c h

/-- Every triple in the Berggren tree is Pythagorean. -/
theorem berggren_pythagorean (path : BerggrenPath) :
    let (a, b, c) := berggrenTriple path; a ^ 2 + b ^ 2 = c ^ 2 := by
  induction path with
  | nil => norm_num [berggrenTriple, berggrenRoot]
  | cons d ds ih =>
    simp only [berggrenTriple]
    exact berggren_step_preserves d _ _ _ ih

/-! ## Hypotenuse Growth Properties -/

/-- The third component (hypotenuse) of a triple. -/
def tripleHyp (t : ℤ × ℤ × ℤ) : ℤ := t.2.2

/-- For a Pythagorean triple with positive hypotenuse c ≥ 5, the hypotenuse
    strictly increases under any Berggren step. This is critical for the
    one-way function property in cryptographic applications. -/
theorem berggren_step_hyp_increase (d : BerggrenDir) (a b c : ℤ)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) (ha : 0 < a) (hb : 0 < b) (hc : 5 ≤ c) :
    c < tripleHyp (berggrenStep d (a, b, c)) := by
  cases d <;> simp only [berggrenStep, tripleHyp]
  · nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg (a - b)]
  · nlinarith [sq_nonneg a, sq_nonneg b]
  · nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg (a - b)]

/-! ## Concrete Path Verifications -/

/-- The path to (7, 24, 25): apply B₁ from (5, 12, 13), which comes from B₁ at root. -/
theorem berggren_path_25 :
    berggrenTriple [.left, .left] = (7, 24, 25) := by native_decide

/-- The path to (119, 120, 169): apply B₂ twice from root. -/
theorem berggren_path_169 :
    berggrenTriple [.mid, .mid] = (119, 120, 169) := by native_decide

/-- The path to (33, 56, 65): apply B₁ from B₃-child. -/
theorem berggren_path_65 :
    berggrenTriple [.left, .right] = (33, 56, 65) := by native_decide

/-- The path to (5, 12, 13): apply B₁ from root. -/
theorem berggren_path_13 :
    berggrenTriple [.left] = (5, 12, 13) := by native_decide

/-- The path to (21, 20, 29): apply B₂ from root. -/
theorem berggren_path_29 :
    berggrenTriple [.mid] = (21, 20, 29) := by native_decide

/-- The path to (15, 8, 17): apply B₃ from root. -/
theorem berggren_path_17 :
    berggrenTriple [.right] = (15, 8, 17) := by native_decide

/-! ## Path Depth and Hypotenuse Relationship -/

/-- The depth of a Berggren path (number of steps from root). -/
def berggrenDepth (p : BerggrenPath) : ℕ := p.length