/-! # CatalogBuild.Physics.Defs.lean

Auto-generated from theorem catalog database.
Domain: Physics
Declarations: 8
-/

import Mathlib

noncomputable section

/-- A primitive Pythagorean triple `(a, b, c)` with `a² + b² = c²`, `a > 0`, `b > 0`,
and `gcd(a, b) = 1`. -/
structure PrimPythTriple where
  a : ℤ
  b : ℤ
  c : ℤ
  pyth : a ^ 2 + b ^ 2 = c ^ 2
  a_pos : 0 < a
  b_pos : 0 < b
  coprime : Int.gcd a b = 1
  c_pos : 0 < c


/-- `c - b > 0` for any primitive Pythagorean triple, since `c² - b² = a² > 0`
and both `c, b > 0` implies `c > b`. -/
theorem PrimPythTriple.c_sub_b_pos (p : PrimPythTriple) : 0 < p.c - p.b := by
  nlinarith [p.pyth, p.a_pos, sq_nonneg p.a, sq_nonneg (p.c - p.b), p.c_pos, p.b_pos]


/-- `c - b ≠ 0` (as a real number). -/
theorem PrimPythTriple.c_sub_b_ne_zero (p : PrimPythTriple) : (p.c : ℝ) - (p.b : ℝ) ≠ 0 := by
  have h := p.c_sub_b_pos
  exact_mod_cast ne_of_gt h


/-- Möbius transformation on ℝ induced by a 2×2 real matrix `[[a, b], [c, d]]`:
`z ↦ (a·z + b) / (c·z + d)`. -/
def moebiusReal (a b c d : ℝ) (z : ℝ) : ℝ := (a * z + b) / (c * z + d)


/-- The cross-ratio of four real numbers `(z₁, z₂, z₃, z₄)`, defined as
`((z₁ - z₃)(z₂ - z₄)) / ((z₁ - z₄)(z₂ - z₃))`.
This is a fundamental projective invariant: it is preserved by all Möbius
transformations. -/
def cross_ratio (z₁ z₂ z₃ z₄ : ℝ) : ℝ :=
  ((z₁ - z₃) * (z₂ - z₄)) / ((z₁ - z₄) * (z₂ - z₃))


/-- The three Berggren 3×3 matrices that generate all primitive Pythagorean triples
from `(3, 4, 5)`. Each maps a primitive triple to a new primitive triple. -/
def berggrenMatrix : Fin 3 → Matrix (Fin 3) (Fin 3) ℤ
  | 0 => !![1, -2, 2; 2, -1, 2; 2, -2, 3]   -- U
  | 1 => !![1, 2, 2; 2, 1, 2; 2, 2, 3]       -- A
  | 2 => !![-1, 2, 2; -2, 1, 2; -2, 2, 3]    -- D


/-- The Berggren action on column vectors `(a, b, c)ᵀ`. -/
def berggrenActVec (g : Fin 3) (v : Fin 3 → ℤ) : Fin 3 → ℤ :=
  (berggrenMatrix g).mulVec v


/-- The 2×2 matrices induced by the Berggren generators on the stereographic
coordinates `[a : c - b]`. These act by Möbius transformations on the SPB
value `a/(c-b)`.
- Generator 0 (U): `[[1, 2], [0, 1]]` — translation `t ↦ t + 2`
- Generator 1 (A): `[[2, 1], [1, 0]]` — inversion-translation `t ↦ 2 + 1/t`
- Generator 2 (D): `[[2, -1], [1, 0]]` — inversion-translation `t ↦ 2 - 1/t` -/
def berggren2x2 : Fin 3 → Matrix (Fin 2) (Fin 2) ℤ
  | 0 => !![1, 2; 0, 1]
  | 1 => !![2, 1; 1, 0]
  | 2 => !![2, -1; 1, 0]

end

end
